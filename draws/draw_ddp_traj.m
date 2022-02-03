n_t = size( sim_h, 1);
load( fullfile( raw_data_root, 'utils', 'comoDemand.txt' ), '-ascii' );

figure;
tiledlayout(2,1);
nexttile;
plot(period, sim_h, 'LineWidth', 1.5 );
hold on;
plot( 1.1*ones(1, n_t) , '--', 'Color', [0.8500 0.3250 0.0980] );
plot( -0.2*ones(1, n_t), '--', 'Color', [0.9290 0.6940 0.1250] );
plot( -0.4*ones(1, n_t), '--k', 'LineWidth', 0.25);
ylim( [-0.4, 3]);
ylabel( 'Lake level [m]', 'FontSize', 14);
xlabel( 'Time', 'FontSize', 14);

title( combination_title );

nexttile;
plot(period, sim_r, 'LineWidth', 1.5);
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

% hold on
% eps1 = 0.0002;
% plot3( JJJ(1, weights(:,3)==eps1), JJJ(3, weights(:,3)==eps1), JJJ(2, weights(:,3)==eps1), '.r' );
% plot3( JJJ(1, weights(:,2)==eps1), JJJ(3, weights(:,2)==eps1), JJJ(2, weights(:,2)==eps1), '.g' );
% plot3( JJJ(1, weights(:,1)==eps1), JJJ(3, weights(:,1)==eps1), JJJ(2, weights(:,1)==eps1), '.m' );

figure; 
p = parallelplot( JJJ' );
p.CoordinateTickLabels = ["FloodDays [day/year]", "Deficit [??]", "Static low [day/year]" ];
title( combination_title );