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
legend( {'', 'PROGEA', 'average', 'ciclo', 'consistency'}, 'FontSize', 10 );

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
legend( {'', 'PROGEA', 'average', 'ciclo', 'consistency'}, 'FontSize', 10 );
%% PROB
%%
a = figure;
plot( historical.Time, historical.dis24 , 'k', 'LineWidth', 1.75);
hold on
efsrForecast.plot( 'Figure', a);
xlim( [datetime(2015,1,1), datetime(2015, 12, 31) ]);
ylim( [0, 700]);
xlabel('Time');
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', 14)
title( "Lead1", 'FontSize', 14 );

a = figure;
plot( hAgg.Time(hAgg.Time.Day==1), hAgg.agg_1mo(hAgg.Time.Day==1) , 'k', 'LineWidth', 1.75);
hold on
efsrForecast.plot( 'Figure', a, 'AggTime', calmonths(1))
xlim( [datetime(2015,1,1), datetime(2018, 12, 31) ]);
ylim( [0, 500]);
xlabel('Time');
ylabel('monthly discharge [m^{3}/{s}]', 'FontSize', 14)
title( "1 step ahead of monthly average discharge", 'FontSize', 14 );

a = figure;
plot( hAgg.Time(hAgg.Time.Day==1), hAgg.agg_2mo(hAgg.Time.Day==1) , 'k', 'LineWidth', 1.75);
hold on
efsrForecast.plot( 'Figure', a, 'AggTime', calmonths(2))
xlim( [datetime(2015,1,1), datetime(2018, 12, 31) ]);
ylim( [0, 500]);
xlabel('Time');
ylabel('2 months discharge [m^{3}/{s}]', 'FontSize', 14)
title( "1 step ahead of 2 months average discharge", 'FontSize', 14 );

%%
aT = efsrProbScores.Properties.CustomProperties.agg_times;
markpos = {'*','*', '+','+', 'x','x', 's','s', 'none', 'none'};
figure;
colororder( [[1,0,0];colors.prob2det;colors.prob2det;colors.prob2det;colors.prob2det;...
    colors.ave; colors.cic; colors.con] )
plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:size( efsrDetScores, 2)-6
    plot( 1:length(aT), efsrDetScores{"kge", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markpos{idx});
end
for idx = idx+1:size( efsrDetScores, 2)
    plot( 1:length(aT), efsrDetScores{"kge", idx}{1}(:,1), 'LineWidth', 0.75);
end
title( 'KGE', 'FontSize', 18 );
xlabel( 'Aggregation time', 'FontSize', 14 );
ylabel( 'KGE', 'FontSize', 14 );
xticklabels( strcat("agg-", string(aT) ));
grid on
%legend( 'PROGEA', 'average', 'ciclo', 'consistency' );

markpos = {'*','*', '+','+', 'x','x', 's','s', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o'};
figure;
plot3( 1, 1, 1, '*', 'Color', colors.lim);
title( 'KGE decomposition Agg:1d', 'FontSize', 18 );
grid on;
hold on;
% 3red lines
plot3( [1,0] , [1,1], [1,1], '-', 'Color', colors.lim );
plot3( [1,1] , [1,0], [1,1], '-', 'Color', colors.lim);
plot3( [1,1] , [1,1], [0.8,1.2], '-', 'Color', colors.lim );
color_ord = [colors.prob2det;colors.prob2det;colors.prob2det;colors.prob2det;...
    colors.ave; colors.cic; colors.con];
for idx = 1:size(efsrDetScores, 2)
    for jdx = 1:7
        plot3(efsrDetScores{'r', idx}{1}(1, jdx), efsrDetScores{'alpha', idx}{1}(1, jdx), efsrDetScores{'beta', idx}{1}(1, jdx),...
            'Marker', markpos{idx}, 'MarkerSize', 11-jdx, 'MarkerEdgeColor', color_ord(idx, :));
    end
end
zlim( [0.2, 1.1] );
xlabel( 'correlation', 'FontSize', 14 );
ylabel( 'relative variability', 'FontSize', 14 );
zlabel( 'bias', 'FontSize', 14 );


figure;
plot3( 1, 1, 1, '*', 'Color', colors.lim);
title( 'KGE decomposition Agg:1mo', 'FontSize', 18 );
grid on;
hold on;
% 3red lines
plot3( [1,0] , [1,1], [1,1], '-', 'Color', colors.lim );
plot3( [1,1] , [1,0], [1,1], '-', 'Color', colors.lim);
plot3( [1,1] , [1,1], [0.8,1.2], '-', 'Color', colors.lim );
color_ord = [colors.prob2det;colors.prob2det;colors.prob2det;colors.prob2det;...
    colors.ave; colors.cic; colors.con];
for idx = 1:size(efsrDetScores, 2)-6
    for jdx = 1:7
        plot3(efsrDetScores{'r', idx}{1}(7, jdx), efsrDetScores{'alpha', idx}{1}(7, jdx), efsrDetScores{'beta', idx}{1}(7, jdx),...
            'Marker', markpos{idx}, 'MarkerSize', 11-jdx, 'MarkerEdgeColor', color_ord(idx, :));
    end
end
zlim( [0.2, 1.1] );
xlabel( 'correlation', 'FontSize', 14 );
ylabel( 'relative variability', 'FontSize', 14 );
zlabel( 'bias', 'FontSize', 14 );

figure;
colororder( [[1,0,0];colors.prob2det;colors.prob2det;colors.prob2det;colors.prob2det;...
    colors.ave; colors.cic; colors.con] )
plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:size( efsrDetScores, 2)-6
    plot( 1:length(aT), efsrDetScores{"nse", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markpos{idx});
end
for idx = idx+1:size( efsrDetScores, 2)
    plot( 1:length(aT), efsrDetScores{"nse", idx}{1}(:,1), 'LineWidth', 0.75);
end
title( 'NSE', 'FontSize', 18 );
xlabel( 'Aggregation time', 'FontSize', 14 );
ylabel( 'NSE', 'FontSize', 14 );
xticklabels( strcat("agg-", string(aT) ));
grid on

%%
markpos = {'*','+','x','s','none', 'none'};
figure;
colororder( [colors.det;colors.det;colors.det;colors.det;...
    colors.ave; colors.cic; colors.con] )
%plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:size( efsrProbScores, 2)-6
    plot( 1:length(aT), efsrProbScores{"crps", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markpos{idx});
end
title( 'CRPS', 'FontSize', 18 );
xlabel( 'Aggregation time', 'FontSize', 14 );
ylabel( 'CRPS', 'FontSize', 14 );
xticklabels( strcat("agg-", string(aT) ));
grid on

figure;
colororder( [colors.det;colors.det;colors.det;colors.det;...
    colors.ave; colors.cic; colors.con] )
%plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:size( efsrProbScores, 2)-6
    plot( 1:length(aT), efsrProbScores{"bs_annual_1/3_2/3", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markpos{idx});
end
title( 'BS', 'FontSize', 18 );
xlabel( 'Aggregation time', 'FontSize', 14 );
ylabel( 'BS', 'FontSize', 14 );
ylim( [0, 2]);
xticklabels( strcat("agg-", string(aT) ));
grid on

seas = {'Spring', 'Summer', 'Autumn', 'Winter'};
figure;
tiledlayout(2,2)
for jdx = 1:4
    nexttile;
    colororder( [colors.det;colors.det;colors.det;colors.det;...
        colors.ave; colors.cic; colors.con] )
    %plot( [1,length(aT)], [1, 1], '-');
    hold on;
    for idx = 1:size( efsrProbScores, 2)-6
        plot( 1:length(aT), efsrProbScores{"bs_seasonal_1/3_2/3", idx}{1}(:,1,jdx), 'LineWidth', 2, 'Marker', markpos{idx});
    end
    title( strcat("BS ", seas{jdx}), 'FontSize', 18 );
    xlabel( 'Aggregation time', 'FontSize', 14 );
    ylabel( 'BS', 'FontSize', 14 );
    xticks( 1:length(aT))
    xticklabels( strcat("agg-", string(aT) ));
    xlim( [1, length(aT)] )
    ylim( [0, 2])
    grid on
end

figure;
tiledlayout(2,2)
for jdx = 1:4
    nexttile;
    colororder( [colors.det;colors.det;colors.det;colors.det;...
        colors.ave; colors.cic; colors.con] )
    %plot( [1,length(aT)], [1, 1], '-');
    hold on;
    for idx = 1:size( efsrProbScores, 2)-6
        plot( 1:length(aT), efsrProbScores{"bs_seasonal_1/3_2/3ub", idx}{1}(:,1,jdx), 'LineWidth', 2, 'Marker', markpos{idx});
    end
    title( strcat("BS ", seas{jdx}), 'FontSize', 18 );
    xlabel( 'Aggregation time', 'FontSize', 14 );
    ylabel( 'BS', 'FontSize', 14 );
    xticks( 1:length(aT))
    xticklabels( strcat("agg-", string(aT) ));
    xlim( [1, length(aT)] )
    ylim( [0, 2])
    grid on
end