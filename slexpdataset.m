classdef slexpdataset
%EXPDATASET : experiment dataset class
% informations for datasets and methods for loading datasets

   properties
       name;    % dataset name: e.g. yeast
       type;    % dataset type: e.g. multilabel
       discription; %dataset discription
       randomSeed = 5489; % random seed for subsampling
       
   end

   methods
       % construction function
       function obj = slexpdataset(name,type)
           obj.name=name;
           obj.type=type;
       end
   end
   methods
       function [data,label]= sampling(obj,varargin)
           % [to implement]
       end
       
   end
   methods (Abstract)
       % load dataset
      [data, label] = Load(obj,varargin)
   end
end 
