function L = Calculate_Lap(W)

D = diag(sum(W, 2).^(-0.5));
L = -D * W;
D = diag(sum(W, 1).^(-0.5));
L = L * D;