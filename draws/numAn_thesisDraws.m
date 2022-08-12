%DRAW PLOTS 
cicloDetForecast = cicloForecast.prob2det( 'average' );
detForecast = PROGEAForecast;
setup_draws;
tFSize = 36;
axFSize = 22;
labFSize = 24;
legFSize = 28;
%%
ye = 2014;
for jdx = 1:4
ye = ye+1;
hist2015 = figure('WindowState','fullscreen'); 
hist2015TL = tiledlayout(3, 1);
for idx = 1:3
    ax(idx) = nexttile;
    plot(historical.Time, historical.dis24, 'LineWidth', 2, 'Color', Tcolor.black);
    hold on;
    detForecast.plot(caldays(1), idx-1, 'Figure', hist2015, 'LineWidth', 2, 'Color', Tcolor.sig1(2,:) );
    %averageForecast.plot(caldays(1), idx-1, 'Figure', hist2015, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
    cicloDetForecast.plot(caldays(1), idx-1, 'Figure', hist2015, 'LineWidth', 1.5, 'Color', Tcolor.sig3(2,:) );
    xlim( [datetime(ye,1,1), datetime(ye, 12, 31) ]);
    yticks( 0:250:1000 )
    ylim( [0, 1060]);
    xlabel('Time', 'FontSize', labFSize);
    ax(idx).XAxis.FontSize = axFSize;
    ax(idx).YAxis.FontSize = axFSize;
    ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', labFSize)
    title( strcat( "Year ",int2str(ye), " PROGEA Lead time Y = ", int2str(24*idx), " h"), 'FontSize', tFSize );
end
hist2015leg = legend('Observed', 'dis_{24}^{Y,PROGEA}', 'Ciclostationary');
hist2015leg.FontSize = 28;
hist2015leg.Location = "southoutside";
hist2015leg.Orientation = 'horizontal';

hist2015TL.Padding = 'compact';
hist2015TL.TileSpacing = 'compact';
end
clear ax hist2015 hist2015leg tl
%% det KGE
aggT = 1;

kgePROGEA = figure('WindowState','fullscreen');
l(1) = plot( 1:3, PROGEADetScores{"kge", "PROGEA"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig1(2,:));
hold on;
l(2) = plot( 1:3, PROGEADetScores{"kge", "average"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.gray);
l(3) = plot( 1:3, PROGEADetScores{"kge", "ciclostationary"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig3(2,:));
l(4) = plot( 1:3, PROGEADetScores{"kge", "ave_1d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(1,:));
l(5) = plot( 1:3, PROGEADetScores{"kge", "ave_3d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(2,:));
l(6) = plot( 1:3, PROGEADetScores{"kge", "ave_7d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(3,:));
l(7) = plot( 1:3, PROGEADetScores{"kge", "ave_30d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(4,:));
l(8) = plot( 1:3, [1,1,1], '--', 'Color', Tcolor.red);

title( 'PROGEA KGE', 'FontSize', tFSize );
xlabel( 'Lead time [h]', 'FontSize', labFSize );
ylabel( 'KGE [-]', 'FontSize', labFSize );
xlim( [0.95, 3.05] )
xticks( [1,2,3] )
xticklabels( ["24", "48", "72"] )
ylim( [-0.5, 1.05])
grid on
ax = gca;
ax(1).XAxis.FontSize = axFSize;
ax(1).YAxis.FontSize = axFSize;

kgePROGEAleg = legend( l, {'PROGEA', 'Mean', 'Ciclostationary', 'Last obs','Average 3d','Average 7d','Average 30d', 'Ideal'} );
kgePROGEAleg.FontSize = 28;
kgePROGEAleg.Location = "southeast";

clear kgePROGEA kgePROGEAleg l
%% KGE dec PROGEA
kgePROGEADecom = figure('WindowState','fullscreen');
plot3( 1, 1, 1, '*', 'Color', Tcolor.red);
title( 'PROGEA KGE decomposition', 'FontSize', tFSize );
grid on;
hold on;

symbol = 'o*d';
color_ord = [Tcolor.sig1(2,:); Tcolor.gray; Tcolor.sig3(2,:); Tcolor.sig2];
k = 1;
for idx = 1:size( PROGEADetScores("kge", :), 2)
    for jdx = 1:3
       l(k) =  plot3(PROGEADetScores{"r",idx}{1}(1, jdx), PROGEADetScores{"alpha",idx}{1}(1, jdx), PROGEADetScores{"beta",idx}{1}(1, jdx),...
            'Marker', symbol(jdx), 'MarkerSize', 18, 'Color', color_ord(idx, :), 'LineWidth', 3, 'LineStyle', 'none');
        k = k+1;
    end
end
% disegno un ulteriore progea solo per la legenda
l(end+1) = plot3(PROGEADetScores{"r",1}{1}(1, 1), PROGEADetScores{"alpha",1}{1}(1, 1), PROGEADetScores{"beta",1}{1}(1, 1),...
            'Marker', symbol(1), 'MarkerSize', 18, 'Color', color_ord(1, :), 'LineWidth', 3, 'LineStyle', 'none');

% 3red lines
l(end+1) = plot3( [1,0] , [1,1], [1,1], '--', 'Color', Tcolor.red );
plot3( [1,1] , [1,0], [1,1], '--', 'Color', Tcolor.red );
plot3( [1,1] , [1,1], [0.9,1.2], '--', 'Color', Tcolor.red );

zlim( [0.9, 1.2] );
ax = gca;
ax(1).XAxis.FontSize = axFSize;
ax(1).YAxis.FontSize = axFSize;
ax(1).ZAxis.FontSize = axFSize;
xlabel( 'Correlation: r [-]', 'FontSize', labFSize );
ylabel( 'Relative variability: \alpha [-]', 'FontSize', labFSize );
zlabel( 'Bias: \beta [-]', 'FontSize', labFSize );
kgePROGEADecomLeg = legend([l(1:3),l(end-1),l(4:3:end-2),l(end)],...
    {'24h lead time', '48h lead time','72h lead time','PROGEA','Mean','Ciclostationary','Last obs','Average 3d','Average 7d','Average 30d','Ideal'} );
kgePROGEADecomLeg.FontSize = legFSize;
%kgePROGEADecomLeg.Location = "southoutside";

clear kgePROGEADecom kgePROGEADecomLeg ax l k
%% NSE VE PROGEA
nse_vePROGEA = figure('WindowState','fullscreen');
tiledlayout(1,2);
ax = nexttile;

l(1) = plot( 1:3, PROGEADetScores{"nse", "PROGEA"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig1(2,:));
hold on;
l(2) = plot( 1:3, PROGEADetScores{"nse", "average"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.gray);
l(3) = plot( 1:3, PROGEADetScores{"nse", "ciclostationary"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig3(2,:));
l(4) = plot( 1:3, PROGEADetScores{"nse", "ave_1d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(1,:));
l(5) = plot( 1:3, PROGEADetScores{"nse", "ave_3d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(2,:));
l(6) = plot( 1:3, PROGEADetScores{"nse", "ave_7d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(3,:));
l(7) = plot( 1:3, PROGEADetScores{"nse", "ave_30d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(4,:));
l(8) = plot( [1,3], [1,1], '--', 'Color', Tcolor.red);

title( 'PROGEA NSE', 'FontSize', tFSize );
ax(1).XAxis.FontSize = axFSize;
ax(1).YAxis.FontSize = axFSize;
xlabel( 'Lead time [h]', 'FontSize', labFSize );
ylabel( 'NSE [-]', 'FontSize', labFSize );
xlim( [0.95, 3.05] )
xticks( [1,2,3] )
xticklabels( ["24", "48", "72"] )
ylim( [-0.1, 1.05] );
grid on,
%legend( {'', 'PROGEA', 'average', 'ciclo', 'consistency'}, 'FontSize', 10 );

ax = nexttile;

l(1) = plot( 1:3, PROGEADetScores{"ve", "PROGEA"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig1(2,:));
hold on;
l(2) = plot( 1:3, PROGEADetScores{"ve", "average"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.gray);
l(3) = plot( 1:3, PROGEADetScores{"ve", "ciclostationary"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig3(2,:));
l(4) = plot( 1:3, PROGEADetScores{"ve", "ave_1d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(1,:));
l(5) = plot( 1:3, PROGEADetScores{"ve", "ave_3d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(2,:));
l(6) = plot( 1:3, PROGEADetScores{"ve", "ave_7d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(3,:));
l(7) = plot( 1:3, PROGEADetScores{"ve", "ave_30d"}{1}(1, :), 'LineWidth', 2, 'Color', Tcolor.sig2(4,:));
l(8) = plot( [1,3], [1,1], '--', 'Color', Tcolor.red);

title( 'PROGEA VE', 'FontSize', tFSize );
ax(1).XAxis.FontSize = axFSize;
ax(1).YAxis.FontSize = axFSize;
xlabel( 'Lead time [h]', 'FontSize', labFSize );
xlim( [0.95, 3.05] )
xticks( [1,2,3] )
xticklabels( ["24", "48", "72"] )
ylabel( "VE [-]", 'FontSize', labFSize  );
ylim( [0.48, 1.024] );
grid on;
nse_vePROGEALeg = legend( l, {'PROGEA', 'Mean', 'Ciclostationary', 'Last obs','Average 3d','Average 7d','Average 30d', 'Ideal'} );
nse_vePROGEALeg.FontSize = legFSize;
nse_vePROGEALeg.Location = "northeast";

clear nse_vePROGEA  nse_vePROGEALeg ax l 
%% efrf 
% hist 2015 -2016 dis24
hist2015 = figure('WindowState','fullscreen'); 
hist2015TL = tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efrfForecast(3).plot( caldays(1), 0, 'Figure', hist2015, 'LineWidth', 2 );
%averageForecast.plot( caldays(1), 0, 'Figure', hist2015, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(caldays(1), 0, 'Figure', hist2015, 'LineWidth', 1.5, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2014+idx,1,1), datetime(2014+idx, 12, 31) ]);
yticks( 0:250:1000 )
ylim( [0, 1060]);
xlabel('Time', 'FontSize', labFSize);
ax(idx).XAxis.FontSize = axFSize;
ax(idx).YAxis.FontSize = axFSize;
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', labFSize)
title( strcat( "Year 201",int2str(4+idx), " efrf seamless definition" ), 'FontSize', tFSize );
end
hist2015leg = legend([ax(2).Children(end),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'dis_{24}^{seam,efrf,LakeComo}', 'Ciclostationary');
hist2015leg.FontSize = 28;
hist2015leg.Location = "southoutside";
hist2015leg.Orientation = 'horizontal';

hist2015TL.Padding = 'compact';
hist2015TL.TileSpacing = 'compact';

clear hist2015 hist2015leg ax 
%% hist 2017-2018 dis24
hist2017 = figure('WindowState','fullscreen'); 
hist2017TL = tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efrfForecast(3).plot( caldays(1), 0, 'Figure', hist2017, 'LineWidth', 2 );
%averageForecast.plot( caldays(1), 0, 'Figure', hist2017, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(caldays(1), 0, 'Figure', hist2017, 'LineWidth', 1.5, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2016+idx,1,1), datetime(2016+idx, 12, 31) ]);
yticks( 0:250:1000 )
ylim( [0, 1060]);
xlabel('Time', 'FontSize', labFSize);
ax(idx).XAxis.FontSize = axFSize;
ax(idx).YAxis.FontSize = axFSize;
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', labFSize)
title( strcat( "Year 201",int2str(6+idx), " efrf seamless definition" ) , 'FontSize', tFSize );
end
hist2017leg = legend([ax(2).Children(end),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'dis_{24}^{seam,efrf,LakeComo}', 'Ciclostationary');
hist2017leg.FontSize = 28;
hist2017leg.Location = "southoutside";
hist2017leg.Orientation = 'horizontal';

hist2017TL.Padding = 'compact';
hist2017TL.TileSpacing = 'compact';

clear hist2017 hist2017leg ax 
%% hist 2015-2016 dis14d 
hist2015 = figure('WindowState','fullscreen'); 
hist2015TL = tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(qAgg.Time, qAgg.agg_14d, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efrfForecast(3).plot( caldays(14), 0, 'Figure', hist2015, 'LineWidth', 2 );
%averageForecast.plot( caldays(14), 0, 'Figure', hist2015, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(caldays(14), 0, 'Figure', hist2015, 'LineWidth', 1.5, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2014+idx,1,1), datetime(2014+idx, 12, 31) ]);
yticks( 0:100:400 )
ylim( [0, 450]);
xlabel('Time', 'FontSize', labFSize);
ax(idx).XAxis.FontSize = axFSize;
ax(idx).YAxis.FontSize = axFSize;
ylabel('dis_{14d} [m^{3}/{s}]', 'FontSize', labFSize)
title( strcat( "Year 201",int2str(4+idx), " efrf seamless definition" ) , 'FontSize', tFSize );
end
hist2015leg = legend([ax(2).Children(end),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'dis_{14d}^{seam,efrf,LakeComo}', 'Ciclostationary');
hist2015leg.FontSize = 28;
hist2015leg.Location = "southoutside";
hist2015leg.Orientation = 'horizontal';

hist2015TL.Padding = 'compact';
hist2015TL.TileSpacing = 'compact';

clear hist2015 hist2015leg ax 
%% hist 2017-2018 dis14d
hist2017 = figure('WindowState','fullscreen'); 
hist2017TL = tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(qAgg.Time, qAgg.agg_14d, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efrfForecast(3).plot(        caldays(14), 0, 'Figure', hist2017, 'LineWidth', 2 );
%averageForecast.plot( caldays(14), 0, 'Figure', hist2017, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(caldays(14), 0, 'Figure', hist2017, 'LineWidth', 1.5, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2016+idx,1,1), datetime(2016+idx, 12, 31) ]);
yticks( 0:100:400 )
ylim( [0, 450]);
xlabel('Time', 'FontSize', labFSize);
ax(idx).XAxis.FontSize = axFSize;
ax(idx).YAxis.FontSize = axFSize;
ylabel('dis_{14d} [m^{3}/{s}]', 'FontSize', labFSize)
title( strcat( "Year 201",int2str(6+idx), " efrf seamless definition" ) , 'FontSize', tFSize );
end
hist2017leg = legend([ax(2).Children(end),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'dis_{14d}^{seam,efrf,LakeComo}', 'Ciclostationary');
hist2017leg.FontSize = 28;
hist2017leg.Location = "southoutside";
hist2017leg.Orientation = 'horizontal';

hist2017TL.Padding = 'compact';
hist2017TL.TileSpacing = 'compact';

clear hist2017 hist2017leg ax 
%% NSE efrf
aT = efrfProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT);

markerpos = '**^^ssvv';
colorOrd = [Tcolor.sig1(2,:);Tcolor.sig2(2,:);Tcolor.sig1(2,:);Tcolor.sig2(2,:);
    Tcolor.sig1(2,:);Tcolor.sig2(2,:);Tcolor.sig1(2,:);Tcolor.sig2(2,:);Tcolor.gray;
    Tcolor.sig3(2,:)];

efrf_nse = figure('WindowState','fullscreen');
l(1) = plot( [1,aTXcord(end)], [1, 1], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:size( efrfDetScores, 2)-6
    l(idx+1) = plot( aTXcord, efrfDetScores{"nse", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markerpos(idx), 'MarkerSize', 16, 'Color', colorOrd(idx,:));
end
for idx = (size( efrfDetScores, 2)-5):size( efrfDetScores, 2)-4
    l(idx+1) = plot( aTXcord, efrfDetScores{"nse", idx}{1}(:,1), 'LineWidth', 2, 'Color', colorOrd(idx,:));
end
title( 'efrf NSE', 'FontSize', tFSize );
ax = gca;
ax.XAxis.FontSize = axFSize;
ax.YAxis.FontSize = axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'NSE [-]', 'FontSize', labFSize );
ylim( [-2, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on
efrfnseLeg = legend([l(2:end),l(1)], {...
    'Fuentes average', 'Fuentes control', 'Mandello average', 'Mandello control', ...
    'LakeComo average', 'LakeComo control', 'Olginate average', 'Olginate control', ...
    'Mean', 'Ciclostationary' , 'Ideal'});
efrfnseLeg.FontSize = legFSize;
efrfnseLeg.Location = "eastoutside";

clear efrf_nse efrfnseLeg ax l
%% KGE efrf
efrf_kge = figure('WindowState','fullscreen');
l(1) = plot( [1,aTXcord(end)], [1, 1], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:size( efrfDetScores, 2)-6
    l(idx+1) = plot( aTXcord, efrfDetScores{"kge", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markerpos(idx), 'MarkerSize', 16, 'Color', colorOrd(idx,:));
end
for idx = (size( efrfDetScores, 2)-5):size( efrfDetScores, 2)-4
    l(idx+1) = plot( aTXcord, efrfDetScores{"kge", idx}{1}(:,1), 'LineWidth', 2, 'Color', colorOrd(idx,:));
end
title( 'efrf KGE', 'FontSize', tFSize );
ax = gca;
ax.XAxis.FontSize = axFSize;
ax.YAxis.FontSize = axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'KGE [-]', 'FontSize', labFSize );
ylim( [-0.5, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on
efrfkgeLeg = legend([l(2:end),l(1)], {...
    'Fuentes average', 'Fuentes control', 'Mandello average', 'Mandello control', ...
    'LakeComo average', 'LakeComo control', 'Olginate average', 'Olginate control', ...
    'Mean', 'Ciclostationary' , 'Ideal'});
efrfkgeLeg.FontSize = legFSize;
efrfkgeLeg.Location = "eastoutside";

clear efrf_kge efrfkgeLeg ax l
%% efrf dec beta r 
efrf_b_r = figure('WindowState','fullscreen');
efrf_b_r_TL = tiledlayout(1,2);
ax(1) = nexttile;
l(1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:8
    l(idx+1) = plot( aTXcord, efrfDetScores{"alpha", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markerpos(idx), 'MarkerSize', 16, 'Color', colorOrd(idx,:));
end
for idx = 9:10
    l(idx+1) = plot( aTXcord, efrfDetScores{"alpha", idx}{1}(:,1), 'LineWidth', 2, 'Color', colorOrd(idx,:));
end

ax(1).XAxis.FontSize = axFSize;
ax(1).YAxis.FontSize = axFSize;
ax(1).XAxis.TickLabelRotation = 90;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'Relative variability: \alpha [-]', 'FontSize', labFSize );
ylim( [0.3, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick);
grid on

ax(2) = nexttile;
l(1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:8
    l(idx+1) = plot( aTXcord, efrfDetScores{"r", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markerpos(idx), 'MarkerSize', 16, 'Color', colorOrd(idx,:));
end
for idx = 9:10
    l(idx+1) = plot( aTXcord, efrfDetScores{"r", idx}{1}(:,1), 'LineWidth', 2, 'Color', colorOrd(idx,:));
end
ax(2).XAxis.FontSize = axFSize;
ax(2).YAxis.FontSize = axFSize;
ax(2).XAxis.TickLabelRotation = 90;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'Correlation: r [-]', 'FontSize', labFSize );
ylim( [0.3, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on

title(efrf_b_r_TL, 'efrf decomposition: \alpha - r', 'FontSize', tFSize );

efrf_b_rLeg = legend([l(2:end),l(1)], {...
    'Fuentes average', 'Fuentes control', 'Mandello average', 'Mandello control', ...
    'LakeComo average', 'LakeComo control', 'Olginate average', 'Olginate control', ...
    'Mean', 'Ciclostationary' , 'Ideal'});
efrf_b_rLeg.FontSize = legFSize;
efrf_b_rLeg.Location = "northeastoutside";

clear efrf_b_r efrf_b_rLeg ax l

%% CRPS efrf
markerpos = '*^sv';
colorOrd = [Tcolor.sig1(2,:);Tcolor.sig1(2,:);Tcolor.sig1(2,:);
    Tcolor.sig1(2,:);Tcolor.gray;Tcolor.sig3(2,:)];

efrf_crps = figure('WindowState','fullscreen');
l(1) = plot( [1, aTXcord(end)], [0, 0], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:4
    l(idx+1) = plot( aTXcord, efrfProbScores{"crps", idx}{1}(:,1), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 18);
end
for idx = 5:6
    l(idx+1) = plot( aTXcord, efrfProbScores{"crps", idx}{1}(:,1), 'LineWidth', 2,  'Color', colorOrd(idx,:));
end
title( 'efrf CRPS', 'FontSize', tFSize );
ax = gca;
ax.XAxis.FontSize = axFSize;
ax.YAxis.FontSize = axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'CRPS [m^3/s]', 'FontSize', labFSize );
%ylim( [-0.5, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on
efrf_crpsLeg = legend([l(2:end),l(1)], {...
    'Fuentes', 'Mandello', 'LakeComo', 'Olginate', 'Mean', 'Ciclostationary' });
efrf_crpsLeg.FontSize = legFSize;
efrf_crpsLeg.Location = "eastoutside";

clear efrf_crps ax l efrf_crpsLeg
%% bs efrf

bsLC = nan(2,12,9);
sc = ["Ubs_monthly0.6", "Bbs_monthly0.6"];
for idx = 1:2
    bsLC(idx,:,:) = cat(3,efrfBrierScores{sc(idx),"LakeComo"}{1}.bs);
end
bsLC = squeeze(mean(bsLC, 2));
bsLC(:,end-1) = []; %remove 1 month

markerpos = '*s';
colorOrd = [Tcolor.sig1(2,:);Tcolor.sig3(2,:)];

efrf_ubs_bs = figure('WindowState','fullscreen');
l(1) = plot( [1, aTXcord(end)], [0, 0], '--', 'Color', Tcolor.red);
l(2) = plot( [1, aTXcord(end)], [2, 2], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:2
    l(idx+2) = plot( aTXcord, bsLC(idx,:), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 18);
end

title( 'efrf Unbiased vs Biased BS Monthly', 'FontSize', tFSize );
ax = gca;
ax.XAxis.FontSize = axFSize;
ax.YAxis.FontSize = axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'BS [-]', 'FontSize', labFSize );
%ylim( [-0.5, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on
efrf_ubs_bsLeg = legend(l(3:4), { 'Unbiased', 'Biased' });
efrf_ubs_bsLeg.FontSize = legFSize;
efrf_ubs_bsLeg.Location = "eastoutside";

%% bs monthly e daily compared
efrf_ubs_m_d = figure('WindowState','fullscreen');
%efrf_ubs_m_dTL = tiledlayout(1,2);
%ax = nexttile;
sc = ["Ubs_monthly0.2", "Ubs_monthly0.4","Ubs_monthly0.6","Ubs_monthly0.8","Ubs_daily0.2", "Ubs_daily0.4","Ubs_daily0.6","Ubs_daily0.8"];

bsLC = nan(length(sc),9);
for idx = 1:4
    bsLC(idx,:,:) = mean(cat(1,efrfBrierScores{sc(idx),"LakeComo"}{1}.bs), 2)';
end
for idx = (1:4)+4
    bsLC(idx,:,:) = mean(cat(1,efrfBrierScores{sc(idx),"LakeComo"}{1}.bs), 2, 'omitnan')';
end
bsLC(:,end-1) = []; %remove 1 month

markerpos = '*sd+*sd+';
colorOrd = [Tcolor.sig1;Tcolor.sig3];

l(1) = plot( [1, aTXcord(end)], [0, 0], '--', 'Color', Tcolor.red);
l(2) = plot( [1, aTXcord(end)], [2, 2], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:length(sc)
    l(idx+2) = plot( aTXcord, bsLC(idx,:), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 18);
end
ax = gca;
ax.XAxis.FontSize = axFSize;
ax.YAxis.FontSize = axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'BS [-]', 'FontSize', labFSize );
ylim( [0, 1] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on
efrf_ubs_m_dLeg = legend(l(3:end), { 'qtM:020', 'qtM:040','qtM:060', 'qtM:080','qtD:020', 'qtD:040','qtD:060', 'qtD:080' });
efrf_ubs_m_dLeg.FontSize = legFSize;
efrf_ubs_m_dLeg.Location = "eastoutside";


title( 'efrf Unbiased BS Monthly vs Daily', 'FontSize', tFSize );

%% efsr
% 2015 -2016 dis 24
hist2015 = figure('WindowState','fullscreen'); 
hist2015TL = tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efsrForecast(3).plot( caldays(1), 0, 'Figure', hist2015, 'LineWidth', 2 );
%averageForecast.plot( caldays(1), 0, 'Figure', hist2015, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(caldays(1), 0, 'Figure', hist2015, 'LineWidth', 1.5, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2014+idx,1,1), datetime(2014+idx, 12, 31) ]);
yticks( 0:250:1000 )
ylim( [0, 1060]);
xlabel('Time', 'FontSize', labFSize);
ax(idx).XAxis.FontSize = axFSize;
ax(idx).YAxis.FontSize = axFSize;
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', labFSize)
title( strcat( "Year 201",int2str(4+idx), " efsr seamless definition" )  , 'FontSize', tFSize );
end
hist2015leg = legend([ax(2).Children(end),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'dis_{24}^{seam,efsr,LakeComo}', 'Ciclostationary');
hist2015leg.FontSize = 28;
hist2015leg.Location = "southoutside";
hist2015leg.Orientation = 'horizontal';

hist2015TL.Padding = 'compact';
hist2015TL.TileSpacing = 'compact';

clear hist2015 hist2015leg ax 
%% 2017 -2018 dis24
hist2017 = figure('WindowState','fullscreen'); 
hist2017TL = tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(historical.Time, historical.dis24, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efsrForecast(3).plot( caldays(1), 0, 'Figure', hist2017, 'LineWidth', 2 );
%averageForecast.plot( caldays(1), 0, 'Figure', hist2017, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(caldays(1), 0, 'Figure', hist2017, 'LineWidth', 1.5, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2016+idx,1,1), datetime(2016+idx, 12, 31) ]);
yticks( 0:250:1000 )
ylim( [0, 1060]);
xlabel('Time', 'FontSize', labFSize);
ax(idx).XAxis.FontSize = axFSize;
ax(idx).YAxis.FontSize = axFSize;
ylabel('dis_{24} [m^{3}/{s}]', 'FontSize', labFSize)
title( strcat( "Year 201",int2str(6+idx), " efsr seamless definition" ) , 'FontSize', tFSize );
end
hist2017leg = legend([ax(2).Children(end),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'dis_{24}^{seam,efsr,LakeComo}', 'Ciclostationary');
hist2017leg.FontSize = 28;
hist2017leg.Location = "southoutside";
hist2017leg.Orientation = 'horizontal';

hist2017TL.Padding = 'compact';
hist2017TL.TileSpacing = 'compact';

clear hist2017 hist2017leg ax 
%{
hist2015 = figure('WindowState','fullscreen'); 
tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(qAgg.Time, qAgg.agg_5mo, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efsrForecast(3).plot( calmonths(5), 0, 'Figure', hist2015, 'LineWidth', 2 );
averageForecast.plot( calmonths(5), 0, 'Figure', hist2015, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(calmonths(5), 0, 'Figure', hist2015, 'LineWidth', 1.25, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2014+idx,1,1), datetime(2014+idx, 12, 31) ]);
yticks( 0:100:400 )
ylim( [0, 450]);
xlabel('Time');
ax(idx).XAxis.FontSize = 18;
ax(idx).YAxis.FontSize = 18;
ylabel('dis_{5mo} [m^{3}/{s}]', 'FontSize', 22)
title( ['dis_{5mo}^{efsr,LakeComo} - Year 201',int2str(4+idx)] , 'FontSize', 36 );
end
hist2015leg = legend([ax(2).Children(end),ax(2).Children(3),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'efsr', 'Mean', 'Ciclostationary');
hist2015leg.FontSize = 28;
hist2015leg.Location = "southoutside";
hist2015leg.Orientation = 'horizontal';

clear hist2015 hist2015leg ax 
%%
hist2017 = figure('WindowState','fullscreen'); 
tiledlayout(2, 1);
for idx = 1:2
ax(idx) = nexttile;
plot(qAgg.Time, qAgg.agg_5mo, 'LineWidth', 2, 'Color', Tcolor.black);
hold on;
efsrForecast(3).plot( calmonths(5), 0, 'Figure', hist2017, 'LineWidth', 2 );
averageForecast.plot( calmonths(5), 0, 'Figure', hist2017, '--', 'LineWidth', 1.25, 'Color', Tcolor.gray  );
cicloDetForecast.plot(calmonths(5), 0, 'Figure', hist2017, 'LineWidth', 1.25, 'Color', Tcolor.sig3(2,:) );
xlim( [datetime(2016+idx,1,1), datetime(2016+idx, 12, 31) ]);
yticks( 0:100:400 )
ylim( [0, 450]);
xlabel('Time');
ax(idx).XAxis.FontSize = 18;
ax(idx).YAxis.FontSize = 18;
ylabel('dis_{5mo} [m^{3}/{s}]', 'FontSize', 22)
title( ['dis_{5mo}^{efsr,LakeComo} - Year 201',int2str(6+idx)] , 'FontSize', 36 );
end
hist2017leg = legend([ax(2).Children(end),ax(2).Children(3),ax(2).Children(2),ax(2).Children(1)],...
    'Observed', 'efsr', 'Mean', 'Ciclostationary');
hist2017leg.FontSize = 28;
hist2017leg.Location = "southoutside";
hist2017leg.Orientation = 'horizontal';

clear hist2017 hist2017leg ax 
%}

%% KGE CORRELATION EFSR
aT = efsrDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT);
aTXtick([1,3]) = ""; %remove some of the first to save space (1d and 5d)

markerpos = '**^^ssvv';
colorOrd = [Tcolor.sig1(2,:);Tcolor.sig2(2,:);Tcolor.sig1(2,:);Tcolor.sig2(2,:);
    Tcolor.sig1(2,:);Tcolor.sig2(2,:);Tcolor.sig1(2,:);Tcolor.sig2(2,:);Tcolor.gray;
    Tcolor.sig3(2,:)];

efsr_kge_r = figure('WindowState','fullscreen');
efsr_kge_rTL = tiledlayout(1,2);
ax(1) = nexttile;
plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:8
    l(idx) = plot( aTXcord, efsrDetScores{"kge", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markerpos(idx), 'MarkerSize', 16, 'Color', colorOrd(idx,:));
end
for idx = 9:10
    l(idx) = plot( aTXcord, efsrDetScores{"kge", idx}{1}(:,1), 'LineWidth', 2, 'Color', colorOrd(idx,:));
end
ax(1).XAxis.FontSize = axFSize-8;
ax(1).YAxis.FontSize = axFSize;
ax(1).XAxis.TickLabelRotation = 90;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'KGE [-]', 'FontSize', labFSize );
ylim( [-0.5, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick);
grid on

ax(2) = nexttile;
l(1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:8
    l(idx+1) = plot( aTXcord, efsrDetScores{"r", idx}{1}(:,1), 'LineWidth', 2, 'Marker', markerpos(idx), 'MarkerSize', 16, 'Color', colorOrd(idx,:));
end
for idx = 9:10
    l(idx+1) = plot( aTXcord, efsrDetScores{"r", idx}{1}(:,1), 'LineWidth', 2, 'Color', colorOrd(idx,:));
end

ax(2).XAxis.FontSize = axFSize-8;
ax(2).YAxis.FontSize = axFSize;
ax(2).XAxis.TickLabelRotation = 90;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'Correlation:r [-]', 'FontSize', labFSize );
ylim( [0.4, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on

efsr_kge_rLeg = legend([l(2:end),l(1)], {...
    'Fuentes average', 'Fuentes control', 'Mandello average', 'Mandello control', ...
    'LakeComo average', 'LakeComo control', 'Olginate average', 'Olginate control', ...
    'Mean', 'Ciclostationary' , 'Ideal'});
efsr_kge_rLeg.FontSize = legFSize;
efsr_kge_rLeg.Location = "northeastoutside";

title(efsr_kge_rTL, 'efsr KGE and correlation component', 'FontSize', tFSize );
efsr_kge_rTL.Padding = 'compact';
efsr_kge_rTL.TileSpacing = 'compact';

clear efsr_r efsr_kge_rLeg ax l

%% CRPS EFSR
markerpos = '*^sv';
colorOrd = [Tcolor.sig1(2,:);Tcolor.sig1(2,:);Tcolor.sig1(2,:);
    Tcolor.sig1(2,:);Tcolor.gray;Tcolor.sig3(2,:)];

efsr_crps = figure('WindowState','fullscreen');
l(1) = plot( [1,aTXcord(end)], [0, 0], '--', 'Color', Tcolor.red);
hold on;
for idx = 1:4
    l(idx+1) = plot( aTXcord, efsrProbScores{"crps", idx}{1}(:,1), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 18);
end
for idx = 5:6
    l(idx+1) = plot( aTXcord, efsrProbScores{"crps", idx}{1}(:,1), 'LineWidth', 2,  'Color', colorOrd(idx,:));
end
title( 'efsr CRPS', 'FontSize', tFSize );
ax = gca;
ax.XAxis.FontSize = axFSize;
ax.XAxis.TickLabelRotation = 90;
ax.YAxis.FontSize = axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', labFSize );
ylabel( 'CRPS [m^3/s]', 'FontSize', labFSize );
%ylim( [-0.5, 1.05] ) 
xticks( aTXcord )
xticklabels( aTXtick );
grid on
efsr_crpsLeg = legend([l(2:end),l(1)], {...
    'Fuentes', 'Mandello', 'LakeComo', 'Olginate', 'Mean', 'Ciclostationary' });
efsr_crpsLeg.FontSize = legFSize;
efsr_crpsLeg.Location = "eastoutside";

clear efsr_crps ax l efrf_crpsLeg

%{ 
% KGE sul piano 1 e 14d non bello
% magari tenerlo per le seasonal
corr_ave = nan(4,5,2);
corr_con = nan(4,5,2);
var_ave  = nan(4,5,2);
var_con  = nan(4,5,2);

for idx = 1:4
    corr_ave(idx,:,1) = efrfDetScores{"r", (idx-1)*2+1}{1}(1, 1:5); 
    corr_ave(idx,:,2) = efrfDetScores{"r", (idx-1)*2+1}{1}(5, 1:5); %aT=14d
    corr_con(idx,:,1) = efrfDetScores{"r",       idx*2}{1}(1, 1:5); %aT=1
    corr_con(idx,:,2) = efrfDetScores{"r",       idx*2}{1}(5, 1:5); %aT=14d
     var_ave(idx,:,1) = efrfDetScores{"r", (idx-1)*2+1}{1}(1, 1:5); %aT=1
     var_ave(idx,:,2) = efrfDetScores{"r", (idx-1)*2+1}{1}(5, 1:5); %aT=14d
     var_con(idx,:,1) = efrfDetScores{"r",       idx*2}{1}(1, 1:5); %aT=1
     var_con(idx,:,2) = efrfDetScores{"r",       idx*2}{1}(5, 1:5); %aT=14d
end

kgesplit = figure('WindowState','fullscreen');
tiledlayout(1,2);
ax(1) = nexttile;
hold on;
%aT=1
jdx = 1;
markerpos = '*^sv';
for idx = 1:4
    for kdx = 1:5
        l(jdx) = plot( efrfDetScores{"r", (idx-1)*2+1}{1}(5, kdx), efrfDetScores{"alpha", (idx-1)*2+1}{1}(5, kdx), ...
            'Marker', markerpos(idx), 'Color', Tcolor.sig1(2,:), 'MarkerSize', 18-2*kdx );
        jdx = jdx+1;
    end
end
for idx = 1:4
    for kdx = 1:5
        l(jdx) = plot( efrfDetScores{"r", 2*idx}{1}(5, kdx), efrfDetScores{"alpha", 2*idx}{1}(5, kdx), ...
            'Marker', markerpos(idx), 'Color', Tcolor.sig2(2,:), 'MarkerSize', 18-2*kdx );
        jdx = jdx+1;
    end
end
%}

