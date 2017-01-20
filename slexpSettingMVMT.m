classdef slexpSettingMVMT < slexpSetting
    %SLEXPSETTINGSEMIRANDSAMPLING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
      numfold=5;
      randomSeed=5489;
      isparallel=false;
    end
    
    methods
       %% Construction function
       function s = slexpSettingMVMT()
           s = s@slexpSetting('MVMT','Multi-view Multi-Task');
       end
       %% interface function
        function s = evaluate(s)
       
           train_data=s.data{1};
           test_data=s.data{2};
           view_index = s.data{3};
           train_label = s.label{1};
           test_label = s.label{2};
            
           [Outputs,Pre_labels, s.classifier] = s.classifier.classify(train_data,train_label,test_data, view_index);

            %eval
           
           numEval = size(s.evaluations(:),1);
           for k=1:numEval                    
                [~, s.evaluations{k}] = s.evaluations{k}.evaluate(test_label,Pre_labels,Outputs);
                %s.evaluations{k}.value = [s.evaluations{k}.value value];
           end
           s.time = [s.time s.classifier.time];
           fprintf('time: %f\n', mean(s.time));
%           fprintf('para_c: %d^%d\n',base,bestc);
       end       
       
       function s = evaluate_cvo(s)
       % features is a T * 1 cell matrix; each cell is a [d_1;...;d_V ] * n_t matrix
       % index is a vector keeping the dimensionality of each view
       % labels is a T * 1 cell matrix
           features= [s.data{1} s.data{2}];
           view_index = s.data{3};
           labels= [s.label{1} s.label{2}];
           num_task = size(features,1);
           rand('twister',s.randomSeed);

           train_data = cell(s.numfold,1);
           train_label = cell(s.numfold,1);
           test_data = cell(s.numfold,1);
           test_label = cell(s.numfold,1);
           for i = 1:s.numfold
               train_data{i} = cell(num_task,1);
               train_label{i} = cell(num_task,1);
               test_data{i} = cell(num_task,1);
               test_label{i} = cell(num_task,1);
           end
           for t = 1:num_task
               CVO = cvpartition(labels{t},'k',s.numfold);
                for i = 1:CVO.NumTestSets
                    train_data{i}{t} = features{t}(:,CVO.training(i));
                    train_label{i}{t} = labels{t}(:,CVO.training(i));
                    train_label{i}{t} = full(train_label{i}{t});
                    test_data{i}{t} = features{t}(:,CVO.test(i));
                    test_label{i}{t} = labels{t}(:,CVO.test(i));
                    test_label{i}{t} = full(test_label{i}{t});
                end
           end
            %test_data=train_data;%%
            %test_label=train_label;%%
            %train
            Pre_labels = cell(CVO.NumTestSets,1);
            Outputs = cell(CVO.NumTestSets,1);
            if s.isparallel
                parfor i = 1:CVO.NumTestSets
                   [Outputs{i},Pre_labels{i}] = s.classifier.classify(train_data{i},train_label{i},test_data{i},view_index);
%                   Outputs{i}=full(Outputs{i});
                   %Pre_labels{i}=full(Pre_labels{i});
                end
            else
               for i = 1:CVO.NumTestSets
                   [Outputs{i},Pre_labels{i},s.classifier] = s.classifier.classify(train_data{i},train_label{i},test_data{i},view_index);
%                   Outputs{i}=full(Outputs{i});
                   %Pre_labels{i}=full(Pre_labels{i});
               end
            end
            %eval
           for r=1:CVO.NumTestSets
               numEval = size(s.evaluations(:),1);
               for k=1:numEval                    
                    [~, s.evaluations{k}] = s.evaluations{k}.evaluate(test_label{r},Pre_labels{r},Outputs{r});
                    %s.evaluations{k}.value = [s.evaluations{k}.value value];                    
               end               
               s.time = [s.time s.classifier.time];
           end
           fprintf('time: %f\n', mean(s.time));
%           fprintf('para_c: %d^%d\n',base,bestc);
       end
  end
end
