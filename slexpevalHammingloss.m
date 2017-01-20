classdef slexpevalHammingloss < slexpeval
%SLEXPEVALHAMMINGLOSS Summary of this class goes here
%   Detailed explanation goes here
   properties
   end

   methods
       % construction function
      function s = slexpevalHammingloss()
            s = s@slexpeval('hammingloss','multilabel');
            s.discription='Hamming loss of the multilabel classification';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          value = slhamming_loss(pre_labels,labels);
          s.value=[s.value value];
      end
   end
end 
