classdef slexpSettingCollectiveCla < slexpSetting
    %SLEXPSETTINGSEMIRANDSAMPLING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
      numfold=3;
      randomSeed=5489;
      isparallel=false;
    end
    
    methods
       %% Construction function
       function s = slexpSettingCollectiveCla()
           s = s@slexpSetting('cc','Collective Classification.');
       end
       %% interface function
       function s = evaluate(s)
           features=s.data{1};
           index=s.data{2};
           labels=s.label;
           rand('twister',s.randomSeed);
           CVO = cvpartition(labels(1,:)','k',s.numfold);
           train_data= cell(CVO.NumTestSets,1);
           train_label= cell(CVO.NumTestSets,1);
           test_data= cell(CVO.NumTestSets,1);
           test_label= cell(CVO.NumTestSets,1);
            for i = 1:CVO.NumTestSets
                train_data{i}=features(:,CVO.training(i));
                train_label{i}=labels(:,CVO.training(i));
                train_label{i}=full(train_label{i});
                train_label{i}(train_label{i}==0)=-1;
                test_data{i}=features(:,CVO.test(i));
                test_label{i}=labels(:,CVO.test(i));
                test_label{i}=full(test_label{i});
                test_label{i}(test_label{i}==0)=-1;
            end
            %test_data=train_data;%%
            %test_label=train_label;%%
            %vali
%             nsize = size(train_data{1},2);
%             vali_test_idx = randperm(nsize,floor(nsize/s.numfold));
%             vali_train_idx = setdiff(1:nsize,vali_test_idx);
%             vali_test_data = train_data{1}(:,vali_test_idx);
%             vali_train_data = train_data{1}(:,vali_train_idx);
%             vali_test_label = train_label{1}(:,vali_test_idx);
%             vali_train_label = train_label{1}(:,vali_train_idx);
%             base=2;
%             bestv=-1;
%             bestc=-1;
%             for c=-5:5
%                 s.classifier.para_c = base^c;
%                 [Outputs,Pre_labels] = s.classifier.classify(vali_train_data,vali_train_label,vali_test_data,index);
%                 value = s.evaluations{1}.evaluate(vali_test_label,Pre_labels,Outputs);
%                 if value>bestv
%                     bestv = value;
%                     bestc = c;
%                 end;
%             end;
%             s.classifier.para_c = base^bestc;
            %train
            Pre_labels = cell(CVO.NumTestSets,1);
            Outputs = cell(CVO.NumTestSets,1);
            if s.isparallel
                parfor i = 1:CVO.NumTestSets
                   [Outputs{i},Pre_labels{i}] = s.classifier.classify(train_data{i},train_label{i},test_data{i},index);
                   Outputs{i}=full(Outputs{i});
                   Pre_labels{i}=full(Pre_labels{i});
                end
            else
               for i = 1:CVO.NumTestSets
                   [Outputs{i},Pre_labels{i}] = s.classifier.classify(train_data{i},train_label{i},test_data{i},index);
                   Outputs{i}=full(Outputs{i});
                   Pre_labels{i}=full(Pre_labels{i});
               end
            end
            %eval
           for r=1:CVO.NumTestSets
               numEval = size(s.evaluations(:),1);
               for k=1:numEval
                    [value,s.evaluations{k}] = s.evaluations{k}.evaluate(test_label{r},Pre_labels{r},Outputs{r});
                    s.time = [s.time s.classifier.time];
               end
           end
%           fprintf('para_c: %d^%d\n',base,bestc);
       end
  end
end