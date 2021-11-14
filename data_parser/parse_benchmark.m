% parse_benchmark
clear cicloDetForecast
%% benchmarks 
%AVERAGE
averageDetForecast = mean( historical.dis24 );
av_detStats = detStats;
% populate with zeros;
t_ = zeros(1, size( detForecast, 2) );
n = fieldnames(detStats);
for j = 1:length(n)
    av_detStats.(n{j}) = t_;
end
clear t_ j n


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
% consistency is just a shift on time, thus I don't create one because I
% can alwys start from historical.
con_detStats = av_detStats;
%%
figure;
plot( historical.Time, historical.dis24 );
hold on; 
plot( historical.Time, averageDetForecast*ones( size(historical.Time)) );
plot( cicloDetForecast.Time, cicloDetForecast.Lead1 );
plot( historical.Time+1, historical.dis24 );
legend( 'History', 'Average', 'ciclo', 'consistency' );