%% KGE PROGEA

% synch periods 

% aggregation time : 1 day 
aggT = 1;
for lT = 1:3
    df = detForecast(:, lT );
    df.Time = df.Time + caldays(lT);
    
    ave = averageDetForecast(:, 'agg_1d' );
    cic = cicloDetForecast(:, 'agg_1d' );
    con = conDetForecast;
    con.Time = con.Time + caldays( lT-1 ); % for the way has been built it is already with one lead day.
    
    matchedData = synchronize( historical, df, ave, cic, con,'intersection' );
   
    matchedData.Properties.VariableNames(1:4) = {'observation', 'simulation', 'average', 'ciclo'};
    
    for ref = 1:size( matchedData, 2 )-1
        p = KGE( matchedData(:, ref+1), matchedData(:, 'observation'), 'Standard' );
        detFScores.kge(aggT, lT, ref) = p.kge;
        detFScores.r(aggT, lT, ref) = p.r ;
        detFScores.alpha(aggT, lT, ref) = p.alpha ;
        detFScores.beta(aggT, lT, ref) = p.beta ;
        
        p = KGE( matchedData(:, ref+1), matchedData(:, 'observation'), 'Modified' );
        detFScores.kge_mod(aggT, lT, ref) = p.kge;
        detFScores.gamma(aggT, lT, ref) = p.gamma ;
        
        p = NSE( matchedData(:, ref+1), matchedData(:, 'observation') );
        detFScores.nse(aggT, lT, ref) = p.nse;
        
        detFScores.ve(aggT, lT, ref) = VE( matchedData(:, ref+1), matchedData(:, 'observation') );
    end
end

clear df matchedData con ave cic lT aggT detF p ref