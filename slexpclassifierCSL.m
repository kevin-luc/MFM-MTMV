classdef slexpclassifierCSL < slexpclassifier
    properties
        alpha_; % task relation regularization parameter
        beta_; %  regularization parameter
        gamma_; %  view consistency regularization parameter
        iteration_;
        h_; % number of factors
        loss_; % 0 for regression; 1 for classification
        para_train='-lambda 0.01 -beta 0.01 -gamma 0.01 -f 10';
    end
    
    methods
        function s = slexpclassifierCSL()
            s = s@slexpclassifier( 'CSL', 'CSL-MVMT' );
            s.discription = 'CSL';
        end
        function [ Outputs_task, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            % train_data is a T * 1 cell matrix,
            % each cell is a [d_1, ..., d_V] * instanceNum matrix           
            % labels is a T * 1 cell matrix
            h = s.h_;
            alpha = s.alpha_;
            beta = s.beta_;
            gamma = s.gamma_;
            loss_func = s.loss_;
            num_iter = 10;
            
            num_task = length(train_label);
            num_view  = length( view_index );
            view_index = [ 0, view_index];
            % transform train_data into a cell of taskNum-by-viewNum
            % cell array of matrices, each matrix is a instanceNum-by-viewDim
            % matrix
            trainFea = cell(num_task, num_view);
            testFea = cell(num_task, num_view);   
            train_task_label = cell(num_task,1);
            for t = 1:num_task
                train_task_label{t} = train_label{t}';
                for v = 1:num_view
                    trainFea{t,v} = train_data{t}(view_index(v)+1:view_index(v+1),:);
                    if nnz(trainFea{t,v}) == 0
                        trainFea{t,v} = [];
                        testFea{t,v} = [];
                    else
                        trainFea{t,v} = trainFea{t,v}';
                        testFea{t,v} = test_data{t}(view_index(v)+1:view_index(v+1),:);
                        testFea{t,v} = testFea{t,v}';
                    end
                    
                end
            end
            running_t=cputime;
            [Outputs_task,~,~,~] = CASO_MVMT(testFea, trainFea,train_task_label,testFea,num_iter,h,alpha,beta,gamma);
            
            Pre_Labels = cell(num_task,1);
            Outputs = cell(num_task,1);            
            for t= 1:num_task
                Outputs{t} = Outputs_task{t}';
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
            s.para_train = strcat('-lambda: ',num2str(alpha),' -beta: ', num2str(beta),...
                ' -gamma: ', num2str(gamma), '-h: ', num2str(h));
            s.abstract=[s.name  '('...
                        '-time:' num2str(s.time)...
                        '-para:' s.para_train ...
                        ')'];
        end
    end
end
