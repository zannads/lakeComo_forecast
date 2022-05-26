function outputArg = detCoeff( s, o )
%detCoeff Calculates all the parameters needed for the calculation of NSE
% and KGE scores.
%   d = detCoeff( s, o ) calculates all the parameters needed for the
%   calculation of NSE and KGE scores.
%   There is no check on the inputs. 
%   The first input s is a n x 1 array containg the simulation. 
%   The second input o is a n x 1 array containg the observation. 
% See also NSE and KGE.

% linear correlation coefficient
R = corrcoef( s, o );
r = R(2);
if abs(r) < 10^-3 || isnan(r)    %to avoid nan and small numerical errors
    r = 0;
end
outputArg.r = r; 
%the element off diagonal is the correlation coefficient between the two
%series, the elements in the diagonal are 1. 
sigma_s = std( s );
if abs(sigma_s) < 10^-3 || isnan(sigma_s)
    sigma_s = 0;
end
sigma_o = std( o );
mu_s = mean( s );
mu_o = mean( o );

%for KGE an NSE
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