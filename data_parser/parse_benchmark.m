% parse_benchmark
clear averageDis24 cicloDetForecast consistencyDetForecast
%% benchmarks 
%AVERAGE
meanDis24Historical = mean( historical.dis24 );
t = size( historical, 1);
averageDetForecast = timetable( historical.Time, ...
    meanDis24Historical*ones( t,1), meanDis24Historical*ones( t,1), ...
    meanDis24Historical*ones( t,1) );
averageDetForecast.Properties.VariableNames = {'Lead1', 'Lead2', 'Lead3'};
averageDetForecast = addprop( averageDetForecast, {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'}, ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );


%CICLOSTATIONARY
cicloDetForecast = moving_average( historical  ); %filter noise
cicloDetForecast = ciclostationary( cicloDetForecast  ); %get one realization(365 d) of ciclostationary mean
cicloDetForecast = cicloseriesGenerator( cicloDetForecast, historical); %force ciclostat mean in historical size.
cicloDetForecast.(2) = cicloDetForecast.(1);
cicloDetForecast.(3) = cicloDetForecast.(1);
cicloDetForecast.Properties.VariableNames = {'Lead1', 'Lead2', 'Lead3'};
cicloDetForecast = addprop( cicloDetForecast, {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'}, ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );

%CONSISTENCY 
consistencyDetForecast = timetable( historical.Time, ...
    [meanDis24Historical; historical.dis24(1:end-1)], ...
    [meanDis24Historical; historical.dis24(1:end-1)], ...
    [meanDis24Historical; historical.dis24(1:end-1)] );

consistencyDetForecast.Properties.VariableNames = {'Lead1', 'Lead2', 'Lead3' };
consistencyDetForecast = addprop( consistencyDetForecast, {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'}, ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );

%%
figure;
plot( historical.Time, historical.dis24 );
hold on; 
plot( averageDetForecast.Time, averageDetForecast.Lead1 );
plot( cicloDetForecast.Time, cicloDetForecast.Lead1 );
plot( consistencyDetForecast.Time, consistencyDetForecast.Lead1 );
legend( 'History', 'Average', 'ciclo', 'consistency' );

%%
clear first_day deterministic_forecast meanDis24Historical w idx t temp