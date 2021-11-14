%% KGE PROGEA
for idx = 1:3
    df = detForecast(:, idx );
    df.Time = df.Time + caldays(idx);
    matchedData = synchronize( historical, df, 'intersection' );
    matchedData.Properties.VariableNames = {'observation', 'simulation'};
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Standard' );
    detForecast.Properties.CustomProperties.kge(idx) = p.kge;
    detForecast.Properties.CustomProperties.r(idx) = p.r ;
    detForecast.Properties.CustomProperties.alpha(idx) = p.alpha ;
    detForecast.Properties.CustomProperties.beta(idx) = p.beta ;
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Modified' );
    detForecast.Properties.CustomProperties.kge_mod(idx) = p.kge;
    detForecast.Properties.CustomProperties.gamma(idx) = p.gamma ;
    
    p = NSE( matchedData(:, 2), matchedData(:, 1) );
    detForecast.Properties.CustomProperties.nse(idx) = p.nse;
    
    detForecast.Properties.CustomProperties.ve(idx) = VE( matchedData(:, 2), matchedData(:, 1) );
end
%% KGE for average
for idx = 1:3
    matchedData = synchronize( historical, ...
        timetable(historical.Time+caldays(idx), averageDetForecast*ones( size(historical.dis24 ) ) ),...
        'intersection' );
    matchedData.Properties.VariableNames = {'observation', 'simulation'};
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Standard' );
    av_detStats.kge(idx) = p.kge;
    av_detStats.r(idx) = p.r ;
    av_detStats.alpha(idx) = p.alpha ;
    av_detStats.beta(idx) = p.beta ;
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Modified' );
    av_detStats.kge_mod(idx) = p.kge;
    av_detStats.gamma(idx) = p.gamma ;
    
    p = NSE( matchedData(:, 2), matchedData(:, 1) );
    av_detStats.nse(idx) = p.nse;
    
    av_detStats.ve(idx) = VE( matchedData(:, 2), matchedData(:, 1) );
end
%% KGE for ciclostat
for idx = 1:3
    df = cicloDetForecast(:, idx );
    df.Time = df.Time + caldays(idx);
    matchedData = synchronize( historical, df, 'intersection' );
    matchedData.Properties.VariableNames = {'observation', 'simulation'};
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Standard' );
    cicloDetForecast.Properties.CustomProperties.kge(idx) = p.kge;
    cicloDetForecast.Properties.CustomProperties.r(idx) = p.r ;
    cicloDetForecast.Properties.CustomProperties.alpha(idx) = p.alpha ;
    cicloDetForecast.Properties.CustomProperties.beta(idx) = p.beta ;
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Modified' );
    cicloDetForecast.Properties.CustomProperties.kge_mod(idx) = p.kge;
    cicloDetForecast.Properties.CustomProperties.gamma(idx) = p.gamma ;
    
    p = NSE( matchedData(:, 2), matchedData(:, 1) );
    cicloDetForecast.Properties.CustomProperties.nse(idx) = p.nse;
    
    cicloDetForecast.Properties.CustomProperties.ve(idx) = VE( matchedData(:, 2), matchedData(:, 1) );
end
%% KGE for CONSIST
for idx = 1:3
   matchedData = synchronize( historical, ...
        timetable(historical.Time+caldays(idx), historical.dis24 ) ,...
        'intersection' );
    matchedData.Properties.VariableNames = {'observation', 'simulation'};
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Standard' );
    con_detStats.kge(idx) = p.kge;
    con_detStats.r(idx) = p.r ;
    con_detStats.alpha(idx) = p.alpha ;
    con_detStats.beta(idx) = p.beta ;
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Modified' );
    con_detStats.kge_mod(idx) = p.kge;
    con_detStats.gamma(idx) = p.gamma ;
    
    p = NSE( matchedData(:, 2), matchedData(:, 1) );
    con_detStats.nse(idx) = p.nse;
    
    con_detStats.ve(idx) = VE( matchedData(:, 2), matchedData(:, 1) );
