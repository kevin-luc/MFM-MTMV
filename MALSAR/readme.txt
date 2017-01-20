MALSAR package Version 1.1 (Dec. 18, 2012)

The Multi-tAsk Learning via StructurAl Regularization (MALSAR) package 
has covered most of the popular topics such as the regularized multi-task 
learning, sparse multi-task learning, clustered multi-task learning, 
and multi-task learning via common feature mapping.

The folder "MALSAR" contains all the functions implemented in this package

The folder "Examples" provides the examples for the major functions implemented in this package.

If any problem, please contact Jiayu Zhou and Jieping Ye via {jiayu.zhou,jieping.ye}@asu.edu.


Patch Notes:
May 1. 
1) Added INSTALL.m file to the package. 
2) fix some bugs in compilation on Unix machines. 
3) Replace the Mosek solver by a native Matlab solver.
The package no longer requires Mosek. 

Dec. 18.
1) Improved algorithm performance.
2) Added disease progression models.
3) Added the incomplete multi-source fusion (iMSF) models.
4) Added the multi-stage multi-task feature learning.
5) Added the learning shared subspace for multi-task clustering (LSSMTC) algorithm.
6) Added an example to illustrate training, testing and model selection in multi-task learning.