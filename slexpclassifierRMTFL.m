classdef slexpclassifierRMTFL < slexpclassifier
    properties
        rho1_; % task relation regularization parameter
        rho2_; %  regularization parameter
        iteration_;
        loss_; % 0 for regression; 1 for classification
        para_train='-rho1 0.01 -rho2 0.01';
    end
    
    methods
        function s = slexpclassifierRMTFL()
            s = s@slexpclassifier( 'rMTFL', 'rMTFL' );
            s.discription = 'rMTFL';
        end
        function [ Outputs, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            % train_data is a T * 1 cell matrix,
            % each cell is a [d_1, ..., d_V] * instanceNum matrix           
            % labels is a T * 1 cell matrix
            loss_func = s.loss_;
            rho_1 = s.rho1_;
            rho_2 = s.rho2_;
            num_iter  = s.iteration_;
            
            num_task = length(train_label);
            
            for t = 1: num_task
                train_data{t} = train_data{t}';
                test_data{t} = test_data{t}';
                train_label{t} = train_label{t}';
            end

            opts.init = 0;      % guess start point from data. 
            opts.tFlag = 1;     % terminate after relative objective value does not changes much.
            opts.tol = 10^-6;   % tolerance. 
            opts.maxIter = num_iter; % maximum iteration number of optimization.
            
            running_t=cputime;
            [W, ~, ~, ~] = Least_rMTFL(train_data, train_label, rho_1, rho_2, opts);
            
            Outputs = cell(num_task,1);
            for t = 1: num_task
                Outputs{t} = test_data{t} * W(:,t);
            end
            
            Pre_Labels = cell(num_task,1);            
            for t= 1:num_task
                if loss_func == 0
                    Pre_Labels{t} = Outputs{t};
                elseif loss_func == 1
                    Pre_Labels{t} = ones(size(Outputs{t}));
                    Pre_Labels{t}( Outputs{t}<0 ) = -1;
                end
            end   

            disp('train over');
            s.time = cputime - running_t;
            % save running state discription
            s.para_train = strcat('-rho_1: ',num2str(rho_1),' -rho_2: ', num2str(rho_2));
            s.abstract=[s.name  '('...
                        '-time:' num2str(s.time)...
                        '-para:' s.para_train ...
                        ')'];
        end
    end
end