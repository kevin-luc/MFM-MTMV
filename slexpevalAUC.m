classdef slexpevalAUC< slexpeval
    %SLEXPVALMCERRORRATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function s = slexpevalAUC()
            s = s@slexpeval('AUC','AUC');
            s.discription='AUC';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          num_task = size(labels,1);          
          values = zeros(num_task,1);
          for t = 1:num_task
              labels{t}(labels{t}<0) = 0;
              values(t) = scoreAUC(labels{t}(:),outputs{t}(:));
          end
          value = mean(values);
          s.value=[s.value value];
      end
    end
    
end