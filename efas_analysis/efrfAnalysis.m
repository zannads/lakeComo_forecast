%% efrf
aT = std_aggregation( efrfForecast(1).valid_agg_time( std_aggregation ) );
aT(end-1) = []; % I don't want 1 month of aggregation
lTmax = efrfForecast(1).max_leadTime( aT );
efrfDetForecast( 8 ) = forecast;

for idx = 1:4
    efrfDetForecast(idx*2-1) = efrfForecast(idx).prob2det( 'average' );
    efrfDetForecast(idx*2-1).name = strcat( efrfDetForecast(idx*2-1).name, "_ave" );
    
    efrfDetForecast(idx*2) = efrfForecast(idx).prob2det( 'first' );
    efrfDetForecast(idx*2).name = strcat( efrfDetForecast(idx*2).name, "_first" );
end

benchmark = [averageForecast, cicloForecast.prob2det( 'average' ), conForecast];

%% det
signalsnames = [cat(2, efrfDetForecast.name), cat(2, benchmark.name) ];
scoresnames = {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'};
efrfDetScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames) ),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Score', 'Signal'});
for idx = 1:length(scoresnames)
    for jdx = 1:length(signalsnames)
        efrfDetScores{idx,jdx}{1} = nan(length(aT), max(lTmax)+1);
    end
end
efrfDetScores = addprop(efrfDetScores, 'agg_times', 'table');
efrfDetScores.Properties.CustomProperties.agg_times = aT;

%%
for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % obs
    obs = qAgg(:, w);
    oNan = isnan(obs.(1));
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    for sT = 1:lTmax(aggT)+1
        lT = sT-1;
        
        df = efrfDetForecast.getTimeSeries( aT(aggT), lT );
        
        bf =  benchmark.getTimeSeries( aT(aggT), lT);
        
        matchedData = synchronize( obs, df, bf,'intersection' );
        
        for ref = 1:length(signalsnames)
            p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Standard' );
            efrfDetScores{"kge", signalsnames(ref)}{1}(aggT, sT) = p.kge;
            efrfDetScores{"r", signalsnames(ref)}{1}(aggT, sT) = p.r;
            efrfDetScores{"alpha", signalsnames(ref)}{1}(aggT, sT) = p.alpha;
            efrfDetScores{"beta", signalsnames(ref)}{1}(aggT, sT) = p.beta;
            
            p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Modified' );
            efrfDetScores{"kge_mod", signalsnames(ref)}{1}(aggT, sT) = p.kge;
            efrfDetScores{"gamma", signalsnames(ref)}{1}(aggT, sT) = p.gamma;
            
            p = NSE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
            efrfDetScores{"nse", signalsnames(ref)}{1}(aggT, sT) = p.nse;
            
            efrfDetScores{"ve", signalsnames(ref)}{1}(aggT, sT) = ...
                VE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
        end
    end
end

%% prob
bs_settings(1).type = 'annual';
bs_settings(1).bias = true;
bs_settings(1).quant = [1/3, 2/3];

bs_settings(2).type = 'seasonal';
bs_settings(2).bias = true;
bs_settings(2).quant = [1/3, 2/3];

bs_settings(3).type = 'monthly';
bs_settings(3).bias = true;
bs_settings(3).quant = [1/3, 2/3];

bs_settings(4).type = 'seasonal';
bs_settings(4).bias = false;
bs_settings(4).quant = [1/3, 2/3];

for idx = 1:length(bs_settings)
    bs_settings(idx).name = "bs_" + string(idx);
end

signalsnames = [cat(2, efrfForecast.name), cat(2, benchmark.name) ];
scoresnames = ["crps", cat(2, bs_settings.name)];

efrfProbScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames)),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Scores', 'Signals'});
for jdx = 1:length(signalsnames)
    efrfProbScores{1,jdx}{1} = nan(length(aT), max(lTmax)+1);
end

for idx = 2:length( scoresnames )
    for jdx = 1:length(signalsnames)
        efrfProbScores{idx,jdx}{1} = repmat( brier_score.empty, length(aT), max(lTmax)+1);
    end
end
efrfProbScores = addprop(efrfProbScores, 'agg_times', 'table');
efrfProbScores.Properties.CustomProperties.agg_times = aT;

signals = [efrfForecast, benchmark];
%% crps
for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % obs
    obs = qAgg(:, w);
    oNan = isnan(obs.(1));
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    for sT = 1:lTmax(aggT)+1
        lT = sT-1;
        
        df = getTimeSeries( signals, aT(aggT), lT);
        
        matchedData = synchronize( obs, df,'intersection' );
        
        for ref = 1:length(signalsnames)
            
            if signals(ref).ensembleN >1
                %get an array of matching names,
                pos_ = strfind( matchedData.Properties.VariableNames', signalsnames(ref) );
                % it is a cell array I need to conver it to logical
                pos = false( size(pos_) );
                for k = 1:length(pos)
                    pos(k) = ~isempty( pos_{k} );
                end
                
                % crps needs double array not timetables.
                efrfProbScores{"crps", signalsnames(ref)}{1}(aggT,sT) = ...
                    crps( matchedData{:, pos}, matchedData{:, "observation"} );
                
            elseif signals(ref).ensembleN == 1
                
                efrfProbScores{"crps", signalsnames(ref)}{1}(aggT,sT) = ...
                    MAE( matchedData(:, signalsnames(ref)), matchedData(:,"observation"));
            end
        end
        
    end
end



%% bs
for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % obs
    obs = qAgg(:, w);
    oNan = isnan(obs.(1));
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    for sT = 1:lTmax(aggT)+1
        lT = sT-1;
        
        df = getTimeSeries( signals, aT(aggT), lT);
        
        matchedData = synchronize( obs, df,'intersection' );
        
        for stg =  1:length( bs_settings)
            
            bnd =  brier_score.extract_bounds( matchedData(:, "observation"), bs_settings(stg).quant, bs_settings(stg).type  );
            
            obs_e = brier_score.parse( matchedData(:, "observation"), bnd, bs_settings(stg).type );
            
            for ref = 5:length(signalsnames)
                for_e = brier_score.parse( matchedData(:, signalsnames(ref) ), bnd, bs_settings(stg).type );
                p = brier_score.calculate(for_e, obs_e);
                
                efrfProbScores{bs_settings(stg).name, signalsnames(ref)}{1}(aggT, sT) = p;
            end
            
            for ref = 1:4
                %get an array of matching names,
                pos_ = strfind( matchedData.Properties.VariableNames', signalsnames(ref) );
                % it is a cell array I need to conver it to logical
                pos = false( size(pos_) );
                for k = 1:length(pos)
                    pos(k) = ~isempty( pos_{k} );
                end
                
                if ~bs_settings(stg).bias
                    %reset quantile
                    bnd = brier_score.extract_bounds( matchedData(:, pos), bs_settings(stg).quant, bs_settings(stg).type );
                end
                for_e = brier_score.parse( matchedData(:, pos), bnd, bs_settings(stg).type  );
                
                p = brier_score.calculate(for_e, obs_e);
                
                efrfProbScores{bs_settings(stg).name, signalsnames(ref)}{1}(aggT, sT) = p;
            end
        end
    end
    
end
%%
clear aggT aT bf df for_e idx jdx k matchedData obs obs_e oNan p pos pos_
clear ref scoresnames signals signalsnames sT lT stg sTmax w
clear efrfDetForecast