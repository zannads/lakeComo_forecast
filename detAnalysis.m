%% KGE PROGEA
for idx = 1:3
    df = detForecast(:, idx );
    df.Time = df.Time + caldays(idx);
    matchedData = synchronize( historical, df, 'intersection' );
    matchedData.Properties.VariableNames = {'observation', 'simulation'};
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Standard' );
    detForecast.Properties.CustomProperties.kge(idx) = p.kge;
    detForecast.Properties.CustomProperties.r(idx) = p.r ;
    detForecast.Properties.CustomProperties.alpha(idx) = p.alpha ;
    detForecast.Properties.CustomProperties.beta(idx) = p.beta ;
    
    p = KGE( matchedData(:, 2), matchedData(:, 1), 'Modified' );
    detForecast.Properties.CustomProperties.kge_mod(idx) = p.kge;
    detForecast.Properties.CustomProperties.gamma(idx) = p.gamma ;
    
    p = NSE( matchedData(:, 2), matchedData(:, 1) );
    detForecast.Properties.CustomProperties.nse(idx) = p.nse;
    
    detForecast.Properties.CustomProperties.ve(idx) = VE( matchedData(:, 2), matchedData(:, 1) );
end

clear df matchedData 
