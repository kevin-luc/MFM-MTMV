classdef slexpclassifierMFM_LR < slexpclassifier
    properties
        gamma1_; % regularization parameter
        k_; % number of factors
        iteration_;
        loss_; % 0 for regression; 1 for classification
        para_train='-gamma: 100';
    end
    
    methods
        function s = slexpclassifierMFM_LR()
            s = s@slexpclassifier( 'LR', 'linear regression w/ L21 norm' );
            s.discription = 'LR';
        end
        function [ Outputs, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            % data is a T * 1 cell matrix; each cell is a [d_1;...;d_V ] * n_t matrix
            % view_index is a vector of the indices of each view in the data
            % labels is a T * 1 cell matrix
            rand ( 'seed', 5948 );
%             randn( 'seed', 5948 );
            loss_func = s.loss_;
            Para.loss_func = loss_func;
            regPara.gamma_1 = s.gamma1_;
            
            num_iter  = s.iteration_;
            num_task = length(train_label);
            
            
            Xtrain = [];
            Xtest = [];
            Ytrain = [];

            train_index = zeros(num_task+1,1);
            test_index = zeros(num_task+1,1);
            for t = 1:num_task
                train_index(t+1) = train_index(t)+size( train_data{t}, 2 );
                test_index(t+1) = test_index(t)+size( test_data{t} , 2 );
                if loss_func == 1
                    Xtrain = [Xtrain full(train_data{t})];
                    Xtest = [Xtest full(test_data{t})];
                else
                    Xtrain = [Xtrain train_data{t}];
                    Xtest = [Xtest test_data{t}];
                end
                Ytrain = [Ytrain; full(train_label{t})']; 
            end       
            clear train_data test_data train_label;
            
            running_t=cputime;            
            % initialize 
            num_fea = size(Xtrain,1);
            Para.U = randn(num_task,num_fea);
            Ada.U = zeros( size(Para.U));
            
            % assign zeros to missing features in each task
            for t = 1:num_task
                idx = train_index(t)+1:train_index(t+1);
                missing_features = sum(Xtrain(:,idx)>0,2)==0;
                Para.U(t,missing_features) = 0;
            end
            
            history = zeros(num_iter,1);
            regPara.step_size = 0.1;
            for  iter = 1: num_iter
%                 regPara.step_size = 1/sqrt(iter+10);
                [Para, Ada] = Update_U(Para, Ada, regPara, Xtrain, Ytrain, train_index, loss_func);                   

                history(iter) = Compute( Para, regPara, Xtrain, Ytrain, train_index, loss_func);
                if rem(iter,20)==1
                    fprintf( '(%d):\t%.6f\n', iter, history( iter ) );
                end
                if isnan( history( iter ) ) || ( iter > 1 && history( iter ) > history( iter - 1 ) - 1e-6 )
                    break;
                end;
            end

            
            s.time_train = cputime-running_t;
            s.time = cputime - running_t;            
%             plot( history );
            
            % test
            running_t=cputime;
            
            [Outputs_task] = Predict( Para, Xtest, test_index );
            Outputs_task = Outputs_task';
            if loss_func == 0
                Pre_Labels_task = Outputs_task;
                Pre_Labels_task(Outputs_task<1) = 1;
                Pre_Labels_task(Outputs_task>5) = 5;
            elseif loss_func == 1
                Outputs_task = 1 ./ ( 1 + exp( - Outputs_task) );                
                Pre_Labels_task = -1*ones(size(Outputs_task));
                Pre_Labels_task( Outputs_task > 0.5 ) = 1;
            end;
            
            Pre_Labels = cell(num_task,1);
            Outputs = cell(num_task,1);            
            for t= 1:num_task
                idx = test_index(t)+1:test_index(t+1);
                Pre_Labels{t} = Pre_Labels_task(idx);
                Outputs{t} = Outputs_task(idx);
            end    
            

            s.time_test = cputime-running_t;

            s.time = s.time_train + s.time_test;
            s.para_train = ['-gamma:' num2str(regPara.gamma_1)];
            % save running state discription
            s.abstract=[s.name  '('...
                        '-time:' num2str(s.time)...
                        '-time_train:' num2str(s.time_train)...
                        '-time_test:' num2str(s.time_test)...
                        '-para:' s.para_train ...
                        ')'];
                    
        end
    end
end

function [ Para, Ada ] = Update_U( Para, Ada, regPara, X, Y, task_index, loss_func)
% U is a D * T matrix 
% f(x) = z^T*U + <W,Z>
% delta_loss_t = sum_t,i X(:,i) * delta_L(i);
% grad_U_t = delta_loss + gamma * D*U_t
% grad_U_t <-  grad_U_t - step_size * grad_theta ./ sqrt(Ada.Theta);
% Pi_Z_Theta: is a N * k matrix, where each row is product of Z_Theta
    gamma_1 = regPara.gamma_1;
    eps = 1e-6;
    step_size = regPara.step_size;
    [ S] = Predict( Para, X, task_index);
    [~, delta_L] = Compute_loss(S, Y, task_index, loss_func);
    
    U = Para.U;
    % 2,1 norm is column sparse
%    D_dash = ComputeDv(U,eps);
    
    % Z = D*N features
    num_task = length(task_index)-1;
    delta_loss = zeros(size(U));
    
    for t = 1:num_task
        idx = task_index(t)+1:task_index(t+1);
        delta_loss(t,:) = delta_L(idx)' * X(:,idx)';
    end

    D_U = ComputeDv(U);
    grad_U = delta_loss + gamma_1 * D_U;

    
    Ada.U = Ada.U + power( grad_U, 2 );
    Para.U = Para.U - step_size * grad_U ./ ( sqrt( Ada.U ) + 1e-6 );
%     Para.U = Para.U - step_size * grad_U;
end

function [F] = Compute( Para, regPara, X, Y, task_index, loss_func)
% F: value of the objective function
% F = \sum_i loss_i
%   + \gamma_1/2 * |U|_21;
    gamma_1 = regPara.gamma_1;
    L21_norm =@(M) sum(sqrt(sum(abs(M).^2,2)));
    
    [ S] = Predict( Para, X, task_index);
    [F, ~] = Compute_loss(S, Y, task_index, loss_func);
    
    F = F +  gamma_1/2 * L21_norm(Para.U);
end

function [F, delta_L] = Compute_loss(S,Y, task_index, loss_func)
% require predicted values S, and ground truth Y
% F: summation of loss
% delta_L: a n_t*1 array of the gradient of normalized loss
    logit2 = @(x) 1./(1+exp(-x));
        
    if loss_func == 0
        delta_L = 2 * ( S - Y );
        loss = power( Y - S, 2 );
    elseif loss_func == 1
        delta_L = (logit2( Y .* S ) -1) .* Y;
        loss = -log(logit2(Y .* S));
    end
    
    num_task = length(task_index)-1;
    F = 0;
    for t = 1:num_task
        N_t = task_index(t+1)-task_index(t);
        idx = task_index(t)+1:task_index(t+1);
        F = F + sum(loss(idx))/N_t;
        delta_L(idx) = delta_L(idx) / N_t;
    end
end

function [ S] = Predict( Para, X, task_index)
% Z: is a  D*N matrix
% S: is a 1*N vector of predictied values 
% Pi_Z_Theta_v: is a N * k matrix, 
%       where each row is the product of Z^{~which_view} * theta^{~which_view}
% Pi_Z_Theta: is a N * k matrix, where each row is product of Z_Theta 
    N = size(X,2);
    
    num_task = length(task_index)-1;
    S = zeros(N,1);
    for t= 1:num_task
        idx = task_index(t)+1:task_index(t+1);
        S(idx) = S(idx) + X(:,idx)' * Para.U(t,:)';
    end    
end

function [Dv] = ComputeDv(M)
    eps = 1e-4;
    M_rnorm = sqrt(sum(abs(M).^2,2));
    Dv_diag = sqrt(eps + M_rnorm .* M_rnorm);
    Dv = bsxfun(@rdivide,M,Dv_diag);
end
