classdef slexpeval
%SLEXPEVAL Summary of this class goes here
%   Detailed explanation goes here

   properties
       name;% the name of the evaluation method
       type;% the type of the evaluation method
       discription; % detail discription of the evaluation method
       value=[];
       stat; %statistics: e.g. mean, std, confidenceinterval
       ttest_alpha=0.05;
   end

   methods
       % construction function
       function s = slexpeval(name,type)
            s.name=name;
            s.type=type;
       end
      function [meanVal, obj ]= getMean(obj)
            meanVal=mean(obj.value(:));
            obj.stat.mean=meanVal;
      end
      function [stdVal, obj] = getStd(obj)
          stdVal= std(obj.value(:));
          obj.stat.std =stdVal;
      end
      function [ci, obj] = getConfidenceInterval(obj)
          [h,p,ci]=ttest(obj.value(:),0,obj.ttest_alpha);
          obj.stat.ci = ci;
      end
   end
   methods (Abstract)
      [value,obj] = evaluate(obj,labels,prelabels,outputs,varargin)
%        meanVal = getMean(obj)
%        stdVal = getStd(obj)
   end

end 
