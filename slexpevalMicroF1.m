classdef slexpevalMicroF1 < slexpeval
%SLEXPEVALMICROF1 Summary of this class goes here
%   Detailed explanation goes here

   properties
   end

   methods
      % construction function
      function s = slexpevalMicroF1()
            s = s@slexpeval('microF1','multilabel');
            s.discription='Micro F1 of the multilabel classification';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          
          num_task = size(labels,1);
          values = zeros(num_task,1);
          for t = 1:num_task
              labels{t}(labels{t}>0) = 1;labels{t}(labels{t}<=0) = 0;
              pre_labels{t}(pre_labels{t}>0) = 1;pre_labels{t}(pre_labels{t}<=0) = 0;
              
              XandY = labels{t}(:)&pre_labels{t}(:);          
              Precision=(sum(XandY(:))+1)/(sum(pre_labels{t}(:))+1);
              Recall=(sum(XandY(:))+1)/(sum(labels{t}(:))+1);          
              values(t) = 2*Precision*Recall/(Precision+Recall);
          end
          value = mean(values);
          s.value=[s.value value];
      end
   end
end 
