%% efrs
bN = 1+1+6;
posV = {'LakeComo', 'Fuentes', 'Mandello', 'Olginate'};
aT = std_aggregation( efsrForecast.valid_agg_time( std_aggregation ) );

%% det
signalsnames = [{'Fuentes_ave', 'Fuentes_first', 'Mandello_ave', 'Mandello_first',...
    'LakeComo_ave', 'LakeComo_first', 'Olginate_ave', 'Olginate_first', ...
    'average', 'ciclostationary'}, conDetForecast.Properties.VariableNames];
scoresnames = {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma', 'nse', 've'};
efsrDetScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames) ),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Score', 'Signal'});
for idx = 1:length(scoresnames)
    for jdx = 1:length(signalsnames)
        efsrDetScores{idx,jdx}{1} = nan(length(aT),7);
    end
end
efsrDetScores = addprop(efsrDetScores, 'agg_times', 'table');
efsrDetScores.Properties.CustomProperties.agg_times = aT;

%%
pos = [{'LakeComo_ave', 'LakeComo_first', 'average', 'ciclostationary'}, conDetForecast.Properties.VariableNames];
efsrForecast = efsrForecast.upload( 'efsr', eval( posV{1} ) );
for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    % sim
    s_1 = efsrForecast.aggregate( aT(aggT), 'Which', 'average' );
    s_2 = efsrForecast.aggregate( aT(aggT), 'Which', 'first' );
    % benchmarks
    ave = averageDetForecast(:, w);
    cic = cicloDetForecast(:, w );
    con = conDetForecast;
    % obs
    o = hAgg(:, w );
    oNan = isnan(o.(1));
    o = o(~oNan, :);
    
    for lT = 1:width(s_1)
        disp(lT);
        
        matchedData = synchronize( s_1(:,lT), s_2(:,lT), con, 'intersection' );
        matchedData = extractLT( matchedData, lT-1 );
        
        matchedData = synchronize(o, matchedData(:, 1:2), ave, cic, matchedData(:,3:end), 'intersection' );
        
        matchedData.Properties.VariableNames(1:5) = {'observation', 'sim_ave', 'sim_first', 'average', 'ciclo'};
        
        for ref = 1:size( matchedData, 2 )-1
            p = KGE( matchedData(:, ref+1), matchedData(:, 'observation'), 'Standard' );
            efsrDetScores{'kge', pos(ref)}{1}(aggT, lT) = p.kge;
            efsrDetScores{'r', pos(ref)}{1}(aggT, lT) = p.r;
            efsrDetScores{'alpha', pos(ref)}{1}(aggT, lT) = p.alpha;
            efsrDetScores{'beta', pos(ref)}{1}(aggT, lT) = p.beta;
            
            p = KGE( matchedData(:, ref+1), matchedData(:, 'observation'), 'Modified' );
            efsrDetScores{'kge_mod', pos(ref)}{1}(aggT, lT) = p.kge;
            efsrDetScores{'gamma', pos(ref)}{1}(aggT, lT) = p.gamma;
            
            p = NSE( matchedData(:, ref+1), matchedData(:, 'observation') );
            efsrDetScores{'nse', pos(ref)}{1}(aggT, lT) = p.nse;
            
            efsrDetScores{'ve', pos(ref)}{1}(aggT, lT)  = VE( matchedData(:, ref+1), matchedData(:, 'observation') );
        end
    end
end
%% other positions
pos = {'Fuentes_ave', 'Fuentes_first', 'Mandello_ave', 'Mandello_first',...
    'Olginate_ave', 'Olginate_first'};
