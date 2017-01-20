classdef slexpevalMAE< slexpeval
    %SLEXPVALMCERRORRATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function s = slexpevalMAE()
            s = s@slexpeval('MAE','mean average error');
            s.discription='MAE';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          num_task = size(labels,1);
          values = zeros(num_task,1);
          for t = 1:num_task
              values(t) = sum(abs(labels{t}(:)-pre_labels{t}(:))) / length(labels{t});
          end
          value = mean(values);
          s.value=[s.value value];
      end
    end
    
end