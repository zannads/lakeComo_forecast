%% OPTIMIZATION
disp('optimization');

tic;
H = nan( n_t+1, n_j, n_s);
%single objective: 1 x n_s
% compos obj G_ :  3 x n_s
G_ = [J{1}.evaluate( discr_h );
    zeros( 1, n_s);
    J{3}.evaluate( discr_h, myDOY(period(end)+1) )];
% 1 x n_j x n_s = n_j x 3 x 3 x n_s
H( end, :, :) = weights*Gnorm*(Gk*G_-Gbias);

for t = n_t:-1:+1
    
    % get release
    % 1 x n_s x n_u
    R_ = R(t, :, :);
    % 1 x n_s + ( 1 - 1 x n_s x n_u ) = 1 x n_s x n_u
    S_ = discr_s + (e(t) - R_)*60*60*24;
    
    % compute G
    % 3 x n_s x n_u
    G_ = [repmat( J{1}.evaluate( discr_h ), 1,1, n_u );
        J{2}.evaluate( R_, t, doy(t) );
        repmat( J{3}.evaluate( discr_h , doy(t) ), 1,1, n_u) ];
    
    % I should do
    %G = weights*Gnorm*(Gk*G_-Gbias);
    % n_j x 3 x 3 x n_s x n_u = n_j x n_s x n_u
    % but they are multi dim array
    G = pagemtimes( weights*Gnorm*Gk, G_ ) - weights*Gnorm*Gbias;
    
    % n_j x n_s
    H_t1 = squeeze(H(t+1, :, :));
    %{
     first element must be the discretization array
    first dim of H_t1 must match discr_s lenght
    discr_s' : n_s x 1
   H_t1' : n_s x n_j
    dimension of output is like dimension of the 3 element plus eventual
    additional dimensions of the second element
    squeeze(S_) : n_s x n_u
    H_ : n_s x n_u x n_j
    %}
    H_ = interp1( discr_s', H_t1', squeeze(S_ ), 'linear', inf);
    % reoder to match G
    % n_j x n_s x n_u
    H_ = permute( H_, [3, 1, 2] );
    
    % compute
    % Q : n_j x n_s x n_u
    Q = G+H_;
    % min wrt n_u -> n_j x n_s
    H( t, :, :) = min(Q, [], 3);
end
toc

%% do simulation for the single objectives
disp('simulation');
s_init = LakeComo.level2storage(historical{ period(1), "h"});

sim_s = nan( n_t+1, n_j);
sim_r = nan( n_t, n_j);
sim_s(1, :) = s_init;
tic
for t = 1:n_t
    
    % get release
    % R_ : 1 x n_j x n_u
    R_ = LakeComo.actual_release( discr_u, sim_s(t,:), t, 0);
    % S_ : 1 x n_j x n_u
    S_ = sim_s(t, :) + (e(t) - R_)*60*60*24;
    
    % compute G
    % now the cost to be in the state is zero, because it has already been
    % accounted at step t-1. At the beginning it is given and you can't do
    % anything about it. you can't penalize st. cond.
    % G_ : 3 x n_j x n_u
    G_ = [zeros(1, n_j, n_u);
        J{2}.evaluate( R_, t, doy(t) );
        zeros(1, n_j, n_u)];
    % G = n_j x 3 x 3 x n_j(n_s) x n_u -> n_j(weights) x n_j(state) x n_u
    G = pagemtimes( weights*Gnorm*Gk, G_ ) - weights*Gnorm*Gbias;
    %{
we have a n_j x n_j when in optimization was n_j x n_s, simply now the
number of states is equal of the number of combination because we don't
need to discretize the state. so are the element in the diagonal that
counts - > n_j row i is combination of weight that corresponds to n_j col i
    %}
    
    % H_t1 : (comb of weight) n_j x n_s
    H_t1 = squeeze(H(t+1, :, :));
    % H_ : [size(S_), n_j] : n_j(state) x n_u x n_j(weights)
    H_ = interp1( discr_s', H_t1', squeeze(S_), 'linear', inf );
    % H_ : n_j(weights) x n_j (state) x n_u
    H_ = permute( H_, [3, 1, 2] );
    
    % compute
    % Q : n_j(weights) x n_j (state) x n_u
    Q = G+H_;
    % min wrt u -> idx_u : n_j(weights) x n_j (state)
    % extract index to select from R_ and S_
    [~, idx_u] = min(Q, [], 3);
    % should select only element in the diag
    
    %this is the c way to do it: Elapsed time:87.45
    for k = 1:n_j
        sim_r(t, k) = R_(1, k, idx_u(k, k) );
        sim_s(t+1, k) = S_(1, k, idx_u(k, k) );
    end
    % this is the matlab wat to do it: ELapsed time: 89.0
    %{
    % idx_u : n_j x 1, the value is the index of R_ or S_ to select
    %idx_u = diag(idx_u);
    % R_/S_ : 1 x n_j x n_j
    R_ = R_(1, :, idx_u );
    S_ = S_(1, :, idx_u );
    % R_/S_ : n_j x 1
    R_ = diag( squeeze( R_ ) );
    S_ = diag( squeeze( S_ ) );
    sim_r(t, :) = R_';
    sim_s(t+1, :) = S_';
    %}
end
sim_s = sim_s(1:n_t, :);
sim_h = LakeComo.storage2level(sim_s);
clear t k G_ G Q H_t1 H_ R_ S_ idx_u

JJJ = [J{1}.evaluate( sim_h );
    J{2}.evaluate( sim_r, 1:n_t, doy );
    J{3}.evaluate( sim_h, doy ) ];
JJJ = diag( [1/yy, 1, 1/yy] )* JJJ; % floodDays and static are defined as day/year
toc
JJJ_hist = [J{1}.evaluate( historical{period, "h"} );
    J{2}.evaluate( historical{period, "r"} , 1:n_t, doy );
    J{3}.evaluate( historical{period, "h"} , doy ) ];
JJJ_hist = diag( [1/yy, 1, 1/yy] )* JJJ_hist;