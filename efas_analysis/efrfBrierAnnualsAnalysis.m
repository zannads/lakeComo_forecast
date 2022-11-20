%% efrf
aT = std_aggregation( efrfForecast(1).valid_agg_time( std_aggregation ) );
lTmax = efrfForecast(1).max_leadTime( aT );

%benchmark = [averageForecast, cicloForecast.prob2det( 'average' ), conForecast];

%% prob
% create settings
quant2test = [1/50, 1/20, 1/10, 1/5, 4/5, 9/10, 19/20, 49/50];
bs_settings(1,2*length(quant2test)) = struct('type', [], 'bias', [], 'quant', [], 'name', [] );
UB_B = ["U", "B"];
for idx = 1:length(quant2test)
    bs_settings(idx).type = 'annual';
    bs_settings(idx).bias = false;
    bs_settings(idx).quant = quant2test(idx);
    bs_settings(idx).name = UB_B(bs_settings(idx).bias+1) + "bs_" +bs_settings(idx).type + num2str(bs_settings(idx).quant);
end
for idx = 1:length(quant2test)
    jdx = idx+length(quant2test);
    bs_settings(jdx).type = 'annual';
    bs_settings(jdx).bias = true;
    bs_settings(jdx).quant = quant2test(idx);
    bs_settings(jdx).name = UB_B(bs_settings(jdx).bias+1) + "bs_" +bs_settings(jdx).type + num2str(bs_settings(jdx).quant);
end

%signalsnames = [cat(2, efrfForecast.name), cat(2, benchmark.name) ];
signalsnames = cat(2, efrfForecast.name);
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

% signals = [efrfForecast, benchmark];
signals = efrfForecast;

for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % obs
    obs = qAgg(:, w);
    oNan = isnan(obs.(1));
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    df4bnd = getTimeSeries( signals, aT(aggT), 0, true ); % get a complete one to extract bounds later
    
    for lT = 1:lTmax(aggT)
        df = getTimeSeries( signals, aT(aggT), lT-1, false );
        
        matchedData = synchronize( obs, df,'intersection' );
        
        for stg =  1:length( bs_settings)
            
            % instead of doing it for only the matchedData I will do it for obs in
            % order to have more point since we are doing annual
            bnd = brier_score.extract_bounds( obs, bs_settings(stg).quant, bs_settings(stg).type  );
            
            obs_e = brier_score.parse( matchedData(:, "observation"), bnd, bs_settings(stg).type );
            
            
            for ref = 1:4
                pos = false(45,1);
                pos( (1:11)+(ref-1)*11 ) = true(11,1);
                
                if ~bs_settings(stg).bias
                    %reset quantile
                    bnd = brier_score.extract_bounds( df4bnd(:, pos(1:end-1)), bs_settings(stg).quant, bs_settings(stg).type );
                end
                for_e = brier_score.parse( matchedData(:, pos), bnd, bs_settings(stg).type  );
                
                p = brier_score.calculate(for_e, obs_e);
                
                efrfBrierScores{bs_settings(stg).name, signalsnames(ref)}{1}(aggT, lT) = p;
            end
        end
    end
end
    %%
    clear aggT aT bf df for_e idx jdx k matchedData obs obs_e oNan p pos pos_ ans bnd UB_B
    clear ref scoresnames signals signalsnames stg w quant2test B_UB bs_settings lT df4bnd