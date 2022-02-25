%DRAW PLOTS 
cicloDetForecast = cicloForecast.prob2det( 'average' );
%%
hist2015 = figure; 
colororder( [[0,0,0];colors.det; colors.ave; colors.cic;] );
tiledlayout(3, 1);
for idx = 1:3
nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2);
hold on;
detForecast.plot(caldays(1), idx-1, 'Figure', hist2015, 'LineWidth', 2 );
averageForecast.plot(caldays(1), idx-1, 'Figure', hist2015, '--', 'LineWidth', 0.75  );
cicloDetForecast.plot(caldays(1), idx-1, 'Figure', hist2015, 'LineWidth', 0.75  );
xlim( [datetime(2015,1,1), datetime(2015, 12, 31) ]);
ylim( [0, 1060]);
xlabel('Time');
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', 14)
title( strcat("Lead", num2str(idx)), 'FontSize', 14 );
end

%% det KGE
aggT = 1;

figure;
colororder( [[1,0,0];colors.det; colors.ave; colors.cic; colors.con] )
plot( 1:3, [1,1,1], '-');
hold on;
for idx = 1:size( PROGEADetScores("kge", :), 2)
    plot( 1:3, PROGEADetScores{"kge", idx}{1}(1, :), 'LineWidth', 2);
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
for idx = 1:size( PROGEADetScores("kge", :), 2)
    for jdx = 1:3
        plot3(PROGEADetScores{"r",idx}{1}(1, jdx), PROGEADetScores{"alpha",idx}{1}(1, jdx), PROGEADetScores{"beta",idx}{1}(1, jdx),...
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
for idx = 1:size( PROGEADetScores("kge_mod", :), 2)
    plot( 1:3, PROGEADetScores{"kge_mod", idx}{1}(1, :), 'LineWidth', 2);
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
for idx = 1:size( PROGEADetScores("kge_mod", :), 2)
    for jdx = 1:3
        plot3(PROGEADetScores{"r",idx}{1}(1, jdx), PROGEADetScores{"gamma",idx}{1}(1, jdx), PROGEADetScores{"beta",idx}{1}(1, jdx),...
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
for idx = 1:size( PROGEADetScores("nse", :), 2)
    plot( 1:3, PROGEADetScores{"nse", idx}{1}(1, :), 'LineWidth', 2);
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
for idx = 1:size( PROGEADetScores("ve", :), 2)
    plot( 1:3, PROGEADetScores{"ve", idx}{1}(1, :), 'LineWidth', 2);
end
title( 'VE', 'FontSize', 16 );
xlabel( 'Lead time', 'FontSize', 14  );
xticks( [1,2,3]  )
ylabel( "VE", 'FontSize', 14  );
ylim( [0.5, 1.05] );
legend( {'ideal', 'PROGEA', 'average', 'ciclo', 'con: last obs', 'con: mean 3d', ...
    'con: mean 7d ', 'con: mean 1mo'}, 'FontSize', 10 );

%% 
clear hist2015
clear cicloDetForecast aggT color_ord colors idx jdx symbol