for where = 2:4
    posV{where}
    efsrForecast = efsrForecast.upload( 'efsr', eval( posV{where} ) );
    
    for aggT = 1:length(aT)
        aT(aggT)
        w = strcat( "agg_", string( aT(aggT) ) );
        % sim
        s_1 = efsrForecast.aggregate( aT(aggT), 'Which', 'average' );
        s_2 = efsrForecast.aggregate( aT(aggT), 'Which', 'first' );
        % benchmarks
        %not needed
        
        % obs
        o = hAgg(:, w );
        oNan = isnan(o.(1));
        o = o(~oNan, :);
        
        for lT = 1:width(s_1)
            disp(lT);
            
            matchedData = synchronize( s_1(:,lT), s_2(:,lT), 'intersection' );
            matchedData = extractLT( matchedData, lT-1 );
            
            matchedData = synchronize(o, matchedData(:, 1:2), 'intersection');
            
            matchedData.Properties.VariableNames(1:3) = {'observation', 'sim_ave', 'sim_first'};
            
            for ref = 1:size( matchedData, 2 )-1 % should be 2
                q = (where-2)*2+ref;
                pos(q)
                p = KGE( matchedData(:, ref+1), matchedData(:, 'observation'), 'Standard' );
                efsrDetScores{'kge', pos(q)}{1}(aggT, lT) = p.kge;
                efsrDetScores{'r', pos(q)}{1}(aggT, lT) = p.r;
                efsrDetScores{'alpha', pos(q)}{1}(aggT, lT) = p.alpha;
                efsrDetScores{'beta', pos(q)}{1}(aggT, lT) = p.beta;
                
                p = KGE( matchedData(:, ref+1), matchedData(:, 'observation'), 'Modified' );
                efsrDetScores{'kge_mod', pos(q)}{1}(aggT, lT) = p.kge;
                efsrDetScores{'gamma', pos(q)}{1}(aggT, lT) = p.gamma;
                
                p = NSE( matchedData(:, ref+1), matchedData(:, 'observation') );
                efsrDetScores{'nse', pos(q)}{1}(aggT, lT) = p.nse;
                
                efsrDetScores{'ve', pos(q)}{1}(aggT, lT)  = VE( matchedData(:, ref+1), matchedData(:, 'observation') );
            end
        end
    end
end


%% prob
signalsnames = [{'Fuentes', 'Mandello', 'LakeComo', 'Olginate', 'average', 'ciclostationary'}, conDetForecast.Properties.VariableNames];
scoresnames = {'crps', ...
    'bs_annual_1/3_2/3', 'rel_annual_1/3_2/3', 'res_annual_1/3_2/3', 'unc_annual_1/3_2/3', ...
    'bs_seasonal_1/3_2/3', 'rel_seasonal_1/3_2/3', 'res_seasonal_1/3_2/3', 'unc_seasonal_1/3_2/3', ...
    'bs_monthly_1/3_2/3', 'rel_monthly_1/3_2/3', 'res_monthly_1/3_2/3', 'unc_monthly_1/3_2/3', ...
    'bs_seasonal_1/3_2/3ub', 'rel_seasonal_1/3_2/3ub', 'res_seasonal_1/3_2/3ub', 'unc_seasonal_1/3_2/3ub',...
    'bs_seasonal_1/20ub', 'rel_seasonal_1/20ub', 'res_seasonal_1/20ub', 'unc_seasonal_1/20ub', ...
    'bs_seasonal_1/10ub', 'rel_seasonal_1/10ub', 'res_seasonal_1/10ub', 'unc_seasonal_1/10ub', ...
    'bs_seasonal_9/10ub', 'rel_seasonal_9/10ub', 'res_seasonal_9/10ub', 'unc_seasonal_9/10ub', ...
    'bs_seasonal_19/20ub', 'rel_seasonal_19/20ub', 'res_seasonal_19/20ub', 'unc_seasonal_19/20ub'};
efsrProbScores = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, 12),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Scores', 'Signals'});
for idx = 1:5
    for jdx = 1:length(signalsnames)
        efsrProbScores{idx,jdx}{1} = nan(length(aT),7);
    end
end
for idx = 6:9
    for jdx = 1:length(signalsnames)
        efsrProbScores{idx,jdx}{1} = nan(length(aT),7, 4);
    end
