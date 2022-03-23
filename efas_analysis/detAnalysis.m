%% KGE PROGEA
aT = std_aggregation( detForecast.valid_agg_time( std_aggregation ) );
lTmax = detForecast.max_leadTime( aT );
benchmark = [averageForecast, cicloForecast.prob2det( 'average' ), conForecast];

% det
signalsnames = [detForecast.name, cat(2, benchmark.name )];
scoresnames = {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'};
PROGEADetScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames) ),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Score', 'Signal'});
for idx = 1:length(scoresnames)
    for jdx = 1:length(signalsnames)
        PROGEADetScores{idx,jdx}{1} = nan(length(aT), max(lTmax)+1);
    end
end
PROGEADetScores = addprop(PROGEADetScores, 'agg_times', 'table');
PROGEADetScores.Properties.CustomProperties.agg_times = aT;

%% aggregation time : 1 day
for aggT = 1:length(aT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % obs
    obs = qAgg(:, w);
    oNan = isnan(obs.(1));
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    for sT = 1:lTmax(aggT)+1
        lT = sT-1;
        df = detForecast.getTimeSeries( aT(aggT), lT );
        
        bT =  benchmark.getTimeSeries( aT(aggT), lT);
        
        matchedData = synchronize( obs, df, bT,'intersection' );
        
        for ref = 1:length(signalsnames)
            p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Standard' );
            PROGEADetScores{"kge", signalsnames(ref)}{1}(aggT, sT) = p.kge;
            PROGEADetScores{"r", signalsnames(ref)}{1}(aggT, sT) = p.r;
            PROGEADetScores{"alpha", signalsnames(ref)}{1}(aggT, sT) = p.alpha;
            PROGEADetScores{"beta", signalsnames(ref)}{1}(aggT, sT) = p.beta;
            
            p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Modified' );
            PROGEADetScores{"kge_mod", signalsnames(ref)}{1}(aggT, sT) = p.kge;
            PROGEADetScores{"gamma", signalsnames(ref)}{1}(aggT, sT) = p.gamma;
            
            p = NSE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
            PROGEADetScores{"nse", signalsnames(ref)}{1}(aggT, sT) = p.nse;
            
            PROGEADetScores{"ve", signalsnames(ref)}{1}(aggT, sT) = ...
                VE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
        end
    end
end

%%
clear aggT aT ave cic cicloDetForecast con1 con2 con3 con4 df w bT
clear idx jdx matchedData obs p ref scoresnames signalsnames sT lT lTmax t oNan