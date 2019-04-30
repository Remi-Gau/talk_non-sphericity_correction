%% generate a 2D gaussian with different covariance matrix to compare white and coloured noise

close all

% Define the parameters mu and sigma.
mu = [0 0];

sigma_err = [... coloured noise
    1 .4; ...
    .4 1];

% sigma_err = [... spherical / white noise
%     1 0; ...
%     0 1];

% Create a grid of evenly spaced points in two-dimensional space.
x1 = -3:0.2:3;
x2 = -3:0.2:3;
[X1,X2] = meshgrid(x1,x2);
X = [X1(:) X2(:)];

% Evaluate the pdf of the normal distribution at the grid points.
y = mvnpdf(X,mu,sigma_err);
y = reshape(y,length(x2),length(x1));

% Plot the pdf values.
surf(x1,x2,y)
caxis([min(y(:))-0.5*range(y(:)),max(y(:))])
axis([-3 3 -3 3 0 0.4])
xlabel('x1')
ylabel('x2')
zlabel('Probability Density')



%% generate white noise residuals to simuate a perfect GLM and see how ideal residuals should look like
% change Nb of time points to see how it affects the stability of the
% auto-correlation function

close all

nb_time_points = 100;
nb_voxels = 600;

random_noise = mvnrnd(zeros(1, nb_voxels), eye(nb_voxels), nb_time_points);

plot_residuals('white noise', random_noise)