fullPeriod = (datetime(1999, 1, 1):datetime(2019, 12, 31))';
period = (datetime(1999, 1, 1):datetime(2018, 12, 31))';
%{ selection of leapday-non leap day }%
leapDayActive = true;
if leapDayActive
    % LEAP DAY
    T = 365.25;
else
    % NO LEAP DAY
    T = 365; %#ok<*UNRCH>
    period( period.Month == 2 & period.Day == 29 ) = [];
    fullPeriod( fullPeriod.Month == 2 & fullPeriod.Day == 29 ) = [];
end
n_t = length(period);
doy = myDOY( period );
%load inflow
e = historical{period, "dis24"};
clear leapDayActive
%% obj functions
% h flooding 1 value
h_flo = 1.1;
% dmv rain_weight n_t values
% mef = 22*ones(n_t,1);
% mef = min( mef, e);     % italian legislation defines mef as minimum between the value and the availabilityy, that in this case is the measured inflow
% or 
load( fullfile( raw_data_root, 'utils', 'DMV_99_19_LD_it.txt' ), '-ascii' );
DMV_99_19_LD_it = timetable( (datetime(1999, 1, 1):datetime(2019, 12, 31))', DMV_99_19_LD_it );
mef = DMV_99_19_LD_it{period, "DMV_99_19_LD_it"};
clear DMV_99_19_LD_it;

% rw will be used as deficit^(2-rw)
rw = ones(n_t,1);           %abs value during the year: deficit^(2-1)
rw( doy>91 & doy<=283 ) = 0;%squared during summer:     deficit^(2-0)
% rw = rw-1;
% or 
% load( fullfile( raw_data_root, 'utils', 'rain_weight_99_19_LD.txt' ), '-ascii' );
% rain_weight_99_19_LD = timetable( (datetime(1999, 1, 1):datetime(2019, 12, 31))', rain_weight_99_19_LD );
% rw = rain_weight_99_19_LD{period, "rain_weight_99_19_LD"};
% clear rain_weight_99_19_LD;

% demand, s_low -365values
load( fullfile( raw_data_root, 'utils', 'comoDemand.txt' ), '-ascii' );
load( fullfile( raw_data_root, 'utils', 'static_low.txt' ), '-ascii' );


J = {floodDays( h_flo ), ...
    avgDeficitBeta( 'Demand', comoDemand, 'MEF', mef, 'RainWeight', rw), ...
    staticLow( static_low ) };
%clear h_flo comoDemand static_low rw 
N_obj = length( J );

%% MODEL
LakeComo = lakeComo();
%surface
LakeComo = LakeComo.setSurface( 145900000);
%MEF
LakeComo = LakeComo.setMEF( mef );
%clear mef

%discr s
eps1 = 0.01;
eps2 = 0.05;
discr_h = [-0.8:0.1:-0.4, -0.4+eps1:eps1:1.2, 1.2+eps2:eps2:2.2, 2.5:0.5:5] ;
discr_s = LakeComo.level2storage( discr_h );    %using discr_s or discr_h is the same
n_s = length(discr_s);
clear eps1 eps2

%discr e (inflow)should not be needed as is deterministic

%discr u (release) e will be the history
V = LakeComo.max_release( discr_s, 1:n_t, 0 );
v = LakeComo.min_release( discr_s, 1:n_t, 0 );
discr_u = unique( [V(:); v(:)] );
clear V v
%now I may want to fill the gaps in the most relevant part: 22-230 is
%between MEF and max(comoDemand)
eps1 = .5;
discr_u = [discr_u; (0+eps1:eps1:230)'];
discr_u = sort( discr_u );
n_u = length( discr_u );
clear eps1
% get available release as func of t and s and e
% R : n_t x n_s x n_u
%R = LakeComo.actual_release( discr_u, discr_s, 1:n_t, 0);
%{ 
make R unique, since for some value of discr_s, we can have only 1 value,
(for example below h = -0.4 the only possible value is 0) 
it doesn't make sense to have that value n_u times in 3 dim. If I replace
the multiples with NaN speed will increase.
%}
% tic
% rem = 0;
% for idx = 1:n_t
%     for jdx = 1:n_s
%         [RR, ia, ic] = unique( R(idx, jdx, :) );
%         rem = rem + n_u - length(RR);
%         
%         for mdx = 1:length(ia)
%             ic( discr_u == R(idx,jdx,ia(mdx)) ) = 0;
%         end
%         R(idx, jdx, ic>0 ) = nan;
%     end
% end
% toc
% fprintf( "Reduce of %d points. [%3.1f %%]\n", rem, rem/(n_s.*n_u.*n_t)*10 ) ;
% clear idx jdx ia ic RR rem mdx 

%% WEIGHTS and normalization
N = 15;
[X, Y, Z] = meshgrid( (0:N)/(N) );
X_ = X( X+Y+Z == 1 );
Y_ = Y( X+Y+Z == 1 );
Z_ = Z( X+Y+Z == 1 );
weights = [X_,Y_, Z_] ;
n_j = size( weights, 1 );
clear X Y Z X_ Y_ Z_ N
% I don't want them set to exactly 0
zer = sum( weights==0, 2);
eps1 = 0.0001;
for idx = 1:n_j
    if zer(idx) > 0
        weights(idx, weights(idx,:)>0 ) = weights(idx, weights(idx,:)>0 )-eps1*zer(idx);
        weights(idx, weights(idx,:)==0) = (3-zer(idx))*eps1;
    end
end
clear zer eps1 idx

%this is the multiplier for the output of the objectives:
% flood days(static low) is(are) defined as day/year so I divide by the
% number of years.
% average deficit beta is a daily average, so I divide by the number of
% days
yy = n_t/T;
Gk = diag( [1/yy, 1/n_t, 1/yy] );

% normalization parameters to have the cost function to match their orderd
% of magnitude.
% an intrinsic normalization is provided by the fact that in Gk the 1st and
% 3rd objective are multiplied by the inverse of the number of years. While
% the 2nd by the number of days, thus there is already a ratio of 1:365.
Gbias = zeros(N_obj,1);
Gnorm = diag( [1, 1, 1] );

%%
% plots to see the discretization
plot_on = false;
if plot_on
    figure, plot( historical{ fullPeriod, "h" } );
    hold on
    plot( [1, n_t], [discr_h', discr_h'] )
    
    figure
    plot( e )
    hold on
    plot( [1, n_t], [discr_u, discr_u] )
end