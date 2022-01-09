%% PROB
%%
h2015_efrf_1d = figure;
plot( historical.Time, historical.dis24 , 'k', 'LineWidth', 1.75);
hold on
efrfForecast(2).plot(caldays(1), 1, 'Figure', h2015_efrf_1d);
xlim( [datetime(2015,1,1), datetime(2015, 12, 31) ]);
ylim( [0, 700]);
xlabel('Time');
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', 14)
title( "Lead1", 'FontSize', 14 );

h2015_efrf_1mo = figure;
plot( qAgg.Time(qAgg.Time.Day==1), qAgg.agg_1mo(qAgg.Time.Day==1) , 'k', 'LineWidth', 1.75);
hold on
efrfForecast(2).plot(calmonths(1), 1, 'Figure', h2015_efrf_1mo)
xlim( [datetime(2015,1,1), datetime(2018, 12, 31) ]);
ylim( [0, 500]);
xlabel('Time');
ylabel('monthly discharge [m^{3}/{s}]', 'FontSize', 14)
title( "1 step ahead of monthly average discharge", 'FontSize', 14 );

%%
aT = efrfProbScores.Properties.CustomProperties.agg_times;
markpos = {'*','*', '+','+', 'x','x', 's','s', 'none', 'none'};
figure;
colororder( [[1,0,0];colors.prob2det;colors.prob2det;colors.prob2det;colors.prob2det;...
    colors.ave; colors.cic; colors.con] )
plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:size( efrfDetScores, 2)-6
    plot( 1:length(aT), efrfDetScores{"kge", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markpos{idx}, 'MarkerSize', 11);
end
for idx = idx+1:size( efrfDetScores, 2)
    plot( 1:length(aT), efrfDetScores{"kge", idx}{1}(:,1), 'LineWidth', 0.75);
end
title( 'KGE', 'FontSize', 18 );
xlabel( 'Aggregation time', 'FontSize', 14 );
ylabel( 'KGE', 'FontSize', 14 );
xticklabels( strcat("agg-", string(aT) ));
ylim( [-0.5, 1.05] );
grid on
%legend( 'PROGEA', 'average', 'ciclo', 'consistency' );

figure;
colororder( [[1,0,0];colors.prob2det;colors.prob2det;colors.prob2det;colors.prob2det;...
    colors.ave; colors.cic; colors.con] )
plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:size( efrfDetScores, 2)-6
    plot( 1:length(aT), efrfDetScores{"nse", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markpos{idx}, 'MarkerSize', 11);
end
for idx = idx+1:size( efrfDetScores, 2)
    plot( 1:length(aT), efrfDetScores{"nse", idx}{1}(:,1), 'LineWidth', 0.75);
end
title( 'NSE', 'FontSize', 18 );
xlabel( 'Aggregation time', 'FontSize', 14 );
ylabel( 'NSE', 'FontSize', 14 );
ylim( [-3.5, 1.05] ) 
xticklabels( strcat("agg-", string(aT) ));
grid on

%%
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
for idx = 1:size(efrfDetScores, 2)
    for jdx = 1:7
        plot3(efrfDetScores{'r', idx}{1}(1, jdx), efrfDetScores{'alpha', idx}{1}(1, jdx), efrfDetScores{'beta', idx}{1}(1, jdx),...
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
for idx = 1:size(efrfDetScores, 2)-6
    for jdx = 1:7
        plot3(efrfDetScores{'r', idx}{1}(7, jdx), efrfDetScores{'alpha', idx}{1}(7, jdx), efrfDetScores{'beta', idx}{1}(7, jdx),...
            'Marker', markpos{idx}, 'MarkerSize', 11-jdx, 'MarkerEdgeColor', color_ord(idx, :));
    end
end
zlim( [0.2, 1.1] );
xlabel( 'correlation', 'FontSize', 14 );
ylabel( 'relative variability', 'FontSize', 14 );
zlabel( 'bias', 'FontSize', 14 );

%%
markpos = {'*','+','x','s','none', 'none'};
figure;
colororder( [colors.det;colors.det;colors.det;colors.det;...
    colors.ave; colors.cic; colors.con] )
%plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:6
    plot( 1:length(aT), efrfProbScores{"crps", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markpos{idx});
end
title( 'CRPS', 'FontSize', 18 );
xlabel( 'Aggregation time', 'FontSize', 14 );
ylabel( 'CRPS', 'FontSize', 14 );
xticklabels( strcat("agg-", string(aT) ));
grid on
%%
figure;
colororder( [colors.det;colors.det;colors.det;colors.det;...
    colors.ave; colors.cic; colors.con] )
%plot( [1,length(aT)], [1, 1], '-');
hold on;
for idx = 1:6
    score = cat(1,efrfProbScores{"bs_1", idx}{1}(:,1).bs);
    plot( 1:length(aT), score, 'LineWidth', 2, 'Marker', markpos{idx});
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
    for idx = 1:6
        score = cat(1,efrfProbScores{"bs_2", idx}{1}(:,1).bs);
        plot( 1:length(aT), score(:, jdx) , 'LineWidth', 2, 'Marker', markpos{idx});
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
    for idx = 1:6
        score = cat(1,efrfProbScores{"bs_4", idx}{1}(:,1).bs);
        plot( 1:length(aT), score(:, jdx), 'LineWidth', 2, 'Marker', markpos{idx});
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

%%
figure;
tiledlayout(2,2)
for jdx = 1:4
    nexttile;
    colororder( [colors.det;colors.det;colors.det;colors.det;...
        colors.ave; colors.cic; colors.con] )
    %plot( [1,length(aT)], [1, 1], '-');
    hold on;
    for idx = 1:6
        score = cat(1,efrfProbScores{"bs_6", idx}{1}(:,1).bs);
        plot( 1:length(aT), score(:,jdx), 'LineWidth', 2, 'Marker', markpos{idx});
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