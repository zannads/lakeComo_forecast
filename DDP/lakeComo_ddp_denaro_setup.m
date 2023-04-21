period = (datetime(2006, 1, 1):datetime(2013, 12, 31))';
%{ selection of leapday-non leap day }%
leapDayActive = false;
if leapDayActive
    % LEAP DAY
    T = 365.25;
else
    % NO LEAP DAY
    T = 365; %#ok<*UNRCH>
    period( period.Month == 2 & period.Day == 29 ) = [];
    end
n_t = length(period);
doy = myDOY( period );
%load inflow
e = historical{period, "dis24"};
clear leapDayActive
%% obj functions
% h flooding 1 value
h_flo = 1.24;
% dmv rain_weight H values
mef = 5*ones(n_t,1);
rw = zeros(n_t, 1); %always squared
% demand, s_low -365values
load( fullfile( data_folder, 'LakeComoRawData', 'utils', 'comoDemand.txt' ), '-ascii' );
load( fullfile( data_folder, 'LakeComoRawData', 'utils', 'static_low.txt' ), '-ascii' );


J = {floodDays( h_flo ), ...
    avgDeficitBeta( 'Demand', comoDemand, 'MEF', mef, 'RainWeight', rw), ...
    staticLow( static_low ) };
clear h_flo comoDemand static_low
N_obj = length( J );

%% MODEL
LakeComo = lakeComo();
%surface
LakeComo = LakeComo.setSurface( 145900000 );
%MEF
LakeComo = LakeComo.setMEF( mef );
clear mef

%discr s
eps1 = 0.01;
eps2 = 0.025;
discr_h = [-0.8:0.1:-0.4, -0.4+eps1:eps1:1.2, 1.2+eps2:eps2:2.2, 2.5:0.5:5] ;
discr_s = LakeComo.level2storage( discr_h, 0 );    %using discr_s or discr_h is the same
n_s = length(discr_s);
clear eps1 eps2

%discr e (inflow)should not be needed as is deterministic

%discr u (release) e will be the history
V = LakeComo.max_release( discr_s, 1:n_t, 0 );
v = LakeComo.min_release( discr_s, 1:n_t, 0 );
discr_u = unique( [V(:); v(:)] );
clear V v
%now I may want to fill the gaps in the most relevant part: 5-230 is
%between MEF and max(comoDemand)
eps1 = .1;
discr_u = [discr_u; (5+eps1:eps1:LakeComo.max_release(LakeComo.level2storage(1.24,0), 1, 0) )'];
discr_u = sort( discr_u );
n_u = length( discr_u );
clear eps1
%% WEIGHTS and normalization
N = 20;
[X, Y] = meshgrid( (0:N)/(N) );
X_ = X( X+Y == 1 );
Y_ = Y( X+Y == 1 );
eps1 = 0.0001;
% Y_(X_==0) = Y_(X_==0)-eps1;
% X_(X_==0) = eps1;
X_(Y_==0) = X_(Y_==0)-eps1;
Y_(Y_==0) = eps1;
weights = [X_,Y_, zeros(size(X_))] ;
n_j = size( weights, 1 );
clear X Y X_ Y_ N eps1

%this is the multiplier for the output of the objectives
yy = n_t/T;
Gk = diag( [1/yy, 1/n_t, 1/yy] );

% normalization parameters
Gbias = zeros(N_obj,1);
Gnorm = diag( [1, 1, 1] );

%% plots to see the discretization
plot_on = false;
if plot_on
    figure, plot( historical{ period, "h" } );
    hold on
    plot( [1, n_t], [discr_h', discr_h'] )
    
    figure
    plot( e )
    hold on
    plot( [1, n_t], [discr_u, discr_u] )
end
clear plot_on