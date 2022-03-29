aT = efsrBrierScores.Properties.CustomProperties.agg_times;
aTq = length( aT );
q2t = efsrBrierScores.Properties.CustomProperties.quant2test;
q2tq = length( q2t );

lightB = [0.356862745098039,0.811764705882353,0.956862745098039];
darkB = [0.0196078431372549,0.0745098039215686,0.670588235294118];

bGrad = @(i,N) lightB + (darkB-lightB)*((i-1)/(N-1));

lightG = [ 0.8000    1.0000    0.8000];
darkG = [0    0.6000    0.2000];

gGrad = @(i,N) lightG + (darkG-lightG)*((i-1)/(N-1));

figure;
%plot( [1,length(aT)], [1, 1], '-');
hold on;
scoreF = nan(aTq,q2tq);
for idx = 1:q2tq
    scoreF(:,idx) = cat(2 ,efsrBrierScores{idx, "Fuentes"}{1}(:,1).bs);
end
for idx = 1:aTq
    plot( q2t, scoreF(idx,:), 'LineWidth', 2, 'Color', bGrad(idx, aTq) );
end
for idx = 1:q2tq
    scoreF(:,idx) = cat(2 ,efsrBrierScores{idx, "LakeComo"}{1}(:,1).bs);
end
for idx = 1:aTq
    plot( q2t, scoreF(idx,:), 'LineWidth', 2, 'Color', gGrad(idx, aTq) );
end
title( 'BS Fuentes LakeComo Sub-Seasonal Annual Quantile', 'FontSize', 18 );
xlabel( 'quantile', 'FontSize', 14 );
ylabel( 'BS', 'FontSize', 14 );
ylim( [0, 2]);
xticks( q2t );
xticklabels(  q2t );
legend( [strcat( 'agg_{', string(aT), '}'); strcat( 'agg_{', string(aT), '}') ]);
grid on

%%
figure;
scoreF = nan(q2tq, aTq, 4);
for idx = q2tq+(1:q2tq)
    scoreF(idx-q2tq, :, :) = cat(1 ,efsrBrierScores{idx, "Fuentes"}{1}(:,1).bs);
end
scoreLC = nan(q2tq, aTq, 4);
for idx = q2tq+(1:q2tq)
    scoreLC(idx-q2tq, :, :) = cat(1 ,efsrBrierScores{idx, "LakeComo"}{1}(:,1).bs);
end
seq = {'MAM', 'JJA' , 'SON', 'DJF'};
tiledlayout(2,2);
for tr = 1:4
    nexttile;
    hold on;
    grid on
    title( seq{tr} );
    for idx = 1:aTq
        plot( q2t, scoreF(:,idx, tr), 'LineWidth', 2, 'Color', bGrad(idx, aTq) );
        plot( q2t, scoreLC(:,idx, tr), 'LineWidth', 2, 'Color', gGrad(idx, aTq) );
        ylim( [0, 2]);
        xlabel( 'quantile', 'FontSize', 14 );
        ylabel( 'BS', 'FontSize', 14 );
        xticks( q2t );
        xticklabels(  q2t );
    end
end
%%
figure;
scoreF = nan(q2tq, aTq, 12);
for idx = q2tq*2+(1:q2tq)
    scoreF(idx-2*q2tq, :, :) = cat(1 ,efsrBrierScores{idx, "Fuentes"}{1}(:,1).bs);
end
scoreLC = nan(q2tq, aTq, 12);
for idx = q2tq*2+(1:q2tq)
    scoreLC(idx-2*q2tq, :, :) = cat(1 ,efsrBrierScores{idx, "LakeComo"}{1}(:,1).bs);
end
tiledlayout(4,3);
for mo = 1:12
    nexttile;
    hold on;
    grid on
    title( month( datetime(2020, mo, 1), 'name') );
    for idx = 1:aTq
        plot( q2t, scoreF(:,idx, mo), 'LineWidth', 2, 'Color', bGrad(idx, aTq) );
        plot( q2t, scoreLC(:,idx, mo), 'LineWidth', 2, 'Color', gGrad(idx, aTq) );
        ylim( [0, 2]);
        xlabel( 'quantile', 'FontSize', 14 );
        ylabel( 'BS', 'FontSize', 14 );
        xticks( q2t );
        xticklabels(  q2t );
    end
end
figure;
hold on;
grid on
title( 'Average Brier Score per month' );
for idx = 1:aTq
    plot( q2t, mean(scoreF(:,idx, :), 3), 'LineWidth', 2, 'Color', bGrad(idx, aTq) );
    plot( q2t, mean(scoreLC(:,idx, :), 3), 'LineWidth', 2, 'Color', gGrad(idx, aTq) );
    ylim( [0, 2]);
    xlabel( 'quantile', 'FontSize', 14 );
    ylabel( 'BS', 'FontSize', 14 );
    xticks( q2t );
    xticklabels(  q2t );
end