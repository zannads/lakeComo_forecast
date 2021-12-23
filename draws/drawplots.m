%DRAW PLOTS 
figure; 
colororder( [[0,0,0];colors.det; colors.ave; colors.cic;] );
tiledlayout(3, 1);
nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2);
hold on;
plot(detForecast.Time+1, detForecast.Lead1, 'LineWidth', 2 );
plot(averageDetForecast.Time, averageDetForecast.agg_1d, '--', 'LineWidth', 0.75  );
plot(cicloDetForecast.Time, cicloDetForecast.agg_1d, 'LineWidth', 0.75  );
xlim( [datetime(2015,1,1), datetime(2015, 12, 31) ]);
ylim( [0, 1060]);
xlabel('Time');
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', 14)
title( "Lead1", 'FontSize', 14 );

nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2);
hold on;
plot(detForecast.Time+2, detForecast.Lead2, 'LineWidth', 2);
plot(averageDetForecast.Time, averageDetForecast.agg_1d, '--', 'LineWidth', 0.75 );
plot(cicloDetForecast.Time, cicloDetForecast.agg_1d, 'LineWidth', 0.75);
xlim( [datetime(2015,1,1), datetime(2015, 12, 31) ]);
ylim( [0, 1060]);
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', 14)
title( "Lead2", 'FontSize', 14 );

nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2 );
hold on;
plot(detForecast.Time+3, detForecast.Lead3, 'LineWidth', 2  );
plot(averageDetForecast.Time, averageDetForecast.agg_1d, '--', 'LineWidth', 0.75  );
plot(cicloDetForecast.Time, cicloDetForecast.agg_1d, 'LineWidth', 0.75  );
xlim( [datetime(2015,1,1), datetime(2015, 12, 31) ]);
ylim( [0, 1060]);
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', 14)
title( "Lead3", 'FontSize', 14 );

%% det KGE
figure;
colororder( [[1,0,0];colors.det; colors.ave; colors.cic; colors.con] )
plot( 1:3, [1,1,1], '-');
hold on;
for idx = 1:size( detFScores.kge, 3)
    plot( 1:3, detFScores.kge(1, 1:3, idx), 'LineWidth', 2);
end
title( 'KGE', 'FontSize', 18 );
xlabel( 'Lead time', 'FontSize', 14 );
ylabel( 'KGE', 'FontSize', 14 );
xticks( [1,2,3] )
ylim( [-0.5, 1.05])
grid on
%legend( 'PROGEA', 'average', 'ciclo', 'consistency' );

figure;
plot3( 1, 1, 1, '*', 'Color', colors.lim);
title( 'KGE decomposition', 'FontSize', 18 );
grid on;
hold on;
% 3red lines
plot3( [1,0] , [1,1], [1,1], '-', 'Color', colors.lim );
plot3( [1,1] , [1,0], [1,1], '-', 'Color', colors.lim);
plot3( [1,1] , [1,1], [0.9,1.2], '-', 'Color', colors.lim );
symbol = 'o*s';
color_ord = [colors.det; colors.ave; colors.cic; colors.con];
for idx = 1:size( detFScores.kge, 3)
    for jdx = 1:3
        plot3(detFScores.r(1, jdx, idx), detFScores.alpha(1, jdx, idx), detFScores.beta(1, jdx, idx),...
            'Marker', symbol(jdx), 'MarkerSize', 10, 'MarkerEdgeColor', color_ord(idx, :));
    end
end
zlim( [0.9, 1.2] );
xlabel( 'correlation', 'FontSize', 14 );
ylabel( 'relative variability', 'FontSize', 14 );
zlabel( 'bias', 'FontSize', 14 );
%%
figure;
colororder( [[1,0,0];colors.det; colors.ave; colors.cic; colors.con] )
plot( 1:3, [1,1,1], '-');   %ref
hold on;
for idx = 1:size( detFScores.kge, 3)
    plot( 1:3, detFScores.kge_mod(1, 1:3, idx), 'LineWidth', 2);
end
title( "KGE'", 'FontSize', 14 );
xlabel( 'Lead time', 'FontSize', 14 );
xticks( [1,2,3] )
ylabel( "KGE'", 'FontSize', 14 );
ylim( [-0.5, 1.05])
%legend( 'PROGEA', 'average', 'ciclo', 'consistency' );

figure;
plot3( 1, 1, 1, '*', 'Color', colors.lim);
title( "KGE' decomposition", 'FontSize', 16 );
grid on;
hold on;
% 3red lines
plot3( [1,0] , [1,1], [1,1], '-', 'Color', colors.lim );
plot3( [1,1] , [1,0], [1,1], '-', 'Color', colors.lim);
plot3( [1,1] , [1,1], [0.8,1.2], '-', 'Color', colors.lim );
symbol = 'o*s';
color_ord = [colors.det; colors.ave; colors.cic; colors.con];
for idx = 1:size( detFScores.kge, 3)
    for jdx = 1:3
        plot3(detFScores.r(1, jdx, idx), detFScores.gamma(1, jdx, idx), detFScores.beta(1, jdx, idx),...
            'Marker', symbol(jdx), 'MarkerSize', 10, 'MarkerEdgeColor', color_ord(idx, :));
    end
end
zlim( [0.9, 1.2] );
xlabel( 'correlation', 'FontSize', 14 );
ylabel( 'variability ratio', 'FontSize', 14 );
zlabel( 'bias', 'FontSize', 14 );

%%
figure;
colororder( [[1,0,0];colors.det; colors.ave; colors.cic; colors.con] )
plot( 1:3, [1,1,1], '-');
hold on;
for idx = 1:size( detFScores.nse, 3)
    plot( 1:3, detFScores.nse(1, 1:3, idx), 'LineWidth', 2);
end
title( 'NSE', 'FontSize', 16 );
xlabel( 'Lead time', 'FontSize', 14 );
xticks( [1,2,3] )
ylabel( "NSE" , 'FontSize', 14);
ylim( [-0.2, 1.05] );
%legend( {'', 'PROGEA', 'average', 'ciclo', 'consistency'}, 'FontSize', 10 );

figure;
colororder( [[1,0,0];colors.det; colors.ave; colors.cic; colors.con] )
plot( 1:3, [1,1,1], '-');
hold on;
for idx = 1:size( detFScores.ve, 3)
    plot( 1:3, detFScores.ve(1, 1:3, idx), 'LineWidth', 2);
end
title( 'VE', 'FontSize', 16 );
xlabel( 'Lead time', 'FontSize', 14  );
xticks( [1,2,3]  )
ylabel( "VE'", 'FontSize', 14  );
ylim( [0.5, 1.05] );
legend( {'ideal', 'PROGEA', 'average', 'ciclo', 'con: last obs', 'con: mean 3d', ...
    'con: mean 7d ', 'con: mean 14d', 'con: mean 21d', 'con: mean 1mo'}, 'FontSize', 10 );
