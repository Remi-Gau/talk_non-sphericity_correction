function [t_A1L, p_A1L, df, dferror, std_error] = stats_GLM(X, beta, residuals)
% computes some stats for a given GLM
% The t and p values are always computed for the first regressor of the
% design matrix.
%
% X : the design matrix (t time points X n regressors)
% beta : the matrix of beta values (n betas X p voxels)
% residuals : a matrix time courese residuals (t time points X X p voxels)

% contrast for the first regressor
c = [1 ; zeros(size(X,2)-1,1)];

% degrees of freedom
df       = rank(X)-1; 
dferror  = size(X,1) - df - 1;

std_error  = sqrt( sum( (residuals-mean(residuals) ).^2 ) / ( length(residuals)-1) );

t_A1L = c'* beta / sqrt( std_error^2 * c' * inv(X'*X) * c);

p_A1L = tcdf(-t_A1L, dferror);

end

