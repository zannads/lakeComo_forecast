n_t = size( sim_h, 1);
load( fullfile( raw_data_root, 'utils', 'comoDemand.txt' ), '-ascii' );
%selected_w = 1:n_j;
selected_w = 64;

figure;
tiledlayout(2,1);
nexttile;
plot(period, sim_h(:, selected_w), 'LineWidth', 1.5 );
hold on;
plot( 1.1*ones(1, n_t) , '--', 'Color', [0.8500 0.3250 0.0980] );
plot( -0.2*ones(1, n_t), '--', 'Color', [0.9290 0.6940 0.1250] );
plot( -0.4*ones(1, n_t), '--k', 'LineWidth', 0.25);
ylim( [-0.4, 3]);
ylabel( 'Lake level [m]', 'FontSize', 14);
xlabel( 'Time', 'FontSize', 14);

title( combination_title );

nexttile;
plot(period, sim_r(:, selected_w), 'LineWidth', 1.5);
hold on;
%plot( e);
plot( repmat( comoDemand, 20, 1), '--', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 0.75 );
plot( LakeComo.getMEF,  '--', 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 0.75 )
ylim( [0, 1000]);
ylabel( 'Release [m^3/s]', 'FontSize', 14);
xlabel( 'Time', 'FontSize', 14);

figure;
plot3( JJJ(1, :), JJJ(2, :), JJJ(3, :), '.b', 'MarkerSize', 10 );
hold on 
plot3( JJJ_hist(1), JJJ_hist(2), JJJ_hist(3), '*r', 'MarkerSize', 10);
xlabel( 'FloodDays [day/year]', 'FontSize', 14 );
ylabel( 'Deficit [??]',  'FontSize', 14 );
zlabel( 'Static low [day/year]', 'FontSize', 14);
grid on;
title( combination_title );
if length( selected_w ) == 1
    plot3( JJJ(1, selected_w), JJJ(2, selected_w), JJJ(3, selected_w), '.g', 'MarkerSize', 12 );
end

figure; 
p = parallelplot( JJJ' );
p.CoordinateTickLabels = ["FloodDays [day/year]", "Deficit [??]", "Static low [day/year]" ];
title( combination_title );
%%
%weight_selector( JJJ, [4.45; 689.194; 10.85] )
speed_constraint_check( sim_r, sim_h)

function o = weight_selector( J, value )
    o = sum( (J-value).^2, 1);
    [~, o] = min( o );
end

function outp = speed_constraint_check( r, h )
    outp = sum( ( (r(2:end, :)-r(1:end-1,:))>240 & h(1:end-1,:)<0.8 ) | ( (r(2:end,:)-r(1:end-1,:))>360 & h(1:end-1,:)>=0.8 & h(1:end-1,:)<=1.1), 1 );
end