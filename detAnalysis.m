%% KGE PROGEA
aT = std_aggregation( detForecast.valid_agg_time( std_aggregation ) );
sTmax = detForecast.max_step( aT );
cicloDetForecast = cicloForecast.prob2det( 'average' );

% det
signalsnames = [detForecast.name, averageForecast.name, cicloForecast.name, ...
    cat(2, conForecast.name )];
scoresnames = {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'};
PROGEADetScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames) ),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Score', 'Signal'});
for idx = 1:length(scoresnames)
    for jdx = 1:length(signalsnames)
        PROGEADetScores{idx,jdx}{1} = nan(length(aT), max(sTmax));
    end
end
PROGEADetScores = addprop(PROGEADetScores, 'agg_times', 'table');
PROGEADetScores.Properties.CustomProperties.agg_times = aT;

%% aggregation time : 1 day
for aggT = 1:length(aT)
    w = strcat( "agg_", string( aT(aggT) ) );
    obs = qAgg(:, w);
    obs = obs( ~isnan(obs{:,1}), 1);
    for sT = 1:sTmax(aggT)
        df = detForecast.getTimeSeries( aT(aggT), sT );
        
        ave = averageForecast.getTimeSeries( aT(aggT), sT );
        cic = cicloDetForecast.getTimeSeries( aT(aggT), sT );
        con1 = conForecast(1).getTimeSeries( aT(aggT), sT );
        con2 = conForecast(2).getTimeSeries( aT(aggT), sT );
        con3 = conForecast(3).getTimeSeries( aT(aggT), sT );
        con4 = conForecast(4).getTimeSeries( aT(aggT), sT );
        
        matchedData = synchronize( obs, df, ave, cic, con1, con2, con3, con4,'intersection' );
        
        matchedData.Properties.VariableNames = ["observation", signalsnames];
        
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
clear aggT aT ave cic cicloDetForecast con1 con2 con3 con4 df w
clear idx jdx matchedData obs p ref scoresnames signalsnames sT sTmax t