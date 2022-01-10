period = (datetime(2006, 1, 1):datetime(2013, 12, 31))';
isLeapDay = period.Month==2 & period.Day== 29;
period( isLeapDay ) = [];
T = 365;
n_t = length(period);
doy = myDOY( period );
%load inflow
e = historical{period, "dis24"};

%% obj functions
% h flooding 1 value
h_flo = 1.24;
% dmv rain_weight H values
mef = 5*ones(n_t,1);
rw = zeros(n_t, 1);
% demand, s_low -365values
load( fullfile( raw_data_root, 'utils', 'comoDemand.txt' ), '-ascii' );
load( fullfile( raw_data_root, 'utils', 'static_low.txt' ), '-ascii' );


J = {floodDays( h_flo ), ...
    avgDeficitBeta( 'Demand', comoDemand, 'MEF', mef, 'RainWeight', rw), ...
    staticLow( static_low ) };
%clear h_flo comoDemand static_low
N_obj = length( J );

%% MODEL
LakeComo = lakeComo();
%surface
LakeComo = LakeComo.setSurface( 145900000);
%s0
s0 =LakeComo.level2storage(historical{ period(1), "h"}, 0 );
%MEF
LakeComo = LakeComo.setMEF( mef );

%discr s
discr_h = [-0.8:0.1:-0.4, -0.35:0.025:1.2, 1.3:0.1:3, 4, 5] ;
discr_s = LakeComo.level2storage( discr_h );    %using discr_s or discr_h is the same
n_s = length(discr_s);

%discr e (inflow)should not be needed as is deterministic

%discr u (release) u will be the history
V = LakeComo.max_release( discr_s, 1:n_t, 0 );
v = LakeComo.min_release( discr_s, 1:n_t, 0 );
discr_u = unique( [V(:); v(:)] );
%now I may want to fill the gaps
discr_u = [discr_u; (27:2.5:230)'];
discr_u = sort( discr_u );
n_u = length( discr_u );
% get available release as func of t and s
R =min( V, max( v, reshape(discr_u, 1, 1, [] ) ));

figure, plot( historical{ period, "h" } );
hold on
plot( [1, n_t], [discr_h', discr_h'] )

figure
plot( e )
hold on
plot( [1, n_t], [discr_u, discr_u] )