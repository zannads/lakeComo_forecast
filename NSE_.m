function [nse, A, B, C, r, alpha, beta] = NSE_( s, o )
% NSE in its most extended form

% linear correlation coefficient
R = corrcoef( s, o );
r = R(2); 
%the element off diagonal is the correlation coefficient between the two
%series, the ones in the diagonal are 1. 
sigma_s = std( s );
sigma_o = std( o );
mu_s = mean( s );
mu_o = mean( o );

%by KGE
% strength of the linear relationship between the simulated and observed values
A = r^2;
% conditional bias
B = (r-sigma_s/sigma_o)^2;
% unconditional bias
C = ((mu_s-mu_o)/sigma_o)^2;
% relative variability in the simulated and observed values
alpha = sigma_s/sigma_o;
% bias normalized by the standard deviation in the observed values
beta = (mu_s-mu_o)/sigma_o;

nse = A-B-C;
end
