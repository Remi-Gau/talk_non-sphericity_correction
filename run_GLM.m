function [beta, Y_hat, residuals] = run_GLM(X, Y)
% runs GLM
% Y : the data, a matrix time courese (t time points X X p voxels)
% X : the design matrix (t time points X n regressors)
% beta : the matrix of beta values (n betas X p voxels)
% Y_hat : the predicted values, a matrix time courese (t time points X X p voxels)
% residuals : a matrix time courese residuals (t time points X X p voxels)

beta = inv(X'*X)*X' * Y;
Y_hat = X * beta;
residuals = Y - Y_hat;

end

