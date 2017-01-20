classdef slexpclassifierLibFM < slexpclassifier
    properties
        lambda_; % regularization parameter
        method_; % 0:ALS, 1:SGD, else:MCMC
        k_; % number of factors
        iteration_;
        loss_; % 0 for regression; 1 for classification
        para_train='-k: 10';
    end
    
    methods
        function s = slexpclassifierLibFM()
            s = s@slexpclassifier( 'FM', 'factorization machines' );
            s.discription = 'FM';
        end
        function [ Outputs, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            % data is a T * 1 cell matrix; each cell is a [d_1;...;d_V ] * n_t matrix
            % view_index is a vector of the indices of each view in the data
            % labels is a T * 1 cell matrix
            rand ( 'seed', 5948 );
%             randn( 'seed', 5948 );
            loss_func = s.loss_;
            k = s.k_;           
            method = s.method_;
            lambda = s.lambda_;
            eps = 1e-6;
            Para.loss_func = loss_func;

            num_iter  = s.iteration_;
            num_task = length(train_label);
            num_view  = length( view_index );
            
            Xtrain = [];
            Xtest = [];
            Ytrain = [];

            test_index = zeros(num_task+1,1);
            
            for t = 1:num_task
                test_index(t+1) = test_index(t)+size( test_data{t} , 2 );
                task_as_view_vector = sparse(num_task, size( train_data{t}, 2 ));
                task_as_view_vector(t,:) = 1;
                tmp_data = [train_data{t}; task_as_view_vector];
                Xtrain = [Xtrain; tmp_data'];
                Ytrain = [Ytrain; full(train_label{t})'];
                
                task_as_view_vector = sparse(num_task, size( test_data{t}, 2 ));
                task_as_view_vector(t,:) = 1;
                tmp_data = [test_data{t}; task_as_view_vector];
                Xtest = [Xtest; tmp_data'];
            end
            Ytest = zeros(size(Xtest,1),1);
            clear train_data test_data train_label;
            
            randIdx = randperm(length(Ytrain));
            Ytrain = Ytrain(randIdx);
            Xtrain = Xtrain(randIdx,:);
            
            
            libsvmwrite('tmp/train.libfm',Ytrain,Xtrain);
            libsvmwrite('tmp/test.libfm',Ytest,Xtest);
            system('./libfm/bin/convert --ifile tmp/train.libfm --ofilex tmp/train.x --ofiley tmp/train.y');
            system('./libfm/bin/convert --ifile tmp/test.libfm --ofilex tmp/test.x --ofiley tmp/test.y');
            system('./libfm/bin/transpose --ifile tmp/train.x --ofile tmp/train.xt');
            system('./libfm/bin/transpose --ifile tmp/test.x --ofile tmp/test.xt');
%             running_t=cputime;
            if loss_func == 1
                loss_str  = 'c';
            else
                loss_str  = 'r';
            end
            dim_str = ['"1,1,' num2str(k) '"'];            
            if strcmp(method,'mcmc')
                cmd_str = ['./libfm/bin/libFM -task ' loss_str ' -dim ' dim_str ' -iter ' num2str(num_iter) ... 
                    ' -test tmp/test -train tmp/train -out tmp/pred.txt'];
            else
                para_str = ['"' num2str(lambda) '"'];
    %            cmd_str = ['./libfm/bin/libFM -method sgda -init_stdev 0.1 -learn_rate 0.01 -task '...
    %                loss_str ' -dim ' dim_str ' -iter ' num2str(num_iter) ' -test tmp/test -train tmp/train -validation tmp/test -out tmp/pred.txt'];
                cmd_str = ['./libfm/bin/libFM -method ' method ' -regular ' para_str ' -init_stdev 1 -learn_rate 0.1 -task '...
                   loss_str ' -dim ' dim_str ' -iter ' num2str(num_iter) ' -test tmp/test -train tmp/train -out tmp/pred.txt'];
            end
            tic;
            system(cmd_str);
            Outputs_task = importdata('tmp/pred.txt');
            s.time_train = toc;
            
%             plot( history );            
            % test
            running_t=cputime;            
            Outputs_task = Outputs_task';
            if loss_func == 0
                Pre_Labels_task = Outputs_task;
            elseif loss_func == 1
%                Outputs_task = 1 ./ ( 1 + exp( - Outputs_task) ); 
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
            s.para_train = [' -k:' num2str(s.k_)];
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
