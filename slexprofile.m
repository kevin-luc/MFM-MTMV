classdef slexprofile
%SLEXPROFILE Summary of this class goes here
%   Detailed explanation goes here
   properties
       dataset;
       expsetting;
       classifier;
       evalmethods;
       result
   end

   methods 
       % construction function
       function obj = slexprofile(dataset,expsetting,classifier,evalmethods,result)
           obj.dataset = dataset;
           obj.expsetting = expsetting;
           obj.classifier = classifier;
           obj.evalmethods = evalmethods;
           obj.result=result;
       end
       function s=run(s,IsCv)
           % load dataset
           [data, label] = s.dataset.Load();
           % profile experiment settings
           s.expsetting = s.expsetting.setClassifier(s.classifier);
           s.expsetting = s.expsetting.setEval(s.evalmethods);
           s.expsetting.data = data; 
           s.expsetting.label = label;
           % run experiment
           if IsCv
               s.expsetting = s.expsetting.evaluate_cvo();
           else
               s.expsetting = s.expsetting.evaluate();
           end           
           % clear dataset
           s.expsetting.data = []; 
           s.expsetting.label = [];
           % save setting
           save(s.result,'s');
           for i=1:length(s.expsetting.evaluations)
               fprintf('&%.3f$\\pm$%.3f\n',mean(s.expsetting.evaluations{i}.value),std(s.expsetting.evaluations{i}.value));
           end;
       end
       function  massRun(s,fieldName, values,results)
           % load dataset
           [data, label] = s.dataset.Load();
           % profile experiment settings
           s.expsetting = s.expsetting.setClassifier(s.classifier);
           s.expsetting = s.expsetting.setEval(s.evalmethods);
           s.expsetting.data = data; 
           s.expsetting.label = label;
%            s.expsetting.unlabel_data = unlabel_data;
           % run experiment
           s.expsetting = s.expsetting.massevaluate(fieldName, values);
           % clear dataset
           numPara=size(values(:),1);
           s.expsetting.data = []; 
           s.expsetting.label = [];
           tmp_s=s;
           for v=1:numPara
                ss{v}=tmp_s;
                ss{v}.expsetting=expsetting{v};
                ss{v}.expsetting.data=[];
                ss{v}.expsetting.label=[];
                % save setting
                s=ss{v};
                save(results{v},'s');
           end

       end
   end
end 
