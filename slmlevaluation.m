function [ result ] = slmlevaluation( Outputs, Pre_Labels,test_target,varargin)
%SLMLEVALUATION Summary of this function goes here
% $ Syntax $
%   - slprf( X,Y,varargin)

%
% $ Description $
%   - 'type':   the type of P,R,F: 
%               'micro'--micro-averaging (results are computed based on global sums over all decisions) (default ='micro')
%               'macro'--macro-averaging (results are computed on a
%               per-category basis, then averaged over categories)
%       Micro-averaged scores tend to be dominated by the most commonly used categories, 
%       while macro-averaged scores tend to be dominated by the performance in rarely used categories. 
%   
% $ History $
%   - Created by Xiangnan Kong, on Jan 1, 2008

%% parse and verify input arguments
opts.H=true;
opts.O=true;
opts.RL=true;
opts.C=true;
opts.A=true;
opts.prf=true;
opts.prftype='micro';
opts = slparseprops(opts, varargin{:});
%% evaluation

if opts.H
    result.H=slhamming_loss(Pre_Labels,test_target);
end
if opts.O
    result.O=slone_error(Outputs,test_target);
end

if opts.C
    result.C=slcoverage(Outputs,test_target);
end

if opts.RL
    result.RL=slranking_loss(Outputs,test_target);
end

if opts.A
    result.A=slaverage_precision(Outputs,test_target);
end

if opts.prf
    Pre_Labels(Pre_Labels<=0)=0;
    test_target(test_target<=0)=0;
    [ result.P,result.R,result.F]=slprf(Pre_Labels,test_target,'type',opts.prftype);
end
         result.text =[ ...
                '  -H:' num2str(result.H) ...
                '  -O:' num2str(result.O) ...
                '  -C:' num2str(result.C) ...
                '  -RL:' num2str(result.RL) ...
                '  -A:' num2str(result.A)...
                '  -P:' num2str(result.P)...
                '  -R:' num2str(result.R)...
                '  -F:' num2str(result.F)...
                ];
