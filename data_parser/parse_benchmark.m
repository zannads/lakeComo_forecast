% parse_benchmark
clear averageDetForecast cicloDetForecast conDetForecast
%% benchmarks 
h = aggregate_historical(historical, std_aggregation );    

%% AVERAGE
averageDetForecast = benchmark( mean( historical.dis24), 'average' );
averageDetForecast = calculateStats( averageDetForecast , h);

%CICLOSTATIONARY
cs = moving_average( historical  ); %filter noise
cs = ciclostationary( cs  ); %get one realization(365 d) of ciclostationary mean
cicloDetForecast = benchmark( cs, 'ciclostationary');
cicloDetForecast = calculateStats( cicloDetForecast, h );

%CONSISTENCY 
% consistency is just a shift on time, thus I don't create one because I
% can alwys start from historical.
conDetForecast = benchmark( [], 'consistency');
conDetForecast = calculateStats( conDetForecast, h );

%% PROB
% mae for crps
% brier?