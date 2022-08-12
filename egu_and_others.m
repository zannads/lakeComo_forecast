temp = cat(1, ddpsol(cat(1,ddpsol.flag_ref)>0).J );
POPPareto.reference = temp(1:end-3, :);
clear temp

til = tiledlayout(1,3);
p2d = POPPareto.reference(:,2:3);
[qq, ord] = sort( p2d(:,1) );
p2d = [ qq, p2d(ord,2) ];

ax1 = nexttile;
plot( p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 8 );
ax1.ColorOrder = hex2rgb( [colors.black; colors.gray; colors.bluepres; colors.greenpres] );
xlim(ax1, [1000, 2000] )
ylim(ax1, [0, 50] )
title(ax1, 'Flood days : 4.5 [day/year]', 'FontSize', 14 );
grid on

ax2 = nexttile;
plot( p2d(:,1), p2d(:,2), 'LineStyle', ':', 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 12 );
ax2.ColorOrder = hex2rgb( [colors.black; colors.gray; colors.bluepres; colors.greenpres] );
xlim(ax2, [1000, 2000] )
ylim(ax2, [0, 50] )
title(ax2, 'Flood days : 6 [day/year]', 'FontSize', 14 );
grid on
l = legend;
l.FontSize = 14;

ax3 = nexttile;
plot( p2d(:,1), p2d(:,2), 'LineStyle', ':', 'LineWidth', 2, 'Marker', '.','MarkerSize', 12 );
ax3.ColorOrder = hex2rgb( [colors.black; colors.gray; colors.bluepres; colors.greenpres] );
xlim(ax3, [1000, 2000] )
ylim(ax3, [0, 50] )
title(ax3, 'Flood days : 12 [day/year]', 'FontSize', 14 );
grid on

til.Padding = 'compact';
til.TileSpacing = 'compact';
xlabel(til, 'Deficit [(m^3/s)^{eq}]');
ylabel(til, 'Low leve [day/year]');

sols = ( [BOP, IOP_qAgg21dAnom, IOP_LakeComo14dmeanAnom] );
steps = [4.2, 6, 12];
for idx = 1:3
    nexttile(idx);
    hold on
    for jdx = 1:length(sols)
        set = sols(jdx).reference;
        ref = [ round(set(:,1), 1), set(:,2), set(:,3) ];
        
        p2d = ref( ref(:,1) >= steps(idx) & ref(:,1) < steps(idx) + 0.5, 2:3);
        [qq, ord] = sort( p2d(:,1) );
        p2d = [ qq, p2d(ord,2) ];
        
        plot( p2d(:,1), p2d(:,2), '-o', 'LineWidth', 2 );
    end
end
   
l.String = {'POP', 'BOP(h_t,d_t)', 'IOP(h_t,d_t,pF_{21d,anom})', 'IOP(h_t,d_t,LC^{efrf}_{14d,anom})'};

%%
aver = nan(14, 4);
conr = nan(14, 4);

for idx = 1:4
    aver(:, idx) = efsrDetScores{ 'r', 1+(idx-1)*2 }{1}(:,1);
    conr(:, idx) = efsrDetScores{ 'r', idx*2 }{1}(:,1);
end

%%

quant2test = [1/20, 1/10:1/10:9/10, 19/20];
bs_settings(1,length(quant2test)) = struct('type', [], 'bias', [], 'quant', [], 'name', [] );
UB_B = ["U", "B"];
for idx = 1:length(quant2test)
    bs_settings(idx).type = 'daily';
    bs_settings(idx).bias = false;
    bs_settings(idx).quant = quant2test(idx);
    bs_settings(idx).name = UB_B(bs_settings(idx).bias+1) + "bs_" +bs_settings(idx).type + num2str(bs_settings(idx).quant);
end

signals = efrfForecast(3);
signalsnames = signals.name;
scoresnames = cat(2, bs_settings.name);

