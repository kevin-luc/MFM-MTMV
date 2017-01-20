function [g, f] = MTMV_graph_multi_task(data, y, fea_num, a, miu, c, iter_num)
%%%%-input parameters
% --data: a taskNum-by-1 cell array of matrices, each matirx is a instanceNum-by-viewDim 
%           represents the feature matrix for a views in a task. If a
%           view does not exist for a task, then it is an empty matrix.
% --y:  a taskNum dimension cell array of matrices, each matrix 
%           contains the true class labels for a task, it is a vector
%           (n-by-1 matrix), labels are -1 or 1. It contains testing samples' label.
% --fea_num:    a taskNum-by-1 cell array of matrices, containing the
%         number of features for a view in a task
% --a:    a taskNum-by-viewNum matrix. a_{task,view}=1 in the paper
% --miu:    a vector of miu for each task. miu_{task}=0.01 in the paper
% --iter_num: the number of iterations steps. iterm_num = 100 in the paper
% --c:      c = 1 in the paper 


nT = length(data);
nV = 0;

tmp = fea_num{1};
for i = 1:nT
    current = fea_num{i};
    if length(current) > nV
        nV = length(current);
    end
    if current(1) ~= tmp(1)
        disp('Feature num of first view does not agree');
        return;
    end
end

g = cell(nT, 1);
for i = 1:nT
    g{i} = y{i};
end
f = cell(nT, nV);
L = cell(nT, nV);
for i = 1:nT
    index = 1;
    tmp = fea_num{i};
    current_data = data{i};
    for j = 1:length(tmp)
        f{i, j} = zeros(tmp(j), 1);
        L{i, j} = Calculate_Lap(current_data(:, index:(index + tmp(j) - 1)));
        index = index + tmp(j);
    end
end

for t = 1:iter_num
    for i = 1:nT
        tmp = fea_num{i};
        for j = 2:length(tmp)
            f{i, j} = -L{i, j}' * g{i};
        end
    end
    
    M = zeros(nT, nT);
    G = zeros(nT, tmp(1));
    for i = 1:nT
        M(i, :) = -c;
        M(i, i) = a(i, 1) + c * (nT - 1);
        G(i, :) = -a(i, 1) * g{i}' * L{i, 1};
    end
%     M = inv(M);
    G = M \ G;
    for i = 1:nT
        f{i, 1} = G(i, :)';
    end

    for i = 1:nT
        tmp = fea_num{i};
        g{i} = miu(i) * y{i} / (sum(a(i, :)) + miu(i));
        for j = 1:length(tmp)
            g{i} = g{i} - a(i, j) * L{i, j} * f{i, j} / (sum(a(i, :)) + miu(i));
        end
    end
end

% predict labels
for i = 1:nT
    n1 = length(find(y{i} > 0));
    n2 = length(find(y{i} < 0));
    I = sort(g{i});
    index = round((n2 * length(y{i})) / (n1 + n2));
    thre = I(index);
    g{i} = g{i} - thre;
end
