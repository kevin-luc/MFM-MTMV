classdef slexpclassifier
%SLEXPCLASSIFIER Summary of this class goes here
%   Detailed explanation goes here

   properties
       name;
       type;
       discription;
       %properties
       abstract;% abstract string about classifier parameter setting, time cost
       time=0;  % time cost
       time_train = 0; % training time
       time_test = 0;  % testing time
       expsetting; % the expsetting
       %% for debug
       round=0;% parameter for sampling rounds
        test_label=[]; 
%         evaluation=slexpevalErrorRate();
        debug =false;
        sel_para= false;
   end

   methods
       % construction function
       function s = slexpclassifier(name,type)
            s.name=name;
            s.type=type;
       end
       %% result evaluation
       function retVal = evalutate(s, pre_label)
           if ~s.debug
               retVal=0;
               return ;
           end
               
           outputs=[];
           retVal = s.evaluation.evaluate(s.test_label,pre_label,outputs);
       end
       function s = clean(s)
       end
   end
   
   methods (Abstract)
      [Outputs,Pre_labels,obj]=classify(obj,train_data,train_label,test_data,view_index, varargin)
   end
end 
