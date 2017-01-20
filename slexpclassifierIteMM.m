classdef slexpclassifierIteMM < slexpclassifier
    properties
        c_; % task relation regularization parameter
        a_; %  regularization parameter
        miu_; %  view consistency regularization parameter
        iteration_;
        loss_;
        task_; % 0 for regression; 1 for classification
        para_train='-lambda 0.01 -beta 0.01 -gamma 0.01 -f 10';
    end
    
    methods
        function s = slexpclassifierIteMM()
            s = s@slexpclassifier( 'IteMM', 'Iterative Multi-view Multi-task' );
            s.discription = 'IteMM';
        end
        function [ Outputs, Pre_Labels, s ] = classify( s, train_data, train_label, test_data, view_index )
            % train_data is a T * 1 cell matrix,
            % each cell is a [d_1, ..., d_V] * instanceNum matrix           
            % labels is a T * 1 cell matrix
            %%%%-input parameters for IteMM
            % --data: a taskNum-by-1 cell array of matrices, each matirx is a instanceNum-by-viewDim 
            %           represents the feature matrix for a views in a task. If a
            %           view does not exist for a task, then it is an empty matrix.
            % --y:  a taskNum dimension cell array of matrices, each matrix 
            %           contains the true class labels for a task, it is a vector (1-by-n
            %           matrix), labels are -1 or 1. It contains testing samples' label.
            % --fea_num:    a taskNum-by-1 cell array of matrices, containing the
            %         number of features for a view in a task
            % --a:    a taskNum-by-viewNum matrix. a_{task,view}=1 in the paper
            % --miu:    a vector of miu for each task. miu_{task}=0.01 in the paper
            % --iter_num: the number of iterations steps. iterm_num = 100 in the paper
            % --c:      c = 1 in the paper 

            num_task = length(train_label);
            num_view  = length( view_index );
            num_iter = s.iteration_;
            loss_func = s.loss_;
            c = s.c_;
            a = ones(num_task,num_view) * s.a_;
            miu = ones(num_task,1) * s.miu_;
            
            view_index = [ 0, view_index];
            % transform train_data{t} into a cell of taskNum-by-viewNum
            % cell array of matrices, each matrix is a instanceNum-by-viewDim
            % matrix
            view_num = zeros(num_view, 1);
            for v = 2:length(view_index)
                view_num(v-1) = view_index(v) - view_index(v-1);
            end
            data = cell(num_task,1);
            label = cell(num_task,1);
            fea_num = cell(num_task,1);
            for t = 1:num_task
                fea_num{t} = [];
                data{t} = [];
                tmp = [train_data{t} test_data{t}]';                
                for v = 1:num_view
                    idx = view_index(v)+1:view_index(v+1);
                    if nnz(tmp(:,idx)) > 0
                        tmp_dat =  tmp(:,idx);
                       if any(tmp_dat<0)
                            tmp_dat = tmp_dat - min(tmp_dat(:))+1;
                        end
                        data{t} = [data{t} tmp_dat];
                        fea_num{t} = [fea_num{t} length(idx)];
                    end
                end
                num_test = size(test_data{t},2);
                label{t} = [train_label{t} zeros(1,num_test)]';
            end                       
            
            running_t=cputime;
            [Outputs_task,~] = MTMV_graph_multi_task(data, label,fea_num,a, miu, c, num_iter);
                        
            Outputs = cell(num_task,1);
            Pre_Labels = cell(num_task,1);       
            for t = 1:num_task
                num_train = size(train_label{t},2);
                Outputs{t} = Outputs_task{t}(num_train+1:end)';
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
%             s.para_train = strcat('-lambda: ',num2str(alpha),' -beta: ', num2str(beta),...
%                 ' -gamma: ', num2str(gamma), '-h: ', num2str(h));
            s.abstract=[s.name  '('...
                        '-time:' num2str(s.time)...
                        '-para:' s.para_train ...
                        ')'];
        end
    end
end
