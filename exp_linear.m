function [bestPara] = exp_linear(algo_id, data_id, num_metric, loss_func)
    base = 10;
    k = 20;    
    n = 11;
    para.IsCv = 1;    
    para.method = 'als';
    
    result_avg = cell(n, num_metric+1);
    for metric = 1:num_metric+1
        for i = 1 : n
                result_avg{i, metric} = Inf;
        end;
    end
    para1 = [base.^(-6+(1:n))];
    for i = 1 : n
        result_avg{ i, 1} = para1(i);
    end
    for i = n : -1 : 1
        para.para1 =  para1(i);
        para.k = k;
        [ avg_metrics, ~ ] = ...
             exp_func( algo_id, data_id, para, loss_func);
         for metric = 1:num_metric
            result_avg{ i, metric+1} = avg_metrics(metric);            
         end
         csvwrite( [ 'result/avg-algo' num2str( algo_id ) '-' data_id '.csv' ], result_avg );
    end;

    if loss_func == 1
        [~,idx] = max([result_avg{:,end}]);
    else
        [~,idx] = min([result_avg{:,end}]);
    end
    bestPara.para1 = para1(idx);
    
end
