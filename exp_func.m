function [exp_avg,exp_std] = exp_func(algo_id,data_id,para,loss_func)
    num_iter = 200;
%    dataset=slexpdatasetHIV();
    if para.IsCv == 1
       dataset=slexpdatasetTrainValid();
       para.IsCv = 0;
%        dataset=slexpdatasetTrainOnly();
    else
        dataset=slexpdatasetTrainTest();
    end
    dataset.dset=data_id;
    if ~exist('result','dir')
        mkdir('result');
    end
    if ~exist(['result/' dataset.name],'dir')
        mkdir('result/',dataset.name);
    end
    if ~exist('tmp','dir')
        mkdir('tmp');
    end
    
    addpath('MALSAR/MALSAR/functions/rMTFL/'); % load function 
    addpath('MALSAR/MALSAR/utils/'); % load utilities
    addpath('CSL-MVMT/');
    addpath('IteMM/');
%    addpath('liblinear-mkl/');
    addpath('libsvm/matlab/');
    if loss_func == 0
        evalmethods{1}=slexpevalRMSE();
        evalmethods{2}=slexpevalMAE();
        evalmethods{3}=slexpevalAMSE();
        evalmethods{4}=slexpevalNMSE();
    else
         evalmethods{1}=slexpevalAccuracy();
         evalmethods{2}=slexpevalMicroF1();
         evalmethods{3}=slexpevalMacroF1();
         evalmethods{4}=slexpevalAUC();
    end
%      evalmethods{3}=slexpevalHammingloss();
%     evalmethods{4}=slexpevalMicroprecision();
%     evalmethods{5}=slexpevalMicrorecall();
%     evalmethods{5}=slexpevalMicroprecisionNeg();
%     evalmethods{6}=slexpevalMicrorecallNeg();
%     evalmethods{7}=slexpevalMicroF1Neg();
        
%    if (algo_id==7) 
%        cla=slexpclassifierMFM_uni();
%        expsetting=slexpSettingMVMT();
%        disp(['Running ====='  dataset.name '---' cla.name '-----']);
%        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
%        disp(result);
%        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
%        exp.classifier.lambda_ = para.para1;
%        exp.classifier.gamma1_ = para.para2;
%        exp.classifier.k_= para.k;
%        exp.classifier.iteration_=num_iter;
%        exp.classifier.loss_=loss_func;
%        exp=exp.run(para.IsCv);
%    end    
    %MKL
%     if (algo_id==3) 
%         cla=slexpclassifierLIBLINEAR();
%         expsetting=slexpSettingMVMT();
%         disp(['Running ====='  dataset.name '---' cla.name '-----']);
%         result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
%         disp(result);
%         exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
%         exp.classifier.para_c = para.c;
%         exp.classifier.para_g= para.g;
%         exp.classifier.num_iter=num_iter;
%         exp=exp.run(para.IsCv);
%     end
    
%     
%     %% LR removing MVM in MFM
   if (algo_id==1) 
        cla=slexpclassifierMFM_LR();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.gamma1_ = para.para1;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
   end
           
    if (algo_id==2) 
        cla=slexpclassifierLibFM();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.lambda_ = para.para1;
        exp.classifier.k_= para.k;        
        exp.classifier.method_ = para.method;        
%         if ~any(strcmp('method',fieldnames(para)))
%             exp.classifier.method_ = para.method;
%         end
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end
     %% TF
    if (algo_id==3) 
        cla=slexpclassifierMFM_TF();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.lambda_ = para.para1;
        exp.classifier.k_= para.k;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end 
    %% MVM
    if (algo_id==4) 
        cla=slexpclassifierMFM_MVM();
%        cla=slexpclassifierMVM();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.lambda_ = para.para1;
        exp.classifier.k_= para.k;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end
    %IteMM
    if (algo_id==5) 
        cla=slexpclassifierIteMM();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.a_ = 1;
        exp.classifier.c_= para.para1;
        exp.classifier.miu_ = para.para2;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end
    
    % CSL
    if (algo_id==6) 
        cla=slexpclassifierCSL();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.alpha_ = para.para1;
        exp.classifier.beta_= para.para1;
        exp.classifier.gamma_ = para.para2;
        exp.classifier.h_= para.k;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end

        %% RegMFM
    if (algo_id==7) 
        cla=slexpclassifierMFM();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.lambda_ = para.para1;
        exp.classifier.gamma1_ = para.para2;
        exp.classifier.regular_task = 'L2';
        exp.classifier.regular_view = 'L2';
        exp.classifier.regular_u = 'L21';
        exp.classifier.k_= para.k;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end

    if (algo_id==8)
        cla=slexpclassifierMFM();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name 'L21-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.lambda_ = para.para1;
        exp.classifier.gamma1_ = para.para2;
        exp.classifier.regular_task = 'L21';
        exp.classifier.regular_view = 'L21';
        exp.classifier.regular_u = 'L21';
        exp.classifier.k_= para.k;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end

    if (algo_id==9) 
        cla=slexpclassifierMFM();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name 'L2-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.lambda_ = para.para1;
        exp.classifier.gamma1_ = para.para2;
        exp.classifier.regular_task = 'L2';
        exp.classifier.regular_view = 'L2';
        exp.classifier.regular_u = 'L2';
        exp.classifier.k_= para.k;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end
    
    if (algo_id==11) 
        cla=slexpclassifierRMTFL();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.rho1_ = para.para1;
        exp.classifier.rho2_ = para.para2;
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end
    
    if (algo_id==12) 
        % single task based FM
        cla=slexpclassifierFM();
        expsetting=slexpSettingMVMT();
        disp(['Running ====='  dataset.name '---' cla.name '-----']);
        result=['result/' dataset.name '/' cla.name '-' data_id '.mat'];
        disp(result);
        exp=slexprofile(dataset,expsetting,cla,evalmethods,result);
        exp.classifier.lambda_ = para.para1;
        exp.classifier.k_= para.k;        
        exp.classifier.method_ = para.method;        
        exp.classifier.iteration_=num_iter;
        exp.classifier.loss_=loss_func;
        exp=exp.run(para.IsCv);
    end
    
    numEval = size(exp.expsetting.evaluations(:),1);
    exp_avg = zeros(numEval,1);
    exp_std = zeros(numEval,1);
    for i=1:numEval
        exp_avg(i) = mean(exp.expsetting.evaluations{i}.value);
        exp_std(i) = std(exp.expsetting.evaluations{i}.value);
    end;
end
