classdef slexpclassifierFM < slexpclassifier
    properties
        lambda_; % regularization parameter
        method_; % 0:ALS, 1:SGD, else:MCMC
        k_; % number of factors
        iteration_;
        stdev_;
        loss_; % 0 for regression; 1 for classification
        para_train='-k: 10';
    end
    
    methods
        function s = slexpclassifierFM()
            s = s@slexpclassifier( 'FMs', 'factorization machines' );
            s.discription = 'FMs';
        end
        function [ Outputs, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            % data is a T * 1 cell matrix; each cell is a [d_1;...;d_V ] * n_t matrix
            % view_index is a vector of the indices of each view in the data
            % labels is a T * 1 cell matrix
            loss_func = s.loss_;
            k = s.k_;           
            method = s.method_;
            lambda = s.lambda_;

            num_iter  = s.iteration_;
            num_task = length(train_label);
            
            Xtrain = cell(num_task,1);
            Xtest = cell(num_task,1);
            Ytrain = cell(num_task,1);
            Ytest = cell(num_task,1);
            for t = 1:num_task              
                Xtrain{t} = train_data{t}';
                Xtest{t} = test_data{t}';
                Ytrain{t} = full(train_label{t})';
                Ytest{t} = zeros(size(Xtest{t},1),1);
            end
            
            clear train_data test_data train_label;
            
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

            s.time_train = 0;
            Outputs = cell(num_task,1);
            Pre_Labels = cell(num_task,1);
            for t = 1:num_task
                libsvmwrite('tmp/train.libfm',Ytrain{t},Xtrain{t});
                libsvmwrite('tmp/test.libfm',Ytest{t},Xtest{t});
                system('./libfm/bin/convert --ifile tmp/train.libfm --ofilex tmp/train.x --ofiley tmp/train.y');
                system('./libfm/bin/convert --ifile tmp/test.libfm --ofilex tmp/test.x --ofiley tmp/test.y');
                system('./libfm/bin/transpose --ifile tmp/train.x --ofile tmp/train.xt');
                system('./libfm/bin/transpose --ifile tmp/test.x --ofile tmp/test.xt');
            
                tic;
                system(cmd_str);
                Outputs{t} = importdata('tmp/pred.txt');
                Outputs{t} = Outputs{t}';
                if loss_func == 0
                    Pre_Labels{t} = Outputs{t};
                elseif loss_func == 1
%                    Outputs_task = 1 ./ ( 1 + exp( - Outputs_task) ); 
                    Pre_Labels{t} = -1*ones(size(Outputs{t}));
                    Pre_Labels{t}( Outputs{t} > 0.5 ) = 1;
                end;                
                s.time_train = s.time_train + toc;
            end
            
            s.time_test = 0;

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