period = (datetime(1999, 1, 1):datetime(2019, 12, 31))';
isLeapDay = period.Month==2 & period.Day== 29;
period( isLeapDay ) = [];
n_t = length(period);
doy = myDOY( period );
%load inflow
e = historical{period, "dis24"};

%% obj functions
% h flooding 1 value
h_flo = 1.10;
% dmv rain_weight H values
load( fullfile( raw_data_root, 'utils', 'DMV_99_19_noLD.txt' ), '-ascii' );
mef = DMV_99_19_noLD;
clear DMV_99_19_noLD
load( fullfile( raw_data_root, 'utils', 'rain_weight_99_19_noLD.txt' ), '-ascii' );
rw = rain_weight_99_19_noLD;
clear rain_weight_99_19_noLD
% demand, s_low -365values
load( fullfile( raw_data_root, 'utils', 'comoDemand.txt' ), '-ascii' );
load( fullfile( raw_data_root, 'utils', 'static_low.txt' ), '-ascii' );


J = {floodDays( h_flo ), ...
    avgDeficitBeta( 'Demand', comoDemand, 'MEF', mef, 'RainWeight', rw), ...
    staticLow( static_low ) };
clear h_flo comoDemand static_low
N_j = length( J );

%% MODEL
LakeComo = lakeComo();
%surface
LakeComo = LakeComo.setSurface( 145900000);
%s0
s0 =LakeComo.level2storage(historical{ period(1), "h"}, 0 );
%MEF
LakeComo = LakeComo.setMEF( mef );

%discr s
discr_h = [-0.8:0.1:-0.4, -0.35:0.05:1.2, 1.3:0.1:1.8] ;
discr_s = LakeComo.level2storage( discr_h );    %using discr_s or discr_h is the same 
n_s = length(discr_s);

%discr e (inflow)should not be needed as is deterministic

%discr u (release) u will be the history
V = LakeComo.max_release( discr_s );
v = LakeComo.min_release( discr_s, 1:n_t, 0 );
discr_u = unique( [V(:); v(:)] );
clear V v
%now I may want to fill the gaps
discr_u = [discr_u; (27:5:161)'];
discr_u = sort( discr_u );
n_u = length( discr_u );
%% OPTIMIZATION
weights_b = [1, 0,  0;
           0, 1, 0;
           0, 0, 1];
n_j = size( weights_b, 1);

H = nan( n_s, n_t+1, n_j);

%% start optimization for each weight.
yy = 1;
n_t_end = 365*yy; % just 2019
weights = weights_b* diag( yy./[1, 365, 1] );
tic;
for k = 1:n_j
    k
    H( :, end, k) = (weights(k, :)*vertcat( J{1}.evaluate( discr_h ), ...
        zeros( 1, n_s), ...
        J{3}.evaluate( discr_h, myDOY(period(end)+1 )) ) )';
    
    for t = n_t:-1:n_t-n_t_end+1
        for i = 1 : n_s
            % get release
            S_ = nan( n_u, 1 );
            R_ = nan( n_u, 1 );
            for j = 1:n_u
                [S_(j), R_(j)] = LakeComo.integration( 1, [], discr_s(i), discr_u(j), e(t), t, 0, 0);
            end
            
            % compute G
            h_ = discr_h(i)*ones( 1, n_u );
            G = (weights(k, :)*vertcat( J{1}.evaluate( h_ ), ...
                J{2}.evaluate( R_', t, doy(t) ), ...
                J{3}.evaluate( h_ , doy(t) ) ) )';
          
            H_ = interp1( discr_s', H(:,t+1, k), S_ );
            
            % compute
            Q = G+H_;
            H( i,t, k) = min(Q);
            
        end
        
    end
end
toc
Hred = H(:, 7301:end, :);

clear G Q H_ S_ h_ R k t i tt
%% SIMULATION
% do simulation
t = n_t-n_t_end;
q_t = n_t-n_t_end-1;
s_init = LakeComo.level2storage(historical{ period(t), "h"});

sim_s = nan( n_t_end+2, 3);
sim_r = nan( n_t_end+1, 3);
sim_s(1, :) = s_init;
%%
for k = 1:3

for t = 1:n_t_end
% get release
R = LakeComo.actual_release( discr_u, sim_s(t, k), t+q_t, 0);

% compute G
s_ = sim_s(t, k)*ones( size( discr_u ) )';
G = (weights(k, :)*vertcat( J{1}.evaluate( LakeComo.storage2level( s_  ) ), ...
    J{2}.evaluate( R', t, doy(t) ), ...
    J{3}.evaluate( LakeComo.storage2level( s_ ), doy(t) ) ) )';

S_ = nan( size( G ) );
for j = 1:n_u
    [S_(j), RR(j)] = LakeComo.integration( 1, [], sim_s(t, k), R(j), e(t+q_t), period(t+q_t), 0, 0);
end
H_ = interp1( discr_s', Hred(:,t, k), S_ );


% compute
Q = G+H_;
[~, idx_u] = min(Q);

sim_r(t, k) = R(idx_u);
sim_s(t+1, k) = S_(idx_u);
end


end

clear G Q H_ S_ s_ R k t i tt idx_u RR