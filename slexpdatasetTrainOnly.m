classdef slexpdatasetTrainOnly< slexpdataset
    %SLSEPDATASETBINARYNCI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dset;
    end
    
    methods
        function s = slexpdatasetTrainOnly()
            s = s@slexpdataset('TO','Only contains training dataset');
            s.discription ='TO';
        end
       function [data, label] = Load(obj,varargin)
           % train_data is a T * 1 cell matrix
           % train_data is a vector keeping the dimensionality of each view
           % labels is a T * 1 cell matrix
           load(['data/' obj.dset '.mat'],'-mat');
           data = cell(3,1);
           label = cell(2,1);
           data{1} = train_data;
           data{2} = [];
           data{3} = view_index;
           label{1} = train_label;
           label{2} = [];
       end
    end
end
