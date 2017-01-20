% tuning parameters
function [bestPara] = exp_grid(algo_id, data_id, num_metric,loss_func)
    base = 10;
    k = 20;    
    n = 6;
    m = 11;
    para.IsCv = 1;
    
    result_avg = cell(num_metric,1);
    for metric = 1:num_metric
        result_avg{metric} = cell(n+1,m+1);
        for i = 1 : n+1
            for j = 1 : m+1
                result_avg{metric}{ i, j } = Inf;
            end;
        end;
    end
    para1 = [base.^(-6+(1:n))];
    para2 = [ base.^(-6+(1:m))];
    for metric = 1:num_metric
        for i = 1 : n
            result_avg{metric}{ i+1, 1 } = para1(i);
        end
        for j = 1 : m
            result_avg{metric}{ 1, j+1 } = para2(j);
        end
    end
    for j = 1 : m
%        for i = n : -1 : 1
        for i = 1:n
            para.para1 =  para1(i);
            para.para2 = para2(j);
            para.k = k;
            [ avg_metrics, ~ ] = ...
                 exp_func( algo_id, data_id, para, loss_func);
             for metric = 1:num_metric
                result_avg{metric}{ i+1, j+1 } = avg_metrics(metric);
                csvwrite( [ 'result/avg-algo' num2str( algo_id ) '-' data_id '-m' num2str(metric) '.csv' ], result_avg{metric} );
             end            
        end;
    end;
    bestPara = cell(metric,1);
    for metric = 1:num_metric
        if loss_func == 1
            [~,idx] = max([result_avg{metric}{2:end,2:end}]);
        else
            [~,idx] = min([result_avg{metric}{2:end,2:end}]);
        end
        idx1 = rem(idx-1, size(result_avg{metric},1)-1)+1;
        bestPara{metric}.para1 = para1(idx1);
        idx2 = floor((idx-1)/ (size(result_avg{metric},1)-1))+1;
        bestPara{metric}.para2 = para2(idx2);
    end
end

