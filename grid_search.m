% tuning parameters
function [bestPara] = exp_grid(algo_id, data_id, num_metric,loss_func)
    base = 10;
    k = 20;    
    n = 11;
    m = 11;
    para.IsCv = 1;
    
    result_avg = cell(num_metric,1);
    result_std = cell(num_metric,1);
    for metric = 1:num_metric
        result_avg{metric} = cell(n+1,m+1);
        result_std{metric} = cell(n+1,m+1);    
        for i = 1 : n+1
            for j = 1 : m+1
                result_avg{metric}{ i, j } = Inf;
                result_std{metric}{ i, j } = Inf;
            end;
        end;
    end
%     lambda = exp(-8+(0:n));
%     gamma_1 = exp(-8+(0:n));
    para1 = [base.^(-6+(1:n))];
    para2 = [ base.^(-6+(1:m))];
    for metric = 1:num_metric
        for i = 1 : n
            result_avg{metric}{ i+1, 1 } = para1(i);
            result_std{metric}{ i+1, 1 } = para1(i);
        end
        for j = 1 : m
            result_avg{metric}{ 1, j+1 } = para2(j);
            result_std{metric}{ 1, j+1 } = para2(j);
        end
    end
    for j = 1 : m
%        for i = n : -1 : 1
        for i = 1:n
            para.para1 =  para1(i);
            para.para2 = para2(j);
            para.k = k;
            [ avg_metrics, std_metrics ] = ...
                 exp_func( algo_id, data_id, para, loss_func);
             for metric = 1:num_metric
                result_avg{metric}{ i+1, j+1 } = avg_metrics(metric);
                result_std{metric}{ i+1, j+1 } = std_metrics(metric);
                csvwrite( [ 'result/avg-algo' num2str( algo_id ) '-' data_id '-m' num2str(metric) '.csv' ], result_avg{metric} );
            end
        end;
    end;
    bestPara = cell(metric,1);
    for metric = 1:num_metric
        if loss_func == 1
            [v,idx] = max([result_avg{metric}{2:end,2:end}]);
        else
            [v,idx] = min([result_avg{metric}{2:end,2:end}]);
        end
        idx1 = rem(idx-1, size(avg_metrics,1)-1)+1;
        bestPara{metric}.para1 = para1(idx1);
        idx2 = floor((idx-1)/ (size(avg_metrics,1)-1))+1;
        bestPara{metric}.para2 = para2(idx2);
    end
end

% function exp_grid(algo_id, data_id)
%     base = 10;
%     k = 10;    
%     n = 10;
%     m = 10;
%     num_metric = 3;
%     para.IsCv = 1;
%     
%     result_avg = cell(num_metric,1);
%     result_std = cell(num_metric,1);
%     for metric = 1:num_metric
%         result_avg{metric} = cell(n+1,m+1);
%         result_std{metric} = cell(n+1,m+1);    
%         for i = 1 : n+1
%             for j = 1 : m+1
%                 result_avg{metric}{ i, j } = Inf;
%                 result_std{metric}{ i, j } = Inf;
%             end;
%         end;
%     end
% %     lambda = exp(-8+(0:n));
% %     gamma_1 = exp(-8+(0:n));
%     lambda = [base.^(-6+(1:n))];
%     gamma_1 = [ base.^(-6+(1:m))];
%     for metric = 1:num_metric
%         for i = 1 : n
%             result_avg{metric}{ i+1, 1 } = lambda(i);
%             result_std{metric}{ i+1, 1 } = lambda(i);
%         end
%         for j = 1 : m
%             result_avg{metric}{ 1, j+1 } = gamma_1(j);
%             result_std{metric}{ 1, j+1 } = gamma_1(j);
%         end
%     end
%     for j = 1 : m
%         for i = n : -1 : 1
%             para.lambda =  lambda(i);
%             para.gamma_1 = gamma_1(j);
%             para.k = k;
%             [ avg_metrics, std_metrics ] = ...
%                  exp_func( algo_id, data_id, para, 1);
%              for metric = 1:num_metric
%                 result_avg{metric}{ i+1, j+1 } = avg_metrics(metric);
%                 result_std{metric}{ i+1, j+1 } = std_metrics(metric);
%                 csvwrite( [ 'result/avg-algo' num2str( algo_id ) '-' data_id '-m' num2str(metric) '.csv' ], result_avg{metric} );
%                 csvwrite( [ 'result/std-algo' num2str( algo_id ) '-' data_id '-m' num2str(metric) '.csv' ], result_std{metric} );
%              end            
%         end;        
%     end;
% end
% tuning k
% function exp_exe(algo_id)
%     n = 10;
%     result_avg = cell(n,2);
%     result_std = cell(n,2);
%     k = 2.^(-1+(1:n));
%     for i = 1 : n
%         result_avg{ i, 1 } = k(i);
%         result_std{ i, 1 } = k(i);
%         result_avg{ i, 2 } = Inf;
%         result_std{ i, 2 } = Inf;
%     end
%     for i = 1 : n
%         para.lambda =  0;
%         para.eta = 1;
%         para.k = k(i);
%         [ result_avg{ i, 2 }, result_std{ i, 2 } ] = ...
%             exp_func( algo_id, 'HIV', para, 1 );
%         csvwrite( [ 'result-avg-algo' num2str( algo_id ) '.csv' ], result_avg );
%         csvwrite( [ 'result-std-algo' num2str( algo_id ) '.csv' ], result_std );
%     end;
% end
