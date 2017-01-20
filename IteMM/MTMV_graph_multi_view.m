function [g, f] = MTMV_graph_multi_view(data, y, fea_num, a, miu, c, iter_num)

nT = length(data);
nV = length(fea_num);

g = cell(nT, 1);
for i = 1:nT
    g{i} = y{i};
end
f = cell(nT, nV);
L = cell(nT, nV);
for i = 1:nT
    index = 1;
    current_data = data{i};
    for j = 1:nV
        f{i, j} = zeros(fea_num(j), 1);
        L{i, j} = Calculate_Lap(current_data(:, index:(index + fea_num(j) - 1)));
        index = index + fea_num(j);
    end
end

for t = 1:iter_num
    for j = 1:nV
        M = zeros(nT, nT);
        G = zeros(nT, fea_num(j));
        for i = 1:nT
            M(i, :) = -c;
            M(i, i) = a(i, j) + c * (nT - 1);
            G(i, :) = -a(i, j) * g{i}' * L{i, j};
        end
        M = inv(M);
        G = M * G;
        for i = 1:nT
            f{i, j} = G(i, :)';
        end
    end

    for i = 1:nT
        g{i} = miu(i) * y{i} / (sum(a(i, :)) + miu(i));
        for j = 1:nV
            g{i} = g{i} - a(i, j) * L{i, j} * f{i, j} / (sum(a(i, :)) + miu(i));
        end
    end
end

for i = 1:nT
    n1 = length(find(y{i} > 0));
    n2 = length(find(y{i} < 0));
    I = sort(g{i});
    index = round((n2 * length(y{i})) / (n1 + n2));
    thre = I(index);
    g{i} = g{i} - thre;
end