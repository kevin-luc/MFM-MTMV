classdef slexpevalMacroF1 < slexpeval
%SLEXPEVALMICROF1 Summary of this class goes here
%   Detailed explanation goes here

   properties
   end

   methods
      % construction function
      function s = slexpevalMacroF1()
            s = s@slexpeval('macroF1','multilabel');
            s.discription='Macro F1 of the multilabel classification';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          %positive
          num_task = size(labels,1);
          Precisions = zeros(num_task,1);
          Recalls = zeros(num_task,1);
          for t = 1:num_task
              labels{t}(labels{t}>0) = 1;labels{t}(labels{t}<=0) = 0;
              pre_labels{t}(pre_labels{t}>0) = 1;pre_labels{t}(pre_labels{t}<=0) = 0;
              XandY = labels{t}(:)&pre_labels{t}(:);
              Precisions(t)=(sum(XandY(:))+1)/(sum(pre_labels{t}(:))+1);
              Recalls(t)=(sum(XandY(:))+1)/(sum(labels{t}(:))+1);          
          end
          Precision = mean(Precisions);
          Recall = mean(Recalls);
          value = 2*Precision*Recall/(Precision+Recall);
          s.value=[s.value value];
      end
   end
end 
