classdef slexpevalMicrorecallNeg < slexpeval
%SLEXPEVALMICRORECALL Summary of this class goes here
%   Detailed explanation goes here

   properties
   end

   methods
      % construction function
      function s = slexpevalMicrorecallNeg()
            s = s@slexpeval('microrecall','multilabel');
            s.discription='Micro recall of the multilabel classification';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          labels(labels>0) = 1;labels(labels<=0) = 0;
          pre_labels(pre_labels>0) = 1;pre_labels(pre_labels<=0) = 0;
          %negative
          labels = 1-labels;
          pre_labels = 1-pre_labels;
          %positive
          XandY = labels(:)&pre_labels(:);          
          value=(sum(XandY(:))+1)/(sum(labels(:))+1);
          s.value=[s.value value];
      end
   end
end