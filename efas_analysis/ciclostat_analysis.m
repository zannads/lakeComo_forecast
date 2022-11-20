%% det
load('~/Documents/Data/processed/cicloForecast.mat')
load('~/Documents/Data/processed/qAgg.mat')
benchmark = cicloForecast.prob2det( 'average' );
signalsnames = cat(2, benchmark.name);
aT = [caldays([1,3,5,7,14,21,28]), calmonths(1), caldays([42, 56]), calmonths(2:5)];
scoresnames = {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've', 'mae'};
cicloDetScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames) ),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Score', 'Signal'});
for idx = 1:length(scoresnames)
    for jdx = 1:length(signalsnames)
        cicloDetScores{idx,jdx}{1} = nan(length(aT), 1);
    end
end
cicloDetScores = addprop(cicloDetScores, 'agg_times', 'table');
cicloDetScores.Properties.CustomProperties.agg_times = aT;

%%
sT = 1;
for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % obs
    obs = qAgg(:, w);
    oNan = isnan(obs.(1));
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    bf =  benchmark.getTimeSeries( aT(aggT), 9);
    
    matchedData = synchronize( obs, bf,'intersection' );
    
    for ref = 1:length(signalsnames)
        p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Standard' );
        cicloDetScores{"kge", signalsnames(ref)}{1}(aggT, sT) = p.kge;
        cicloDetScores{"r", signalsnames(ref)}{1}(aggT, sT) = p.r;
        cicloDetScores{"alpha", signalsnames(ref)}{1}(aggT, sT) = p.alpha;
        cicloDetScores{"beta", signalsnames(ref)}{1}(aggT, sT) = p.beta;
        
        p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Modified' );
        cicloDetScores{"kge_mod", signalsnames(ref)}{1}(aggT, sT) = p.kge;
        cicloDetScores{"gamma", signalsnames(ref)}{1}(aggT, sT) = p.gamma;
        
        p = NSE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
        cicloDetScores{"nse", signalsnames(ref)}{1}(aggT, sT) = p.nse;
        
        cicloDetScores{"ve", signalsnames(ref)}{1}(aggT, sT) = ...
            VE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
        
        cicloDetScores{"mae", signalsnames(ref)}{1}(aggT, sT) = ...
            MAE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
    end
end
clear aggT ans aT benchmark bf cicloForecast idx jdx lT matchedData obs
clear oNan p qAgg ref scoresnames signalsnames sT w