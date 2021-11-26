%% efrf
% aggiungere un giorno per compensare il fatto che la previsione di oggi è
% confrontata domani
%% det
aT = std_aggregation( efrfForecast.valid_agg_time( std_aggregation ) );
for idx = 1:length(aT)
    aT(idx)
    disp('Average');
    % sim
    s_ = efrfForecast.aggregate( aT(idx), 'Which', 'average' );
    % obs
    o = h(:, strcat( "agg_", string( aT(idx) ) ) );
    for kdx = 1:width(s_)
        disp(kdx);
        s = s_(:, kdx);
        
        matchedData = synchronize( s, o, 'intersection' );
        matchedData.Properties.VariableNames = { 'simulation','observation'};
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Standard' );
        efrfForecast.average_detStats.kge(idx, kdx) = p.kge;
        efrfForecast.average_detStats.r(idx, kdx) = p.r ;
        efrfForecast.average_detStats.alpha(idx, kdx) = p.alpha ;
        efrfForecast.average_detStats.beta(idx, kdx) = p.beta ;
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Modified' );
        efrfForecast.average_detStats.kge_mod(idx, kdx) = p.kge;
        efrfForecast.average_detStats.gamma(idx, kdx) = p.gamma ;
        
        p = NSE( matchedData(:,1), matchedData(:,2) );
        efrfForecast.average_detStats.nse(idx, kdx) = p.nse;
        
        efrfForecast.average_detStats.ve(idx, kdx) = VE( matchedData(:,1), matchedData(:,2) );
    end
    
    disp('First');
    %now the first ensamble only
    s_ = efrfForecast.aggregate( aT(idx), 'Which', 'first' );
    for kdx = 1:width(s_)
        disp(kdx);
        s = s_(:, kdx);
        
        matchedData = synchronize( s, o, 'intersection' );
        matchedData.Properties.VariableNames = { 'simulation','observation'};
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Standard' );
        efrfForecast.first_detStats.kge(idx, kdx) = p.kge;
        efrfForecast.first_detStats.r(idx, kdx) = p.r ;
        efrfForecast.first_detStats.alpha(idx, kdx) = p.alpha ;
        efrfForecast.first_detStats.beta(idx, kdx) = p.beta ;
        
        p = KGE( matchedData(:,1), matchedData(:,2), 'Modified' );
        efrfForecast.first_detStats.kge_mod(idx, kdx) = p.kge;
        efrfForecast.first_detStats.gamma(idx, kdx) = p.gamma ;
        
        p = NSE( matchedData(:,1), matchedData(:,2) );
        efrfForecast.first_detStats.nse(idx, kdx) = p.nse;
        
        efrfForecast.first_detStats.ve(idx, kdx) = VE( matchedData(:,1), matchedData(:,2) );
    end
end

%% prob
%% crps
for idx = 1:length(aT)
    aT(idx)
    
    % sim
    s_ = efrfForecast.aggregate( aT(idx), 'Which', 'all' );
    % obs
    o_ = h(:, strcat( "agg_", string( aT(idx) ) ) );
    for kdx = 1:s_.leadTime
        kdx
        s = compress( s_, 'LeadTime', kdx );
        
        matchedData = synchronize( s, o_, 'intersection' );
        matchedData = table2array( timetable2table( ...
            matchedData, 'ConvertRowTimes', false ) );
        
        o = matchedData(:,end);
        s = matchedData(:, 1:end-1);
        
        efrfForecast.probStats.crps(idx,kdx) = crps(s, o);
    end
end
efrfForecast.probStats.crps( efrfForecast.probStats.crps==0 ) = nan;

%% bs
b = { 'annual', 'seasonal', 'monthly', 'daily' };
efrfForecast.probStats.annual_bs = struct( 'bs', nan(length(aT), 7), ...
    'rel', nan(length(aT), 7), ...
    'res', nan(length(aT), 7), ...
    'unc', nan(length(aT), 7) );
efrfForecast.probStats.seasonal_bs = struct( 'bs', nan(length(aT), 7), ...
    'rel', nan(length(aT), 7), ...
    'res', nan(length(aT), 7), ...
    'unc', nan(length(aT), 7) );
efrfForecast.probStats.monthly_bs = struct( 'bs', nan(length(aT), 7), ...
    'rel', nan(length(aT), 7), ...
    'res', nan(length(aT), 7), ...
    'unc', nan(length(aT), 7) );
efrfForecast.probStats.daily_bs = struct( 'bs', nan(1, 7), ...
    'rel', nan(1, 7), ...
    'res', nan(1, 7), ...
    'unc', nan(1, 7) );

for idx = 1:length(aT)
    aT(idx)
    
    % sim
    s_ = efrfForecast.aggregate( aT(idx), 'Which', 'all' );
    % obs
    o_ = h(:, strcat( "agg_", string( aT(idx) ) ) );
    %set the terciles as boundaries
    brier_score.boundaries( brier_score.extract_tercile(  o_ ) );

    
    c = 4;
    % if agg_time is more then 1 day it doesn't make sense to use daily
    % aggregation
    if idx >1
        c = 3;
    end
    
    for kdx = 1:c
        kdx
        % find where to save
        where = fieldnames( efrfForecast.probStats );
        where = where{kdx+1};
        
        % set the new type
        brier_score.type( b{kdx} );
        
        for jdx = 1:s_.leadTime
            jdx
            
            s = compress( s_, 'LeadTime', jdx );
            
            matchedData = synchronize( s, o_, 'intersection' );
            
            o = matchedData(:,end);
            s = matchedData(:, 1:end-1);
            
            bs = brier_score.calculate( s, o );
            
            efrfForecast.probStats.(where).bs(idx, jdx) = bs.bs;
            efrfForecast.probStats.(where).rel(idx, jdx) = bs.rel;
            efrfForecast.probStats.(where).res(idx, jdx) = bs.res;
            efrfForecast.probStats.(where).unc(idx, jdx) = bs.unc;
            
        end
    end
end

%%
clear aT idx jdx matchedData s o s_ p
