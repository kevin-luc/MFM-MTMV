classdef slexpclassifierMVM < slexpclassifier
    properties
        lambda_; % regularization parameter
        k_; % number of factors
        iteration_;
        loss_; % 0 for regression; 1 for classification
        para_train='-lambda: 0.01 -k: 10';
    end
    
    methods
        function s = slexpclassifierMVM()
            s = s@slexpclassifier( 'MVM', 'MVM' );
            s.discription = 'MVM';
        end
        function [ Outputs, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            % data is a T * 1 cell matrix; each cell is a [d_1;...;d_V ] * n_t matrix
            % view_index is a vector of the indices of each view in the data
            % labels is a T * 1 cell matrix
            rand ( 'seed', 5948 );
%             randn( 'seed', 5948 );
            loss_func = s.loss_;
            k = s.k_;
            eps = 1e-6;
            Para.loss_func = loss_func;
            regPara.lambda = s.lambda_;
            
            num_iter  = s.iteration_;
            num_task = length(train_label);
            num_view  = length( view_index );
            view_index = [ 0, view_index];
            
            
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
            Para.Theta = cell( num_view, 1 );
            Ada.Theta = cell( num_view, 1 );
            Para.Phi = ones( num_task, k );
%             Para.Phi = randn( num_task, k );
%             Ada.Phi = zeros( size(Para.Phi));
            
            for v = 1 : num_view
                tmp = randn( view_index( v + 1 ) - view_index(v) +1, k );
                Para.Theta{v} = tmp * diag(sqrt(1 ./ (sum(tmp.^2) + eps)));
                Ada.Theta{v} = zeros(size(Para.Theta{v}));
            end;
            
            history = zeros(num_iter,1);
            regPara.step_size = 0.1;
            for  iter = 1: num_iter
%                 regPara.step_size = 1/sqrt(iter+10);
                for v = 1 : num_view
                    [Para, Ada] = Update_Theta(Para, Ada, regPara, Xtrain, Ytrain, view_index,train_index, v, loss_func);
                end;                    
%                [Para, Ada] = Update_Phi(Para, Ada, regPara, Xtrain, Ytrain,view_index,train_index, loss_func);

                history(iter) = Compute( Para, regPara, Xtrain, Ytrain, view_index,train_index, loss_func);
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
            
            [Outputs_task, ~, ~] = Predict( Para, Xtest, view_index, test_index, -1 );
            Outputs_task = Outputs_task';
            if loss_func == 0
                Pre_Labels_task = Outputs_task;
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
            s.para_train = ['-lambda:' num2str(regPara.lambda) ' -k:' num2str(s.k_)];
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

function [ Para, Ada ] = Update_Phi( Para, Ada, regPara, X, Y, view_index, task_index, loss_func)
% grad_phi = sum_i E(:,i)^T * delta_L(i) * Pi_Z_Theta(i,:);
% Phi <-  Phi - step_size * grad_phi ./ sqrt(Ada.Phi);
% Pi_Z_Theta: is a T*1 cell array of n_t * k matrix, where each row is product of Z_Theta
    lambda = regPara.lambda;
    
    step_size = regPara.step_size;
    [ S, ~, Pi_Z_Theta ] = Predict( Para, X, view_index, task_index, -1);
    [~, delta_L] = Compute_loss(S, Y, task_index, loss_func);
    Phi = Para.Phi;

    delta_loss = zeros(size(Phi));   
    num_task = length(task_index)-1;
    for t = 1:num_task
        idx = task_index(t)+1:task_index(t+1);
        delta_loss(t,:) = delta_L(idx)' * Pi_Z_Theta(idx,:);        
    end
    grad = delta_loss + lambda * Phi;
    Ada.Phi = Ada.Phi + power( grad, 2 );
    Para.Phi = Para.Phi - step_size * grad ./ ( sqrt( Ada.Phi ) + 1e-6 );
%     Para.Phi = Para.Phi - step_size * grad;
end

function [ Para, Ada ] = Update_Theta( Para, Ada, regPara, X, Y, view_index, task_index, view, loss_func)
% delta_loss = sum_i z_view(:,i) * delta_L(i) * Pi_Z_Theta_v(i,:) * Phi(t,:);
% grad_theta = delta_loss + beta * Theta
% Theta <-  Theta - step_size * grad_theta ./ sqrt(Ada.Theta);
% Pi_Z_Theta_v: is a N * k matrix, 
%    where each row is the product of Z^{~which_view} * theta^{~which_view}
    step_size = regPara.step_size;
    lambda = regPara.lambda;
    
    [ S, Pi_Z_Theta_v, ~] = Predict( Para, X,  view_index, task_index, view);
    [~, delta_L] = Compute_loss(S, Y, task_index, loss_func);
    Theta = Para.Theta{view};
    
    idxs = view_index(view)+1:view_index(view+1);    
    N = size(X,2);
    Z_view = [ones(1,N); X(idxs,:)];
    delta_loss = zeros(size(Theta));    

    num_task = length(task_index)-1;
    for t = 1:num_task
        idx = task_index(t)+1:task_index(t+1);
        tmp = bsxfun(@times, Pi_Z_Theta_v(idx,:),Para.Phi(t,:));
        tmp = bsxfun(@times, tmp, delta_L(idx,:));
        delta_loss = delta_loss + Z_view(:,idx) * tmp;
    end
    
    grad_theta = delta_loss + lambda* Theta;
    
    Ada.Theta{view} = Ada.Theta{view} + power( grad_theta, 2 );
    Para.Theta{view} = Para.Theta{view} - step_size * grad_theta ./ ( sqrt( Ada.Theta{view} ) + 1e-6 );
%     Para.Theta{view} = Para.Theta{view} - step_size * grad_theta;
end


function [F] = Compute( Para, regPara, X, Y, view_index, task_index, loss_func)
% F: value of the objective function
% F = \sum_i loss_i
%   + \lambda/2 ( |Phi|_F^2 + \sum_p^V |Theta^{p}|_F^2)
%   + \gamma_1/2 * |U|_21;
    lambda = regPara.lambda;
    L21_norm =@(M) sum(sqrt(sum(abs(M).^2,2)));
        
    num_view = length(Para.Theta);
    [ S, ~, ~] = Predict( Para, X, view_index, task_index, -1 );
    [F, ~] = Compute_loss(S, Y, task_index, loss_func);
%     k = size( Para.Phi, 2 );
%     I = eye(k);
    
    F = F + lambda/2 * norm( Para.Phi, 'fro');
    for v = 1 : num_view
        F = F + lambda/2 * norm(Para.Theta{v}, 'fro');
%         F = F + beta * norm(Para.M{v}'*Para.Theta{v}- I, 'fro');
%         F = F + mu * norm(Para.M{v} - Para.Theta{v}+ Para.A{v}/mu, 'fro');        
    end;
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

function [ S, Pi_Z_Theta_v, Pi_Z_Theta ] = Predict( Para, X, view_index, task_index, which_view )
% Z: is a  D*N matrix
% S: is a 1*N vector of predictied values 
% Pi_Z_Theta_v: is a N * k matrix, 
%       where each row is the product of Z^{~which_view} * theta^{~which_view}
% Pi_Z_Theta: is a N * k matrix, where each row is product of Z_Theta 
    num_view = length(Para.Theta);
    k = size( Para.Phi,2);
    N = size(X,2);
    
    Pi_Z_Theta_v = ones(N,k);
    Pi_Z_Theta = ones(N,k);
    
    for v = 1 : num_view
        if v+1 > length(view_index)
            disp(v);
        end
        if size(X,1) < view_index(v+1)
            disp(view_index); 
        end
        tmp = [ones(1,N); X(view_index(v)+1:view_index(v+1),:)];
        tmp  = tmp' * Para.Theta{v};
        if (v ~= which_view)
            Pi_Z_Theta_v = Pi_Z_Theta_v.*tmp;
        end
        Pi_Z_Theta = Pi_Z_Theta.*tmp;
    end
    num_task = length(task_index)-1;
    S = zeros(N,1);
    for t= 1:num_task
        idx = task_index(t)+1:task_index(t+1);
        S(idx) = Pi_Z_Theta(idx,:) * Para.Phi(t,:)';
    end    
end

function [Dv] = ComputeDv(M, eps)
    M_rnorm = sqrt(sum(abs(M).^2,2));
    Dv_diag = 0.5 ./ sqrt(eps + M_rnorm .* M_rnorm);
    Dv = diag(Dv_diag);
end