ScoreTab = table('Size', [length(scoresnames), length(signalsnames)], ...
    'VariableTypes', repmat("cell", 1, length(signalsnames)),...
    'VariableNames', signalsnames, 'RowNames', scoresnames, ...
    'DimensionNames', {'Scores', 'Signals'});

for idx = 1:length( scoresnames )
    for jdx = 1:length(signalsnames)
        ScoreTab{idx,jdx}{1} = repmat( brier_score.empty,1, signals.leadTime);
    end
end

ScoreTab = addprop(ScoreTab, 'quant2test', 'table');
ScoreTab.Properties.CustomProperties.quant2test = quant2test;

% per seasonal cambiare lT e signals variable!

for lT = 1:signals.leadTime
    % obs
    obs = qAgg(:, 'agg_1d');
    oNan = isnan(obs{:,1});
    obs = obs( ~oNan, 1);
    obs.Properties.VariableNames = "observation";
    
    df = getTimeSeries( signals, 1, lT-1, false ); 
    
    matchedData = synchronize( obs, df,'intersection' );
    
    for stg =  1:length( bs_settings )
        
        bnd = brier_score.extract_bounds( moving_average(obs(:, "observation")), bs_settings(stg).quant, bs_settings(stg).type  );
        
        obs_e = brier_score.parse( matchedData(:, "observation"), bnd, bs_settings(stg).type );
        
        %get an array of matching names,
        pos_ = strfind( matchedData.Properties.VariableNames', 'LakeComo' );
        % it is a cell array I need to conver it to logical
        pos = false( size(pos_) );
        for k = 1:length(pos)
            pos(k) = ~isempty( pos_{k} );
        end
        
        if ~bs_settings(stg).bias
            %reset quantile
            bnd = brier_score.extract_bounds( matchedData(:, 2), bs_settings(stg).quant, bs_settings(stg).type );
        end
        for_e = brier_score.parse( matchedData(:, pos), bnd, bs_settings(stg).type );
        
        p = brier_score.calculate(for_e, obs_e);
        
        ScoreTab{stg, 1}{1}(1, lT) = p;
        
    end
end
%%
lightB = [0.356862745098039,0.811764705882353,0.956862745098039];
darkB = [0.0196078431372549,0.0745098039215686,0.670588235294118];

bGrad = @(i,N) lightB + (darkB-lightB)*((i-1)/(N-1));

%ScoreTab = efrfBrierScores
%ScoreTab = efsrBrierScores
q2p = height(ScoreTab);
lT = size( ScoreTab{1,1}{1}, 2);

figure
hold on
for idx = 1:q2p
    
    l2p = mean( cat(1, ScoreTab{idx,1}{1}.bs ), 2, 'omitnan' );
    lines(idx) = plot( 1:lT, l2p, 'Color', bGrad(idx, q2p ) ); 
end
lg = legend(lines, string( ScoreTab.Properties.CustomProperties.quant2test ) );


%%
% seleziono il periodo 14d
ts = efrfForecast(3).getTimeSeries( 14, 0, true);

% li medio e genero la ciclostaz
tsmedio  = ts(:,1);
tsmedio{:,1} = mean( ts{:,:}, 2);

ciclost = ciclostationary( tsmedio );
ciclos_9918 = cicloseriesGenerator( ciclost, ts.Time );

% sottraggo la ciclostaz a tutti gli ensemble
% aggiungo zero pre i primi due giorni
tsAnom = [zeros(2, efrfForecast(3).ensembleN ); ts{:,:} - ciclos_9918{:,1}];

% shuffle tutti i giorni e 
tsforced = nan(7305, 50);
tsshuff = ceil(efrfForecast(3).ensembleN*rand(7305, 50 ) ); % generate 50 combinations 
for idx = 1:7305
    tsforced(idx, :) = tsAnom(idx, tsshuff(idx, :) );
end

% salvo, in colonna col tempo
fid = fopen( 'candidate_variables/LakeComo_efrf_14d_50ens_anom.txt', 'w' );
fprintf( fid, '%d\n', tsforced(:) );
fclose(fid);