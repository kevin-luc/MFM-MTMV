function [F1,err] = classify_error(Label, Predict)
% assumes Label is n x 1 in {True,False}

n = size(Label, 1);
assert(size(Label, 2) == 1);

%err = sum(min(abs(Label-Predict),1))/n;
tp=sum(and(Label,Predict));
precision=tp/(sum(Predict)+1e-6);
recall=tp/(sum(Label)+1e-6);
F1=2*precision*recall/(precision+recall+1e-6);
tn = sum(and(~Label,~Predict));
err = 1 - (tp + tn)/n;
end
