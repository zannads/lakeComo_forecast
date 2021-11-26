%% efrs
%TODO LT = more then 1
% aggiungere un giorno per compensare il fatto che la previsione di oggi è
% confrontata domani
%% det
aT = std_aggregation( efsrForecast.valid_agg_time( std_aggregation ) );
for aggT = 1:length(aT)
    aT(aggT)
    disp('Average');
    % sim
    s_ = efsrForecast.aggregate( aT(aggT), 'Which', 'average' );
    
    for lT = 1:width(s_)
        disp(lT);
        s = s_(:, lT);
        % obs
        o = h(:, strcat( "agg_", string( aT(aggT) ) ) );
        o.Time = o.Time-lT;
        
        matchedData = synchronize( s, o, 'intersection' );
        matchedData.Properties.VariableNames = { 'simulation','observation'};
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Standard' );
        efsrForecast.average_detStats.kge(aggT, lT) = p.kge;
        efsrForecast.average_detStats.r(aggT, lT) = p.r ;
        efsrForecast.average_detStats.alpha(aggT, lT) = p.alpha ;
        efsrForecast.average_detStats.beta(aggT, lT) = p.beta ;
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Modified' );
        efsrForecast.average_detStats.kge_mod(aggT, lT) = p.kge;
        efsrForecast.average_detStats.gamma(aggT, lT) = p.gamma ;
        
        p = NSE( matchedData(:,1), matchedData(:,2) );
        efsrForecast.average_detStats.nse(aggT, lT) = p.nse;
        
        efsrForecast.average_detStats.ve(aggT, lT) = VE( matchedData(:,1), matchedData(:,2) );
    end
    
    disp('First');
    %now the first ensamble only
    s_ = efsrForecast.aggregate( aT(aggT), 'Which', 'first' );
    for lT = 1:width(s_)
        disp(lT);
        s = s_(:, lT);
        % obs
        o = h(:, strcat( "agg_", string( aT(aggT) ) ) );
        o.Time = o.Time-lT;
        
        matchedData = synchronize( s, o, 'intersection' );
        matchedData.Properties.VariableNames = { 'simulation','observation'};
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Standard' );
        efsrForecast.first_detStats.kge(aggT, lT) = p.kge;
        efsrForecast.first_detStats.r(aggT, lT) = p.r ;
        efsrForecast.first_detStats.alpha(aggT, lT) = p.alpha ;
        efsrForecast.first_detStats.beta(aggT, lT) = p.beta ;
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Modified' );
        efsrForecast.first_detStats.kge_mod(aggT, lT) = p.kge;
        efsrForecast.first_detStats.gamma(aggT, lT) = p.gamma ;
        
        p = NSE( matchedData(:,1), matchedData(:,2) );
        efsrForecast.first_detStats.nse(aggT, lT) = p.nse;
        
        efsrForecast.first_detStats.ve(aggT, lT) = VE( matchedData(:,1), matchedData(:,2) );
    end
end

%% prob
%% crps
for aggT = 1:length(aT)
    aT(aggT)
    
    % sim
    s_ = efsrForecast.aggregate( aT(aggT), 'Which', 'all' );
    
    for lT = 1:s_.leadTime
        lT
        s = compress( s_, 'LeadTime', lT );
        % obs
        o_ = h(:, strcat( "agg_", string( aT(aggT) ) ) );
        o_.Time = o_.Time-lT;
        
        matchedData = synchronize( s, o_, 'intersection' );
        matchedData = table2array( timetable2table( ...
            matchedData, 'ConvertRowTimes', false ) );
        
        o = matchedData(:,end);
        s = matchedData(:, 1:end-1);
        
        efsrForecast.probStats.crps(aggT,lT) = crps(s, o);
    end
end
efsrForecast.probStats.crps( efsrForecast.probStats.crps==0 ) = nan;

%% bs
b = { 'annual', 'seasonal', 'monthly', 'daily' };
efsrForecast.probStats.annual_bs = struct( 'bs', nan(length(aT), 7), ...
    'rel', nan(length(aT), 7), ...
    'res', nan(length(aT), 7), ...
    'unc', nan(length(aT), 7) );
efsrForecast.probStats.seasonal_bs = struct( 'bs', nan(length(aT), 7), ...
    'rel', nan(length(aT), 7), ...
    'res', nan(length(aT), 7), ...
    'unc', nan(length(aT), 7) );
efsrForecast.probStats.monthly_bs = struct( 'bs', nan(length(aT), 7), ...
    'rel', nan(length(aT), 7), ...
    'res', nan(length(aT), 7), ...
    'unc', nan(length(aT), 7) );
efsrForecast.probStats.daily_bs = struct( 'bs', nan(1, 7), ...
    'rel', nan(1, 7), ...
    'res', nan(1, 7), ...
    'unc', nan(1, 7) );

for aggT = 1:length(aT)
    aT(aggT)
    
    % sim
    s_ = efsrForecast.aggregate( aT(aggT), 'Which', 'all' );
    
    c = 4;
    % if agg_time is more then 1 day it doesn't make sense to use daily
    % aggregation
    if aggT >1
        c = 3;
    end
    
    for type = 1:c
        type
        % find where to save
        where = fieldnames( efsrForecast.probStats );
        where = where{type+1};
        
        % set the new type
        brier_score.type( b{type} );
        
        for lT = 1:s_.leadTime
            lT
            
            s = compress( s_, 'LeadTime', lT );
            % obs
            o_ = h(:, strcat( "agg_", string( aT(aggT) ) ) );
            o_.Time = o_.Time-lT;
            %set the terciles as boundaries
            brier_score.boundaries( brier_score.extract_tercile(  o_ ) );
            
            matchedData = synchronize( s, o_, 'intersection' );
            
            o = matchedData(:,end);
            s = matchedData(:, 1:end-1);
            
            bs = brier_score.calculate( s, o );
            
            efsrForecast.probStats.(where).bs(aggT, lT) = bs.bs;
            efsrForecast.probStats.(where).rel(aggT, lT) = bs.rel;
            efsrForecast.probStats.(where).res(aggT, lT) = bs.res;
            efsrForecast.probStats.(where).unc(aggT, lT) = bs.unc;
            
        end
    end
end

%%
clear bs matchedData o_ s_ o s c lT type aggT where b
