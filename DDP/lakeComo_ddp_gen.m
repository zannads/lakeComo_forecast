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
discr_h = [-0.8:0.1:-0.4, -0.35:0.05:1.2, 1.3:0.1:3] ;
discr_s = LakeComo.level2storage( discr_h );    %using discr_s or discr_h is the same
n_s = length(discr_s);

%discr e (inflow)should not be needed as is deterministic

%discr u (release) u will be the history
V = LakeComo.max_release( discr_s );
v = LakeComo.min_release( discr_s, 1:n_t, 0 );
discr_u = unique( [V(:); v(:)] );
%now I may want to fill the gaps
discr_u = [discr_u; (27:5:161)'];
discr_u = sort( discr_u );
n_u = length( discr_u );
% get available release as func of t and s
R =min( repmat(V, n_t,1), max( v, reshape(discr_u, 1, 1, [] ) ));

%% OPTIMIZATION
weights = [1, 0,  0;
    0, 1, 0;
    0, 0, 1];
%n_j = size( weights, 1);

H = nan( n_s, n_t+1, N_obj);

% start optimization for each single objective
yy = 21;
Gbias = zeros(N_obj,1);
Gk = diag( [1/yy, 1/n_t, 1/yy] );
Gnorm = eye(N_obj);
tic;
G_ = [J{1}.evaluate( discr_h );
    zeros( 1, n_s);
    J{3}.evaluate( discr_h, myDOY(period(end)+1) )];
H( :, end, :) = (weights*Gnorm*(Gk*G_-Gbias))';
    
for k = 1:N_obj
    k
    for t = n_t:-1:+1
        for i = 1 : n_s
            % get release
            R_ = unique( R(t, i, :) )'; % I need it horizontal
            S_ = discr_s(i) + (e(t) - R_)*60*60*24; % same
            n_q = size( R_, 2);
            
            % compute G
            h_ = discr_h(i)*ones( 1, n_q );
            G_ = [J{1}.evaluate( h_ );
                J{2}.evaluate( R_, t, doy(t) );
                J{3}.evaluate( h_ , doy(t) ) ];
            G = weights(k, :)*Gnorm*(Gk*G_-Gbias);
            
            H_ = interp1( discr_s', H(:,t+1, k), S_ );
            
            % compute
            Q = G+H_;
            H( i,t, k) = min(Q);
            
        end
        
    end
end
toc
%Hred = H(:, 7301:end, :);

%% do simulation for the single objectives
s_init = LakeComo.level2storage(historical{ period(1), "h"});

sim_s = nan( n_t+1, N_obj);
sim_r = nan( n_t, N_obj);
sim_s(1, :) = s_init;

for k = 1:N_obj
    
    for t = 1:n_t
        
        % get release
        R_ = unique( LakeComo.actual_release( discr_u, sim_s(t,k), t, 0) )'; % I need it horizontal
        n_q = size( R_, 2);
        
        % compute G
        s_ = sim_s(t, k)*ones( 1, n_q );
        G_ = [J{1}.evaluate( LakeComo.storage2level( s_  ) );
              J{2}.evaluate( R_, t, doy(t) );
              J{3}.evaluate( LakeComo.storage2level( s_ ), doy(t) )];
        
        G = weights(k, :)*Gnorm*(Gk*G_-Gbias);
 
        S_ = sim_s(t,k) + (e(t) - R_)*60*60*24;
        
        H_ = interp1( discr_s', H(:,t+1, k), S_ );
        
        % compute
        Q = G+H_;
        [~, idx_u] = min(Q);
        
        sim_r(t, k) = R_(idx_u);
        sim_s(t+1, k) = S_(idx_u);
    end 
end

%% get normalization
JJJ = [J{1}.evaluate( LakeComo.storage2level(sim_s) );
    J{2}.evaluate( sim_r, t, doy(t) );
    J{3}.evaluate(  LakeComo.storage2level(sim_s) , doy(t) ) ];
JJJ = diag( [1/yy, 1, 1/yy] )* JJJ; % floodDays and static are defined as day/year

MJ = max( JJJ, [], 2 );
%Gnorm = diag(1./MJ);

[X, Y, Z] = meshgrid( (0:3)/4 );
X_ = X( X+Y+Z == 1 );
Y_ = Y( X+Y+Z == 1 );
Z_ = Z( X+Y+Z == 1 );
weights = [weights(1:3, :); [X_,Y_, Z_] ];

n_j = size( weights, 1 );

%% optimize for the new weights
H = cat(3, H, nan( n_s, n_t+1, n_j-N_obj) );

tic;
G_ = [J{1}.evaluate( discr_h );
    zeros( 1, n_s);
    J{3}.evaluate( discr_h, myDOY(period(end)+1) )];
H( :, end, N_obj+1:n_j) = (weights(N_obj+1:n_j, :)*Gnorm*(G_-Gbias))';
    
for k = N_obj+1:n_j
    k
    for t = n_t:-1:+1
        for i = 1 : n_s
            % get release
            R_ = unique( R(t, i, :) )'; % I need it horizontal
            S_ = discr_s(i) + (e(t) - R_)*60*60*24; % same
            n_q = size( R_, 2);
            
            % compute G
            h_ = discr_h(i)*ones( 1, n_q );
            G_ = [J{1}.evaluate( h_ );
                J{2}.evaluate( R_, t, doy(t) );
                J{3}.evaluate( h_ , doy(t) ) ];
            G = weights(k, :)*Gnorm*(Gk*G_-Gbias);
            
            H_ = interp1( discr_s', H(:,t+1, k), S_ );
            
            % compute
            Q = G+H_;
            H( i,t, k) = min(Q);
            
        end
        
    end
end
toc
%Hred = H(:, 7301:end, :);

%% do simulation for the single objectives
s_init = LakeComo.level2storage(historical{ period(1), "h"});

sim_s = [sim_s, nan( n_t+1, n_j-N_j)];
sim_r = [sim_r, nan( n_t, n_j-N_j)];
sim_s(1, :) = s_init;

for k = N_obj+1:n_j
    
    for t = 1:n_t
        
        % get release
        R_ = unique( LakeComo.actual_release( discr_u, sim_s(t,k), t, 0) )'; % I need it horizontal
        n_q = size( R_, 2);
        
        % compute G
        s_ = sim_s(t, k)*ones( 1, n_q );
        G_ = [J{1}.evaluate( LakeComo.storage2level( s_  ) );
              J{2}.evaluate( R_, t, doy(t) );
              J{3}.evaluate( LakeComo.storage2level( s_ ), doy(t) )];
        
        G = weights(k, :)*Gnorm*(Gk*G_-Gbias);
        
        S_ = sim_s(t,k) + (e(t) - R_)*60*60*24;
        
        H_ = interp1( discr_s', H(:,t+1, k), S_ );
        
        % compute
        Q = G+H_;
        [~, idx_u] = min(Q);
        
        sim_r(t, k) = R_(idx_u);
        sim_s(t+1, k) = S_(idx_u);
    end 
end

JJJ = [J{1}.evaluate( LakeComo.storage2level(sim_s) );
    J{2}.evaluate( sim_r, t, doy(t) );
    J{3}.evaluate(  LakeComo.storage2level(sim_s) , doy(t) ) ];
JJJ = diag( [1/yy, 1, 1/yy] )* JJJ; % floodDays and static are defined as day/year

scatter3( JJJ(1, :), JJJ(2, :), JJJ(3, :) );
text( JJJ(1, :), JJJ(2, :), JJJ(3, :), string(1:n_j)')
%%
% 
% figure;
% plot( sim_s );
% hold on;
% plot( LakeComo.level2storage( 1.1*ones(1, n_t) ) );
% plot( LakeComo.level2storage( -0.2*ones(1, n_t) ) );
% 
% figure;
% plot(sim_r);
% hold on;
% plot( e);
% plot( repmat( comoDemand, yy, 1));
% plot( mef )