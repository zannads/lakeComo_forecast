%% efrs
aT = std_aggregation( efsrForecast(1).valid_agg_time( std_aggregation ) );
lTmax = efsrForecast(1).max_leadTime( aT );
efsrDetForecast( 8 ) = forecast;

for idx = 1:4
    efsrDetForecast(idx*2-1) = efsrForecast(idx).prob2det( 'average' );
    efsrDetForecast(idx*2-1).name = strcat( efsrDetForecast(idx*2-1).name, "_ave" );
    
    efsrDetForecast(idx*2) = efsrForecast(idx).prob2det( 'first' );
    efsrDetForecast(idx*2).name = strcat( efsrDetForecast(idx*2).name, "_first" );
end

benchmark = [averageForecast, cicloForecast.prob2det( 'average' ), conForecast];

%% det
signalsnames = [cat(2, efsrDetForecast.name), cat(2, benchmark.name) ];
scoresnames = {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'};
efsrDetScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames) ),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Score', 'Signal'});
for idx = 1:length(scoresnames)
    for jdx = 1:length(signalsnames)
        efsrDetScores{idx,jdx}{1} = nan(length(aT), max(lTmax)+1);
    end
end
efsrDetScores = addprop(efsrDetScores, 'agg_times', 'table');
efsrDetScores.Properties.CustomProperties.agg_times = aT;

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
        
        df = efsrDetForecast.getTimeSeries( aT(aggT), lT );
        
        bf =  benchmark.getTimeSeries( aT(aggT), lT);
        
        matchedData = synchronize( obs, df, bf,'intersection' );
        
        for ref = 1:length(signalsnames)
            p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Standard' );
            efsrDetScores{"kge", signalsnames(ref)}{1}(aggT, sT) = p.kge;
            efsrDetScores{"r", signalsnames(ref)}{1}(aggT, sT) = p.r;
            efsrDetScores{"alpha", signalsnames(ref)}{1}(aggT, sT) = p.alpha;
            efsrDetScores{"beta", signalsnames(ref)}{1}(aggT, sT) = p.beta;
            
            p = KGE( matchedData(:, signalsnames(ref)), matchedData(:, "observation"), 'Modified' );
            efsrDetScores{"kge_mod", signalsnames(ref)}{1}(aggT, sT) = p.kge;
            efsrDetScores{"gamma", signalsnames(ref)}{1}(aggT, sT) = p.gamma;
            
            p = NSE( matchedData(:, signalsnames(ref)), matchedData(:, "observation") );
            efsrDetScores{"nse", signalsnames(ref)}{1}(aggT, sT) = p.nse;
            
            efsrDetScores{"ve", signalsnames(ref)}{1}(aggT, sT) = ...
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

bs_settings(5).type = 'seasonal';
bs_settings(5).bias = false;
bs_settings(5).quant = 1/20;

bs_settings(6).type = 'seasonal';
bs_settings(6).bias = false;
bs_settings(6).quant = 1/10;

bs_settings(7).type = 'seasonal';
bs_settings(7).bias = false;
bs_settings(7).quant = 9/10;

bs_settings(8).type = 'seasonal';
bs_settings(8).bias = false;
bs_settings(8).quant = 19/20;
for idx = 1:length(bs_settings)
bs_settings(idx).name = "bs_" + string(idx);
end

signalsnames = [cat(2, efsrForecast.name), cat(2, benchmark.name) ];
scoresnames = ["crps", cat(2, bs_settings.name)];
    
efsrProbScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames)),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Scores', 'Signals'});
for jdx = 1:length(signalsnames)
    efsrProbScores{1,jdx}{1} = nan(length(aT), max(lTmax)+1);
end

for idx = 2:length( scoresnames )
    for jdx = 1:length(signalsnames)
        efsrProbScores{idx,jdx}{1} = repmat( brier_score.empty, length(aT), max(lTmax)+1);
    end
end
efsrProbScores = addprop(efsrProbScores, 'agg_times', 'table');
efsrProbScores.Properties.CustomProperties.agg_times = aT;

%% crps
signals = [efsrForecast, benchmark];
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
                efsrProbScores{"crps", signalsnames(ref)}{1}(aggT,sT) = ...
                    crps( matchedData{:, pos}, matchedData{:, "observation"} );
                
            elseif signals(ref).ensembleN == 1
                
                efsrProbScores{"crps", signalsnames(ref)}{1}(aggT,sT) = ...
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
            
            brier_score.type( bs_settings(stg).type )
            
            brier_score.boundaries( brier_score.extract_bounds( matchedData(:, "observation"), bs_settings(stg).quant ) );
            
            obs_e = brier_score.parse( matchedData(:, "observation") );
            
            for ref = 5:length(signalsnames)
                for_e = brier_score.parse( matchedData(:, signalsnames(ref) ) );
                p = brier_score.calculate(for_e, obs_e);
                
                efsrProbScores{bs_settings(stg).name, signalsnames(ref)}{1}(aggT, sT) = p;
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
                    brier_score.boundaries( brier_score.extract_bounds( matchedData(:, pos), bs_settings(stg).quant ) );
                end
                for_e = brier_score.parse( matchedData(:, pos) );
                p = brier_score.calculate(for_e, obs_e);

                efsrProbScores{bs_settings(stg).name, signalsnames(ref)}{1}(aggT, sT) = p;
            end
        end
    end
    
end
%%
clear aggT aT bf df for_e idx jdx k matchedData obs obs_e oNan p pos pos_ 
clear ref scoresnames signals signalsnames sT lT stg sTmax w
clear efsrDetForecast