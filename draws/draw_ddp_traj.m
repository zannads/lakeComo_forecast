ref_w = cat(1, ddpsol.flag_ref) >0;
sel_w = 15;

sim_h = cat(2, ddpsol.sim_h);
sim_r = cat(2, ddpsol.sim_r);
JJJ = cat(1, ddpsol.J);
n_t = size( sim_h, 1);
load( fullfile( raw_data_root, 'utils', 'aggregated_demand.txt' ), '-ascii' );
%% all reference sol
figure;
tiledlayout(2,1);
nexttile;
plot([period;period(end)+1], sim_h(:, ref_w), 'LineWidth', 1.5 );
hold on;
plot( 1.1*ones(1, n_t) , '--', 'Color', [0.8500 0.3250 0.0980] );
plot( -0.2*ones(1, n_t), '--', 'Color', [0.9290 0.6940 0.1250] );
plot( -0.4*ones(1, n_t), '--k', 'LineWidth', 0.25);
ylim( [-0.4, 3]);
ylabel( 'Lake level [m]', 'FontSize', 14);
xlabel( 'Time', 'FontSize', 14);

title( "Reference set DDP - level - release trajectories" );

nexttile;
plot([period;period(end)+1], [sim_r(:, ref_w);nan(1,sum(ref_w))], 'LineWidth', 1.5);
hold on;
%plot( e);
plot( repmat( aggregated_demand, 20, 1), '--', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 0.75 );
plot( LakeComo.getMEF,  '--', 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 0.75 )
ylim( [0, 1000]);
ylabel( 'Release [m^3/s]', 'FontSize', 14);
xlabel( 'Time', 'FontSize', 14);

%% sel_w solution
if ~isempty(sel_w)
    figure;
    tiledlayout(2,1);
    nexttile;
    plot([period;period(end)+1], sim_h(:, sel_w), 'LineWidth', 1.5 );
    hold on;
    plot( 1.1*ones(1, n_t) , '--', 'Color', [0.8500 0.3250 0.0980] );
    plot( -0.2*ones(1, n_t), '--', 'Color', [0.9290 0.6940 0.1250] );
    plot( -0.4*ones(1, n_t), '--k', 'LineWidth', 0.25);
    ylim( [-0.4, 3]);
    ylabel( 'Lake level [m]', 'FontSize', 14);
    xlabel( 'Time', 'FontSize', 14);
    
    title( "Selected solution - level - release trajectories" );
    
    nexttile;
    plot([period;period(end)+1], [sim_r(:, sel_w);nan], 'LineWidth', 1.5);
    hold on;
    %plot( e);
    plot( repmat( aggregated_demand, 20, 1), '--', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 0.75 );
    plot( LakeComo.getMEF,  '--', 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 0.75 )
    ylim( [0, 1000]);
    ylabel( 'Release [m^3/s]', 'FontSize', 14);
    xlabel( 'Time', 'FontSize', 14);
end

%% 3d pareto 
figure;
plot3( JJJ(ref_w,1), JJJ(ref_w,2), JJJ(ref_w,3), '.', 'MarkerSize', 14 );
hold on
xlabel( 'FloodDays [day/year]', 'FontSize', 14 );
ylabel( 'Deficit [m^3/s^{eq}]',  'FontSize', 14 );
zlabel( 'Static low [day/year]', 'FontSize', 14);
grid on;
title( "Pareto reference set DDP" );
if ~isempty(sel_w)
    plot3( JJJ(sel_w,1), JJJ(sel_w,2), JJJ(sel_w,3), '.r', 'MarkerSize', 18 );
end

%% pareto parallel plot
bins = (min(JJJ(ref_w,2))-5):10:(max(JJJ(ref_w,2))+5);
figure;
p = parallelplot( JJJ(ref_w, :) );
p.CoordinateTickLabels = ["FloodDays [day/year]", "Deficit [m^3/s^{eq}]", "Static low [day/year]" ];
p.Jitter = 0;
title( "Pareto reference set DDP" );
legend( 'off' );
if ~isempty(sel_w)
    m = (1:sum(ref_w))' == ddpsol(sel_w).flag_ref;
    p.GroupData = m;
    if m(1) > 0
        p.LineWidth = [6,1];
        p.Color = [0.8500,0.3250,0.0980;0,0.4470,0.7410];
    else
        p.LineWidth = [1,6];
        p.Color = [0,0.4470,0.7410;0.8500,0.3250,0.0980];
    end
else
    p.GroupData = discretize(JJJ(ref_w,2), bins);
end
clear bins sim_h sim_r JJJ n_j n_t
%%
%weight_selector( JJJ, [4.45, 1082.07, 9.85] ) %->86
%weight_selector( JJJ, [4.45, 1128.62, 0.9] ) %->127
%weight_selector( JJJ, [4.45, 1078.38, 21.89] ) %->15

function o = weight_selector( J, value )
    o = sum( (J-value).^2, 2);
    [~, o] = min( o );
end