end
%% PLOT EVERYTHING
clear df matchedData lead

kgePlot = figure;
plot( 1:3, detForecast.Properties.CustomProperties.kge, '-b' );
hold on;
plot( 1:3, av_detStats.kge, '-y' );
plot( 1:3, cicloDetForecast.Properties.CustomProperties.kge, '-r' );
plot( 1:3, con_detStats.kge, '-g' );
title( 'KGE' );
xlabel( 'Lead time' );
ylabel( 'KGE' );
legend( 'PROGEA', 'average', 'ciclo', 'consistency' );

kgeDecPlot = figure; 
plot3( 1, 1, 1, '*r' );
title( 'KGE decomposition' );
grid on;
hold on;
plot3( detForecast.Properties.CustomProperties.r,...
    detForecast.Properties.CustomProperties.alpha, ...
    detForecast.Properties.CustomProperties.beta, 'ob' );
plot3( av_detStats.r,...
    av_detStats.alpha, ...
    av_detStats.beta, 'oy' );
plot3( cicloDetForecast.Properties.CustomProperties.r,...
    cicloDetForecast.Properties.CustomProperties.alpha, ...
    cicloDetForecast.Properties.CustomProperties.beta, 'or' );
plot3( con_detStats.r,...
    con_detStats.alpha, ...
    con_detStats.beta, 'og' );
xlabel( 'correlation' );
ylabel( 'relative variability' );
zlabel( 'bias' );
%%
kgeModPlot = figure;
plot( 1:3, detForecast.Properties.CustomProperties.kge_mod, '-b' );
hold on;
plot( 1:3, av_detStats.kge_mod, '-y' );
plot( 1:3, cicloDetForecast.Properties.CustomProperties.kge_mod, '-r' );
plot( 1:3, con_detStats.kge_mod, '-g' );
title( 'Modified KGE' );
xlabel( 'Lead time' );
ylabel( "KGE'" );
legend( 'PROGEA', 'average', 'ciclo', 'consistency' );

kgeModDecPlot = figure; 
plot3( 1, 1, 1, '*r' );
title( "KGE' decomposition" );
grid on;
hold on;
plot3( detForecast.Properties.CustomProperties.r,...
    detForecast.Properties.CustomProperties.gamma, ...
    detForecast.Properties.CustomProperties.beta, 'ob' );
plot3( av_detStats.r,...
    av_detStats.gamma, ...
    av_detStats.beta, 'oy' );
plot3( cicloDetForecast.Properties.CustomProperties.r,...
    cicloDetForecast.Properties.CustomProperties.gamma, ...
    cicloDetForecast.Properties.CustomProperties.beta, 'or' );
plot3( con_detStats.r,...
    con_detStats.gamma, ...
    con_detStats.beta, 'og' );
xlabel( 'correlation' );
ylabel( 'variability ratio' );
zlabel( 'bias' );

%%
nsePlot = figure;
plot( 1:3, detForecast.Properties.CustomProperties.nse, '-b' );
hold on;
plot( 1:3, av_detStats.nse, '-y' );
plot( 1:3, cicloDetForecast.Properties.CustomProperties.nse, '-r' );
plot( 1:3, con_detStats.nse, '-g' );
title( 'NSE' );
xlabel( 'Lead time' );
ylabel( "NSE" );
legend( 'PROGEA', 'average', 'ciclo', 'consistency' );
%%
vePlot = figure;
plot( 1:3, detForecast.Properties.CustomProperties.kge_mod, '-b' );
hold on;
plot( 1:3, av_detStats.kge_mod, '-y' );
plot( 1:3, cicloDetForecast.Properties.CustomProperties.kge_mod, '-r' );
plot( 1:3, con_detStats.kge_mod, '-g' );
title( 'VE' );
xlabel( 'Lead time' );
ylabel( "VE'" );
legend( 'PROGEA', 'average', 'ciclo', 'consistency' );

clear idx clear p 