end
for idx = 10:13
    for jdx = 1:length(signalsnames)
        efsrProbScores{idx,jdx}{1} = nan(length(aT),7, 12);
    end
end
for idx = 14:33
    for jdx = 1:length(signalsnames)
        efsrProbScores{idx,jdx}{1} = nan(length(aT),7, 4);
    end
end
efsrProbScores = addprop(efsrProbScores, 'agg_times', 'table');
efsrProbScores.Properties.CustomProperties.agg_times = aT;

%% crps
efsrForecast = efsrForecast.upload( 'efsr', eval( posV{1} ) );
for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % sim
    s_1 = efsrForecast.aggregate( aT(aggT), 'Which', 'all' );
    % benchmarks
    ave = averageDetForecast(:, w);
    cic = cicloDetForecast(:, w );
    con = conDetForecast;
    % obs
    o = hAgg(:, w );
    oNan = isnan(o.(1));
    o = o(~oNan, :);
    
    for lT = 1:s_1.leadTime
        disp(lT)
        s = compress( s_1, 'LeadTime', lT );
        en = size( s, 2);
        
        matchedData = synchronize( s, con, 'intersection' );
        matchedData = extractLT( matchedData, lT-1 );
        
        matchedData = synchronize(o, matchedData(:, 1:en), ave, cic, matchedData(:,(en+1):end), 'intersection' );
        %matchedData = [{'observation'}, s.Properties.VariableNames,
        %{'average', 'ciclostationary'}];
        

        efsrProbScores{'crps', 'LakeComo'}{1}(aggT,lT) = ...
            crps( matchedData(:, (1:en)+1).Variables, matchedData(:,1).Variables);
        for ref = 1:bN
            efsrProbScores{'crps', ref+4}{1}(aggT,lT) = ...
                MAE( matchedData(:, ref+en+1), matchedData(:,1));
        end
        
    end
end
%% other pos
for where = 2:4
    efsrForecast = efsrForecast.upload( 'efsr', eval( posV{where} ) );
    for aggT = 1:length(aT)
        aT(aggT)
        w = strcat( "agg_", string( aT(aggT) ) );
        
        % sim
        s_1 = efsrForecast.aggregate( aT(aggT), 'Which', 'all' );
        % benchmarks
        
        
        % obs
        o = hAgg(:, w );
        oNan = isnan(o.(1));
        o = o(~oNan, :);
        
        for lT = 1:s_1.leadTime
            disp(lT)
            s = compress( s_1, 'LeadTime', lT );
            en = size( s, 2);
            
            s = extractLT( s, lT-1 );
            
            matchedData = synchronize(o, s, 'intersection' );
            
            efsrProbScores{'crps', posV{where}}{1}(aggT,lT) = ...
                crps( matchedData(:, (1:en)+1).Variables, matchedData(:,1).Variables);
            
        end
    end
end
%% bs
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


efsrForecast = efsrForecast.upload( 'efsr', eval( posV{1} ) );

