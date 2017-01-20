classdef slexpevalRMSE< slexpeval
    %SLEXPVALMCERRORRATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function s = slexpevalRMSE()
            s = s@slexpeval('RMSE','root-mean-square error');
            s.discription='RMSE';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          num_task = size(labels,1);
          values = zeros(num_task,1);
          for t = 1:num_task
              values(t) = sqrt(sum(power(labels{t}(:)-pre_labels{t}(:), 2 ) ) / length(labels{t}) );
          end
          value = mean(values);
          s.value=[s.value value];
      end
    end
    
end