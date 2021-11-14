%% EFSR
agg_times = efsrFdetStats.agg_times;
for idx = 1:length(agg_times)
    % aggregate the forecast with the lead time
    fa = aggregate_forecast( efsrForecastAE, agg_times(idx) );
    ff = aggregate_forecast( efsrForecastFE, agg_times(idx) );
    
    %aggregate the historical to compute the indicators
    h = aggregate_benchmark( fa, historical, agg_times(idx) );
    
    %aggregate the benchmarks to compute their indicators and compare with
    %forecats
    % the average is always the same, indipendent of the aggregation time,
    % so I extract the dates I need
    matchedData = synchronize( fa, ...
        timetable(historical.Time, averageDetForecast*ones( size(historical.dis24 ) ) ),...
        'intersection' );
    av = matchedData(:, 2);
    
    cs = aggregate_benchmark( fa, cicloDetForecast(:,1), agg_times(idx) );
    % consistency is the same as the aggregation of the historical, but
    % shifted of one aggregation time step. The flow in the next x day is
    % the same as the fow of the previous x days, so i should aggregate
    % backward.
    con = aggregate_benchmark( fa, ...
        timetable( historical.Time+1, historical.dis24 ), ...
        agg_times(idx), 'backward' );
    
    %     figure, plot( h.Time, h.(1)); hold on;
    % plot( fa.Time, fa.(1));
    % plot( av.Time, av.(1));
    % plot( cs.Time, cs.(1));
    % plot( con.Time, con.(1));
    % title( h.Properties.VariableNames{1} );
    % legend( 'hist', 'first', 'ave', 'ciclo', 'cons' );
    
    %compute and save indicators
    %% Average ensamble member
    p = KGE( fa, h, 'Standard' );
    efsrFAEdetStats.kge(idx) = p.kge;
    efsrFAEdetStats.r(idx) = p.r ;
    efsrFAEdetStats.alpha(idx) = p.alpha ;
    efsrFAEdetStats.beta(idx) = p.beta ;
    p = KGE( fa, h, 'Modified' );
    efsrFAEdetStats.kge_mod(idx) = p.kge;
    efsrFAEdetStats.gamma(idx) = p.gamma ;
    p = NSE( fa, h );
    efsrFAEdetStats.nse(idx) = p.nse;
    efsrFAEdetStats.ve(idx) = VE( fa, h );
    
    %% first ensamble member
    p = KGE( ff, h, 'Standard' );
    efsrFFEdetStats.kge(idx) = p.kge;
    efsrFFEdetStats.r(idx) = p.r ;
    efsrFFEdetStats.alpha(idx) = p.alpha ;
    efsrFFEdetStats.beta(idx) = p.beta ;
    p = KGE( ff, h, 'Modified' );
    efsrFFEdetStats.kge_mod(idx) = p.kge;
    efsrFFEdetStats.gamma(idx) = p.gamma ;
    p = NSE( ff, h );
    efsrFFEdetStats.nse(idx) = p.nse;
    efsrFFEdetStats.ve(idx) = VE( ff, h );
    
    %% benchmarks
    p = KGE( av, h, 'Standard' );
    av_efsrFdetStats.kge(idx) = p.kge;
    av_efsrFdetStats.r(idx) = p.r ;
    av_efsrFdetStats.alpha(idx) = p.alpha ;
    av_efsrFdetStats.beta(idx) = p.beta ;
    p = KGE( av, h, 'Modified' );
    av_efsrFdetStats.kge_mod(idx) = p.kge;
    av_efsrFdetStats.gamma(idx) = p.gamma ;
    p = NSE( av, h );
    av_efsrFdetStats.nse(idx) = p.nse;
    av_efsrFdetStats.ve(idx) = VE( av, h );
    
    p = KGE( cs, h, 'Standard' );
    cs_efsrFdetStats.kge(idx) = p.kge;
    cs_efsrFdetStats.r(idx) = p.r ;
    cs_efsrFdetStats.alpha(idx) = p.alpha ;
    cs_efsrFdetStats.beta(idx) = p.beta ;
    p = KGE( cs, h, 'Modified' );
    cs_efsrFdetStats.kge_mod(idx) = p.kge;
    cs_efsrFdetStats.gamma(idx) = p.gamma ;
    p = NSE( cs, h );
    cs_efsrFdetStats.nse(idx) = p.nse;
    cs_efsrFdetStats.ve(idx) = VE( cs, h );
    
    
    p = KGE( con, h, 'Standard' );
    con_efsrFdetStats.kge(idx) = p.kge;
    con_efsrFdetStats.r(idx) = p.r ;
    con_efsrFdetStats.alpha(idx) = p.alpha ;
    con_efsrFdetStats.beta(idx) = p.beta ;
    p = KGE( con, h, 'Modified' );
    con_efsrFdetStats.kge_mod(idx) = p.kge;
    con_efsrFdetStats.gamma(idx) = p.gamma ;
    p = NSE( con, h );
    con_efsrFdetStats.nse(idx) = p.nse;
    con_efsrFdetStats.ve(idx) = VE( con, h );
    
end
clear p matchedData fa ff h av cs con

kgePlot = figure;
plot( agg_times, efsrFAEdetStats.kge, '-b' );
hold on;
plot( agg_times, efsrFFEdetStats.kge, '-m' );
plot( agg_times, av_efsrFdetStats.kge, '-y' );
plot( agg_times, cs_efsrFdetStats.kge, '-r' );
plot( agg_times, con_efsrFdetStats.kge, '-g' );
title( 'KGE' );
xlabel( 'Aggregation time' );
ylabel( 'KGE' );
legend( 'Average ensamble', 'First ensamble', 'average', 'ciclo', 'consistency' );
clear agg_times