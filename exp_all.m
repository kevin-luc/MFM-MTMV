algo_num = 12;
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
        data_id = ['fox-t' num2str(sample_ratio)];
        fname = [data_id '-' num2str(i)];
        k = 20;
        para.IsCv = 0;
        for algo_id = 1:5
   %             MFM
            if algo_id >= 7 && algo_id <=9
                if i == 1
                    tmpPara = exp_grid(algo_id, fname, num_metric, 1);
                    bestPara{algo_id} = tmpPara{end};
                end
                para.para1 = bestPara{algo_id}.para1;
                para.para2 = bestPara{algo_id}.para2;
                para.k = k;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end
                              
            % MFM_LR
            if algo_id == 1
                if i == 1
                    bestPara{algo_id} = exp_linear(algo_id, fname, num_metric, 1);
                end
                para.para1 = bestPara{algo_id}.para1;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end
            % libFM
            if algo_id == 2
                if i == 1
                    bestPara = exp_linear(algo_id, fname, num_metric, 1);
                end
                para.para1 = bestPara.para1; 
                para.method = 'als';
                para.k = k; 
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end 

            % MFM_TF
            if algo_id == 3
                if i == 1
                    bestPara{algo_id} = exp_linear(algo_id, fname, num_metric, 1);
                end
                para.para1 = bestPara{algo_id}.para1;
                para.k = k;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end 
 
            % MFM_MVM
            if algo_id == 4
                if i == 1
                    bestPara{algo_id} = exp_linear(algo_id, fname, num_metric, 1);
                end
                para.para1 = bestPara{algo_id}.para1;
                para.k = k;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end
           

            % IteMM
            if algo_id == 5
                para.a_ = 1;
%                para.c_= 1;
%                para.miu_ = 1e2;
               if i == 1
                   tmpPara = exp_grid(algo_id, fname, num_metric, 1);
                   bestPara{algo_id} = tmpPara{end};
               end 
               para.para1 = bestPara{algo_id}.para1;
               para.para2 = bestPara{algo_id}.para2;
                para.para1 = para.c_;
                para.para2 = para.miu_;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end

            % CSL
           if algo_id == 6
                % dblp1, fox
%                para.para1 = 10^-4;    % alpha, beta
%                para.para2 = 10^-5;    % gamma
               if i == 1
                   tmpPara = exp_grid(algo_id, fname, num_metric, 1);
                   bestPara{algo_id} = tmpPara{end};
               end 
               para.para1 = bestPara{algo_id}.para1;
               para.para2 = bestPara{algo_id}.para2;
                para.h = k;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
             end
            % rMTFL
            if algo_id == 11
                if i == 1
                    tmpPara = exp_grid(algo_id, fname, num_metric, 1);
                    bestPara{algo_id} = tmpPara{end};
                end 
                para.para1 = bestPara{algo_id}.para1;
                para.para2 = bestPara{algo_id}.para2;
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end
            
            % FM single task
            if algo_id == 12
                para.method = 'mcmc';
                para.k = k; 
                [avg_metrics,std_metrics] ...
                    = exp_func( algo_id, fname, para, 1);
            end 

             for metric = 1:num_metric
                result_avg{metric}{ algo_id, i+1} = avg_metrics(metric);
                csvwrite( [ 'result/' data_id '-m' num2str(metric) '.csv' ], result_avg{metric});
             end
        end
    end
end
