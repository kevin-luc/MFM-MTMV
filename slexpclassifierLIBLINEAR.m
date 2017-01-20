classdef slexpclassifierLIBLINEAR < slexpclassifier
    properties
        para_c;
        para_g;
        para_train='-s 3';
        baseLearner;
        num_iter=100;
        fullit=false;
    end
    
    methods
        function s = slexpclassifierLIBLINEAR()
            s = s@slexpclassifier('MKL','LIBLINEAR MKL');
            s.discription='LIBLINEAR MKL';
            s.baseLearner= slexpclassifierBSVM();%slexpclassifierMlknn slexpclassifierBSVM
        end
        function [Outputs,Pre_Labels,s]=classify(s,train_data,train_label,test_data,view_index)
            t=cputime;
            paraStr=[s.para_train ' -c ' num2str(s.para_c)];
            
            
            num_task = size(train_label, 1);

            % transform task into multi-class
            train_view_label = [];
            for t = 1:num_task
                train_view_label = [train_view_label t*(train_label(t,:)>0)];             
            end                       
            
            num_test = size(test_data,2);
            num_view = length(view_index);
            view_index = [0 view_index];
            for i=1:num_view
                xtrain{i} = train_data(view_index(i)+1:view_index(i+1),:)';
                xtest{i} = test_data(view_index(i)+1:view_index(i+1),:)';
            end
            
            models=train_mkl2(train_view_label', xtrain, paraStr);
            [Pre_Labels_view, ~, Outputs_view] = predict_mkl2(zeros(num_test,1), xtest', models);
            
            % transform results into multi-task
            Pre_Labels = zeros(num_task,num_test);
            Outputs = zeros(num_task,num_test);
            for t = 1: num_task
                last_num = sum(num_test(1:t-1));
                Pre_Labels(t,:) = Pre_Labels_view(1+last_num:last_num+num_test(t));
                Outputs(t,:) = Outputs_view(1+last_num:last_num+num_test(t));                
                Pre_Labels(t,Pre_Labels(t,:)==t) = 1;
                Pre_Labels(t,Pre_Labels(t,:)~=t) = -1;
            end
            
            
            
            s.time_train = cputime-t;
            s.time = cputime - t;  
            s.time_test = s.time - s.time_train;
            % save running state discription
            s.abstract=[s.name  '('...
                        '-time:' num2str(s.time)...
                        '-time_train:' num2str(s.time_train)...
                        '-time_test:' num2str(s.time_test)...
                        '-base:' s.baseLearner.name ...
                        ')'];
        end
    end
    
end
