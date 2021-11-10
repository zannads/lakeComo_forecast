function outputArg = detCoeff( s, o )
% params extraction in its most extended form

% linear correlation coefficient
R = corrcoef( s, o );
outputArg.r = R(2); 
%the element off diagonal is the correlation coefficient between the two
%series, the ones in the diagonal are 1. 
sigma_s = std( s );
sigma_o = std( o );
mu_s = mean( s );
mu_o = mean( o );

%by KGE
% strength of the linear relationship between the simulated and observed values
outputArg.A = r^2;
% conditional bias
outputArg.B = (r-sigma_s/sigma_o)^2;
% unconditional bias
outputArg.C = ((mu_s-mu_o)/sigma_o)^2;
% relative variability in the simulated and observed values
outputArg.alpha = sigma_s/sigma_o;
% bias normalized by the standard deviation in the observed values
outputArg.beta_n = (mu_s-mu_o)/sigma_o;
% ratio between the mean simulated and mean observed flows, i.e. bias
outputArg.beta = mu_s/ mu_o;
%variability ratio (dimensionless)
outputArg.gamma = (sigma_s/mu_s)/(sigma_o/mu_o);
end