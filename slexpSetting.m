classdef slexpSetting
%SLEXPSETTING Summary of this class goes here
%   
   properties
       name;
       discription;
       classifier;
       data;
       label;
       num_train;
       evaluations; % evaluation methods
       time=[]; % time cost of the classifier
      
       time_train=[];
       time_test=[];
       paraSelector=[];
   end

   methods 
       function obj = slexpSetting(name,discription)
           obj.name=name;
           obj.discription=discription;
       end
       function s =setClassifier(s,classifier)
           s.classifier=classifier;
       end
       function s =setEval(s,evaluations)
           s.evaluations=evaluations;
       end
       function s =LoadData(s,data,label)
           s.data=data;           
           s.label=label;
       end
       function [ci, obj] = getConfidenceInterval(obj)
          [h,p,ci]=ttest(obj.time(:),0,obj.ttest_alpha);
          obj.time_stat.ci = ci;
          [h,p,ci]=ttest(obj.time_train(:),0,obj.ttest_alpha);
          obj.time_train_stat.ci = ci;
          [h,p,ci]=ttest(obj.time_test(:),0,obj.ttest_alpha);
          obj.time_test_stat.ci = ci;
       end
   end
    methods (Abstract)
        obj = evaluate(obj)
    end
end 