for aggT = 1:length(aT)
    aT(aggT)
    w = strcat( "agg_", string( aT(aggT) ) );
    
    % sim
    s_1 = efsrForecast.aggregate( aT(aggT), 'Which', 'all' );
    % benchmarks
    ave = averageDetForecast(:, w);
    cic = cicloDetForecast(:, w );
    con = conDetForecast;
    % obs
    o = hAgg(:, w );
    oNan = isnan(o.(1));
    o = o(~oNan, :);
    
    for stg =  1:length( bs_settings)
        
        brier_score.type( bs_settings(stg).type )
        
        
        for lT = 1:s_1.leadTime
            disp(lT)
            s = compress( s_1, 'LeadTime', lT );
            en = size( s, 2);
            
            matchedData = synchronize( s, con, 'intersection' );
            matchedData = extractLT( matchedData, lT-1 );
            
            matchedData = synchronize(o, matchedData(:, 1:en), ave, cic, matchedData(:,(en+1):end), 'intersection' );
            %matchedData = [{'observation'}, s.Properties.VariableNames,
            %{'average', 'ciclostationary'}];
            
            brier_score.boundaries( brier_score.extract_bounds( o, bs_settings(stg).quant ) );
            
            obs = brier_score.parse( matchedData(:,1) );
            
            for ref = 1:bN
                fore = brier_score.parse( matchedData(:, 1+en+ref) );
                p = brier_score.calculate(fore, obs);
                
                efsrProbScores{(stg-1)*4+2, ref+4}{1}(aggT, lT, :) = ...
                    p.bs;
                efsrProbScores{(stg-1)*4+3, ref+4}{1}(aggT, lT, :) = ...
                    p.rel;
                efsrProbScores{(stg-1)*4+4, ref+4}{1}(aggT, lT, :) = ...
                    p.res;
                efsrProbScores{(stg-1)*4+5, ref+4}{1}(aggT, lT, :) = ...
                    p.unc;
                
            end
            
            if ~bs_settings(stg).bias
                %reset quantile
                brier_score.boundaries( brier_score.extract_bounds( matchedData(:, (1:en)+1), bs_settings(stg).quant ) );
            end
            fore = brier_score.parse( matchedData(:, (1:en)+1) );
            p = brier_score.calculate(fore, obs);
            
            efsrProbScores{(stg-1)*4+2, 'LakeComo'}{1}(aggT, lT, :) = ...
                    p.bs;
                efsrProbScores{(stg-1)*4+3, 'LakeComo'}{1}(aggT, lT, :) = ...
                    p.rel;
                efsrProbScores{(stg-1)*4+4, 'LakeComo'}{1}(aggT, lT, :) = ...
                    p.res;
                efsrProbScores{(stg-1)*4+5, 'LakeComo'}{1}(aggT, lT, :) = ...
                    p.unc;
        end
    end
    
end

%%
for where = 2:4
    efsrForecast = efsrForecast.upload( 'efsr', eval( posV{where} ) );
    
    for aggT = 1:length(aT)
        aT(aggT)
        w = strcat( "agg_", string( aT(aggT) ) );
        
        % sim
        s_1 = efsrForecast.aggregate( aT(aggT), 'Which', 'all' );
        % benchmarks
        
        % obs
        o = hAgg(:, w );
        oNan = isnan(o.(1));
        o = o(~oNan, :);
        
        for stg =  1:length( bs_settings)
            
            brier_score.type( bs_settings(stg).type )
            
            
            for lT = 1:s_1.leadTime
                disp(lT)
                s = compress( s_1, 'LeadTime', lT );
                en = size( s, 2);
                
                s = extractLT( s, lT-1 );
                
                matchedData = synchronize(o, s, 'intersection' );
                
                brier_score.boundaries( brier_score.extract_bounds( o, bs_settings(stg).quant ) );
            
                obs = brier_score.parse( matchedData(:,1) );
                
                if ~bs_settings(stg).bias
                    %reset quantile
                    brier_score.boundaries( brier_score.extract_bounds( matchedData(:, (1:en)+1), bs_settings(stg).quant ) );
                end
                fore = brier_score.parse( matchedData(:, (1:en)+1) );
                p = brier_score.calculate(fore, obs);
                
                efsrProbScores{(stg-1)*4+2, posV{where}}{1}(aggT, lT, :) = ...
                    p.bs;
                efsrProbScores{(stg-1)*4+3, posV{where}}{1}(aggT, lT, :) = ...
                    p.rel;
                efsrProbScores{(stg-1)*4+4, posV{where}}{1}(aggT, lT, :) = ...
                    p.res;
                efsrProbScores{(stg-1)*4+5, posV{where}}{1}(aggT, lT, :) = ...
                    p.unc;
            end
        end
        
    end
end

%% 
clear p fore bs_settings stg where posV pos aggT lT obs matchedData s s_1 s_2
clear o oNan w en ave cic con signalsnames scoresnames bN aT idx jdx q ref