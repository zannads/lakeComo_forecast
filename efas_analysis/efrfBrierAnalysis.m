%% efrf
aT = std_aggregation( efrfForecast(1).valid_agg_time( std_aggregation ) );
lTmax = efrfForecast(1).max_leadTime( aT );

benchmark = [averageForecast, cicloForecast.prob2det( 'average' ), conForecast];

%% prob
% create settings
quant2test = [1/20, 1/10:1/10:9/10, 19/20];
bs_settings(1,8*length(quant2test)) = struct('type', [], 'bias', [], 'quant', [], 'name', [] );
UB_B = ["U", "B"];
for idx = 1:length(quant2test)
    bs_settings(idx).type = 'annual';
    bs_settings(idx).bias = false;
    bs_settings(idx).quant = quant2test(idx);
    bs_settings(idx).name = UB_B(bs_settings(idx).bias+1) + "bs_" +bs_settings(idx).type + num2str(bs_settings(idx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+length(quant2test);
    bs_settings(jdx).type = 'quarterly';
    bs_settings(jdx).bias = false;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+2*length(quant2test);
    bs_settings(jdx).type = 'monthly';
    bs_settings(jdx).bias = false;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+3*length(quant2test);
    bs_settings(jdx).type = 'daily';
    bs_settings(jdx).bias = false;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+4*length(quant2test);
    bs_settings(jdx).type = 'annual';
    bs_settings(jdx).bias = true;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+5*length(quant2test);
    bs_settings(jdx).type = 'quarterly';
    bs_settings(jdx).bias = true;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+6*length(quant2test);
    bs_settings(jdx).type = 'monthly';
    bs_settings(jdx).bias = true;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+7*length(quant2test);
    bs_settings(jdx).type = 'daily';
    bs_settings(jdx).bias = true;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end

signalsnames = [cat(2, efrfForecast.name), cat(2, benchmark.name) ];
scoresnames = cat(2, bs_settings.name);

efrfBrierScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames)),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Scores', 'Signals'});

for idx = 1:length( scoresnames )
    for jdx = 1:length(signalsnames)
        efrfBrierScores{idx,jdx}{1} = repmat( brier_score.empty, length(aT), max(lTmax));
    end
end
efrfBrierScores = addprop(efrfBrierScores, 'agg_times', 'table');
efrfBrierScores.Properties.CustomProperties.agg_times = aT;
efrfBrierScores = addprop(efrfBrierScores, 'quant2test', 'table');
efrfBrierScores.Properties.CustomProperties.quant2test = quant2test;


signals = [efrfForecast, benchmark];

for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % obs
    obs = qAgg(:, w);
    oNan = isnan(obs.(1));
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    
    df = getTimeSeries( signals, aT(aggT), 0, false );
    
    matchedData = synchronize( obs, df,'intersection' );
    
    for stg =  1:length( bs_settings)
        
        bnd = brier_score.extract_bounds( matchedData(:, "observation"), bs_settings(stg).quant, bs_settings(stg).type  );
        
        obs_e = brier_score.parse( matchedData(:, "observation"), bnd, bs_settings(stg).type );
        
        for ref = 5:length(signalsnames)
            for_e = brier_score.parse( matchedData(:, signalsnames(ref) ), bnd, bs_settings(stg).type );
            p = brier_score.calculate(for_e, obs_e);
            
            efrfBrierScores{bs_settings(stg).name, signalsnames(ref)}{1}(aggT, 1) = p;
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
            
            efrfBrierScores{bs_settings(stg).name, signalsnames(ref)}{1}(aggT, 1) = p;
        end
    end
end
%%
clear aggT aT bf df for_e idx jdx k matchedData obs obs_e oNan p pos pos_ ans bnd UB_B
clear ref scoresnames signals signalsnames stg w quant2test B_UB bs_settings