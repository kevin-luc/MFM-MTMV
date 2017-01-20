classdef slexpevalMicroprecision < slexpeval
%SLEXPEVALMICROPRECISION Summary of this class goes here
%   Detailed explanation goes here

   properties
   end

   methods
       % construction function
      function s = slexpevalMicroprecision()
            s = s@slexpeval('microprecision','multilabel');
            s.discription='Micro precision of the multilabel classification';
      end
      function [value,s] = evaluate(s,labels,pre_labels,outputs)
          labels(labels>0) = 1;labels(labels<=0) = 0;
          pre_labels(pre_labels>0) = 1;pre_labels(pre_labels<=0) = 0;
          %positive
          XandY = labels(:)&pre_labels(:);
          value=(sum(XandY(:))+1)/(sum(pre_labels(:))+1);
          s.value=[s.value value];
      end
   end
end 
