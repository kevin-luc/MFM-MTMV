algo_num = 11;
trial_num = 1;
num_metric = 4;
result_avg = cell(num_metric,1);
result_std = cell(num_metric,1);
for metric = 1:num_metric
    result_avg{metric} = cell(algo_num,trial_num);
    result_std{metric} = cell(algo_num,trial_num);    
    for i = 1 : algo_num
        for j = 1 : trial_num+1
            result_avg{metric}{ i, j } = Inf;
            result_std{metric}{ i, j } = Inf;
        end;
    end;
    for i = 1: algo_num
        result_avg{metric}{ i, 1 } = i;
        result_std{metric}{ i, 1 } = i;
    end
end
for sample_ratio = 2:2
    bestPara = cell(algo_num,1);
    for i = 1:trial_num
        data_id = ['ml-t' num2str(sample_ratio)];
        fname = [data_id '-' num2str(i)];
        k = 20;
        para.IsCv = 0;
        for algo_id = 1:algo_num
            % MFM_LR
            if algo_id == 1
                bestPara{algo_id} = reg_linear(algo_id, fname, num_metric, 0);
                para.para1 = bestPara{algo_id}.para1;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 0);
            end
             % libFM
            if algo_id == 2
                bestPara{algo_id} = reg_linear(algo_id, fname, num_metric, 0);
                para.para1 = bestPara{algo_id}.para1; 
                para.method = 'als';
                para.k = k; 
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 0);
            end 
            
           
            % MFM_TF
            if algo_id == 3
                bestPara{algo_id} = reg_linear(algo_id, fname, num_metric, 0);
                para.para1 = bestPara{algo_id}.para1;
                para.k = k;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 0);
            end 

            % MFM_MVM
            if algo_id == 4
                bestPara{algo_id} = reg_linear(algo_id, fname, num_metric, 0);
                para.para1 = bestPara{algo_id}.para1;
                para.k = k;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 0);
            end

            if algo_id >= 7 && algo_id <=9
                tmpPara = reg_grid(algo_id, fname, num_metric, 0);
                bestPara{algo_id} = tmpPara{end};
                para.para1 = bestPara{algo_id}.para1;
                para.para2 = bestPara{algo_id}.para2;
                para.k = k;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 0);
            end

            % rMTFL
             if algo_id == 11
                tmpPara = reg_grid(algo_id, fname, num_metric, 0);
                bestPara{algo_id} = tmpPara{end};
                para.para1 = bestPara{algo_id}.para1;
                para.para2 = bestPara{algo_id}.para2;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 0);
            end

             for metric = 1:num_metric
                result_avg{metric}{ algo_id, i+1} = avg_metrics(metric);
                csvwrite( [ 'result/' data_id '-m' num2str(metric) '.csv' ], result_avg{metric});
             end
        end
    end
end
