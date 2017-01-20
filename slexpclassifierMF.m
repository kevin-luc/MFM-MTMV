classdef slexpclassifierMF < slexpclassifier
    properties
        lambda_; % regularization parameter
        eta_; % learning rate
        k_; % number of factors
        iteration_;
        loss_; % 0 for regression; 1 for classification
        para_train='-lambda: 0.01 -eta: 0.1 -f: 10';
    end
    
    methods
        function s = slexpclassifierMF()
            s = s@slexpclassifier( 'MF', 'matrix factorization' );
            s.discription = 'MF';
        end
        
        function [ Outputs, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            rand ( 'seed', 0 );
            randn( 'seed', 0 );
            loss_func = s.loss_;
            k = s.k_;
            lambda = s.lambda_;
            eta = s.eta_;
            num_iter  = s.iteration_;
            num_task = size(train_data, 1);
            num_train = zeros(num_task,1);
            num_test = zeros(num_task,1);
            for t = 1:num_task
                num_train(t) = size( train_data{t}, 2 );
                num_test(t)  = size( test_data{t} , 2 );
            end
            N_train = sum(num_train);
            N_test = sum(num_test);
            % transform task into a view
            num_view  = length( view_index ) + 1;
            index = [ 0, view_index, num_task+view_index(end)];
            train_view_data = [];
            test_view_data = [];
            train_view_label = [];
            for t = 1:num_task
                task_as_view_vector = zeros(num_task, num_train(t));
                task_as_view_vector(t,:) = 1;
                tmp_data = [train_data{t}; task_as_view_vector];
                train_view_data = [train_view_data tmp_data];
                train_view_label = [train_view_label train_label{t}];
                
                task_as_view_vector = zeros(num_task, num_test(t));
                task_as_view_vector(t,:) = 1;
                tmp_data = [test_data{t}; task_as_view_vector];
                test_view_data = [test_view_data tmp_data];                
            end                       
            randIdx = randperm(length(train_view_label));
            train_view_label = train_view_label(randIdx);
            train_view_data = train_view_data(:,randIdx);
            t=cputime;

            Ada.A = cell( num_view, 1 );
            Para.A = cell( num_view, 1 );
            for v = 1 : num_view
                Ada.A{v} = zeros( index( v + 1 ) - index(v), k );
                Para.A{v} = randn( index( v + 1 ) - index(v), k );
            end;
            for iter = 1 : num_iter
                history( iter ) = 0;
                for i = 1 : num_train
                    [ F, Grad ] = Compute( Para, train_view_data(:,i), train_view_label(i), index, lambda, loss_func );
                    for v = 1 : num_view
                        Ada.A{v} = Ada.A{v} + power( Grad.A{v}, 2 );
                        %Para.A{v} = Para.A{v} - eta * Grad.A{v};
                        Para.A{v} = Para.A{v} - eta * Grad.A{v} ./ ( sqrt( Ada.A{v} ) + 1e-6 );
                    end;
                    history( iter ) = history( iter ) + F;
                end;
                history( iter ) = sqrt( history( iter ) / num_train );
                if rem(iter,20)==0
                    fprintf( '(%d):\t%.6f\n', iter, history( iter ) );
                end
                if isnan( history( iter ) ) || ( iter > 1 && history( iter ) > history( iter - 1 ) - 1e-6 )
                    break;
                end;
            end;
%             plot( history );
            
            s.time_train = cputime-t;
            s.time = cputime - t;
            
%             plot( history );
            
            % test
            t=cputime;
            Outputs_view = ones( N_test, 1 );
            Pre_Labels_view = ones( N_test, 1 );
            for i = 1 : N_test
                S = Predict( Para, test_view_data(:,i), index );
                if loss_func == 0
                    Outputs_view(i) = S;
                    Pre_Labels_view(i) = S;
                elseif loss_func == 1
                    Outputs_view(i) = 1 / ( 1 + exp( - S ) );                    
                end;
            end;
            if loss_func == 1
                Pre_Labels_view( Outputs_view < 0.5 ) = -1;
            end
            s.time_test = cputime-t;

            % transform results into multi-task
            Pre_Labels = cell(num_task,1);
            Outputs = cell(num_task,1);
            for t = 1: num_task
                last_num = sum(num_test(1:t-1));
                Pre_Labels{t} = Pre_Labels_view(1+last_num:last_num+num_test(t));
                Outputs{t} = Outputs_view(1+last_num:last_num+num_test(t));
            end

            s.time = s.time_train + s.time_test;
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

function [ F, Grad ] = Compute( Para, x, y, index, lambda, loss_func )
    [ S, B, C ] = Predict( Para, x, index );
    num_view = length( index ) - 1;
    if loss_func == 0
        delta_L = 2 * ( S - y );
        F = power( y - S, 2 );
    elseif loss_func == 1
        delta_L = - y / ( 1 + exp( y * S ) );
        F = log( 1 + exp( - y * S ) );
    end;
    Grad.A = cell( num_view, 1 );
    for v = 1 : num_view
        F = F + lambda * norm( Para.A{v}, 2 );
        delta_A = x( index(v) + 1 : index( v + 1 ) ) * ( C' ./ B(v,:) );
        Grad.A{v} = delta_L * delta_A + lambda * 2 * Para.A{v};
    end;
end

function [ S, B, C ] = Predict( Para, x, index )
    num_view = length( index ) - 1;
    k = size( Para.A{1}, 2 );
    B = zeros( num_view, k );
    C = zeros( k, 1 );
    for f = 1 : k
        for v = 1 : num_view
            B(v,f) = Para.A{v}(:,f)' * x( index(v) + 1 : index( v + 1 ) );
        end;
        C(f) = prod( B(:,f) );
    end;
    S = sum(C);
end