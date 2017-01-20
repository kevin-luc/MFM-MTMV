classdef slexpevalNMSE< slexpeval
    %SLEXPVALMCERRORRATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function s = slexpevalNMSE()
            s = s@slexpeval('NMSE','normalized mean square error');
            s.discription='NMSE';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          num_task = size(labels,1);
          values = zeros(num_task,1);
          N = 0;
          for t= 1:num_task
              N = N + length(labels{t});
          end
          for t = 1:num_task
              values(t) = sum(power(labels{t}(:)-pre_labels{t}(:), 2 ) ) / N;
          end          
          value = sum(values);
          s.value=[s.value value];
      end
    end
    
end