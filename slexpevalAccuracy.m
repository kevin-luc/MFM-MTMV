classdef slexpevalAccuracy< slexpeval
    %SLEXPVALMCERRORRATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function s = slexpevalAccuracy()
            s = s@slexpeval('Accuracy','multiclass');
            s.discription='Accuracy Rate of the multiclass classification';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)          
          num_task = size(labels,1);
          values = zeros(num_task,1);
          for t = 1:num_task
              labels{t}(labels{t}>0) = 1;labels{t}(labels{t}<=0) = 0;
              pre_labels{t}(pre_labels{t}>0) = 1;pre_labels{t}(pre_labels{t}<=0) = 0;
              values(t) = sum(labels{t}(:) == pre_labels{t}(:))/length(labels{t});
          end
          value = mean(values);
          s.value=[s.value value];
      end
    end
    
end