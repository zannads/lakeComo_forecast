%% setup
Set.tFSize = 22;    % title
Set.axFSize = 14;   % axis tick and stuff
Set.labFSize = 16;  % label
Set.legFSize = 18;  % legend

Set.black = '#000000';  % per perfect, measurements
Set.gray = '#929292';   % per average e baseline in generale
Set.red = '#FF2600';     % per limiti
Set.sig1 = ['#3F5A98'; '#4F71BE'; '#7A94CE'; '#A6B8DE']; % blue and central shades
Set.sig2 = ['#648944'; '#7EAB55'; '#9DC07D'; '#BDD5A8']; % green and central shades
Set.sig3 = ['#B26936'; '#DE8344'; '#E5A16E'; '#F6BE98']; % orange

%% efrf spatial analysis x control ensemble
efrf_sa = figure;
efrf_sa_tl = tiledlayout(2,2);
title(efrf_sa_tl, 'Sub Seasonal KGE(LT) - spatial analysis', 'FontSize', Set.tFSize );

lT2p = [1,2,3,5,7:7:42]';
markerpos = '*^sv';
lT = 1:size(efrfProbScores{1,1}{1},2);
colorOrd = [Set.sig2(4,:);Set.sig2(3,:);Set.sig2(2,:);
    Set.sig2(1,:)];
ax = nexttile;
for idx = 1:4
    val = efrfDetScores{"kge", 2*idx}{1}(1,:);
    plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 12);
    hold on;
end
plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
%xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'KGE [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
xticklabels( {} );
ylim( [-0.5, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize;
ax(end).YAxis.FontSize = Set.axFSize;


ax(end+1) = nexttile;
for idx = 1:4
    val = efrfDetScores{"beta", 2*idx}{1}(1,:);
    plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 12);
    hold on;
end
plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
%xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Bias: \beta [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
xticklabels( {} );
ylim( [0, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize;
ax(end).YAxis.FontSize = Set.axFSize;

l = [];
ax = nexttile;
for idx = 1:4
    val = efrfDetScores{"alpha", 2*idx}{1}(1,:);
    l(end+1) = plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 12);
    hold on;
end
l(end+1) = plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Relative Variability: \alpha [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
ax(end).XAxis.TickLabels(2:4) = {''};
ylim( [0, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize;
ax(end).YAxis.FontSize = Set.axFSize;

ax = nexttile;
for idx = 1:4
    val = efrfDetScores{"r", 2*idx}{1}(1,:);
    plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', markerpos(idx), 'MarkerSize', 12);
    hold on;
end
plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Correlation: r [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
ax(end).XAxis.TickLabels(2:4) = {''};
ylim( [0, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize;
ax(end).YAxis.FontSize = Set.axFSize;

% efrf_sa_leg = legend( l, {'Fuentes', 'Mandello', 'LakeComo', 'Olginate', 'Ideal'} );
% efrf_sa_leg.FontSize = Set.legFSize;
% efrf_sa_leg.Location = "southoutside";
% efrf_sa_leg.Orientation = "horizontal";

efrf_sa_tl.Padding = 'compact';
efrf_sa_tl.TileSpacing = 'compact';

saveas(efrf_sa,'efrf_sa.png')
clear efrf_sa efrf_sa_tl efrf_sa_leg l ax lT2p markerpos idx val colorOrd

%% efrf control-mean analysis
lT2p = [1,2,3,5,7:7:42]';
lT = 1:size(efrfProbScores{1,1}{1},2);
colorOrd = [Set.sig2(4,:);Set.sig2(2,:)];

efrf_cm = figure;
efrf_cm_tl = tiledlayout(2,2);
l = [];

ax = nexttile;
for idx = [1,2]
    val = efrfDetScores{"kge", idx+4}{1}(1,:);
    plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', 's', 'MarkerSize', 14);
    hold on;
end
plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
%xlabel( 'Lead time [d]', 'FontSize', Dsettings.labFSize );
ylabel( 'KGE [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
xticklabels( [] )
ylim( [0, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize;
ax(end).YAxis.FontSize = Set.axFSize;

ax(end+1) = nexttile;
for idx = [1,2]
    val = efrfDetScores{"beta", idx+4}{1}(1,:);
    plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', 's', 'MarkerSize', 14);
    hold on;
end
plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
%xlabel( 'Lead time [d]', 'FontSize', Dsettings.labFSize );
ylabel( 'Bias: \beta [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
xticklabels( [] )
ylim( [0, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize;
ax(end).YAxis.FontSize = Set.axFSize;

ax(end+1) = nexttile;
for idx = [1,2]
    val = efrfDetScores{"alpha", idx+4}{1}(1,:);
    l(end+1) = plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', 's', 'MarkerSize', 14);
    hold on;
end
l(end+1) = plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Relative variability: \alpha [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
%xticklabels( ["24", "48", "72"] )
ylim( [0, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize-2;
ax(end).YAxis.FontSize = Set.axFSize;

ax(end+1) = nexttile;
for idx = [1,2]
    val = efrfDetScores{"r", idx+4}{1}(1,:);
    plot( lT(any(lT==lT2p,1)), val(any(lT==lT2p,1)), 'LineWidth', 2,  'Color', colorOrd(idx,:), 'Marker', 's', 'MarkerSize', 14);
    hold on;
end
plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Correlation: r [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 42.05] )
xticks( lT2p )
%xticklabels( ["24", "48", "72"] )
ylim( [0, 1.05])
grid on
ax(end).XAxis.FontSize = Set.axFSize-2;
ax(end).YAxis.FontSize = Set.axFSize;

title(efrf_cm_tl, "Sub Seasonal KGE(LT) - Control vs Mean", 'FontSize', Set.tFSize);

efrf_cm_leg = legend( l, {'Mean', 'Control', 'Ideal'} );
efrf_cm_leg.FontSize = Set.legFSize;
efrf_cm_leg.Location = "southoutside";
efrf_cm_leg.Orientation  = "horizontal";

efrf_cm_tl.Padding = 'compact';
efrf_cm_tl.TileSpacing = 'compact';

saveas( efrf_cm, 'efrf_cm.png' );
clear efrf_cm efrf_cm_leg efrf_cm_tl l ax lT2p markerpos idx val colorOrd

%% efrf efsr PROGEA ciclost KGE(LT)
kge_lt = figure;
l = [];
lT2p = [1,2,3,5,7:7:42,52:10:183]';
lT = 1:size(PROGEADetScores{1,1}{1},2);
val = PROGEADetScores{"kge", "PROGEA"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

lT = 1:size(efrfDetScores{1,1}{1},2);
val = efrfDetScores{"kge", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig2(2,:));

lT = 1:size(efsrDetScores{1,1}{1},2);
val = efsrDetScores{"kge", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = repmat(cicloDetScores{"kge", "ciclostationary"}{1}(1,:), 1, lT(end) );
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.gray);

l(end+1) = plot( [1, lT2p(end)], [1, 1], '--', 'Color', Set.red);

title( 'KGE(LT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize-2;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'KGE [-]', 'FontSize', Set.labFSize );
ylim( [0, 1.05] )
xlim( [0, 183] );
xticks( lT2p )
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on
kge_lt_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'cyclostationary', 'ideal'});
kge_lt_leg.FontSize = Set.legFSize;
kge_lt_leg.Location = "northeast";

saveas( kge_lt, 'kge_lt.png' );
clear kge_lt kge_lt_leg ax l lT lT2p val lT2pticklabels

%% efrf efsr PROGEA ciclost KGE(AT)
kge_at = figure;
l = [];
aT = PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = PROGEADetScores{"kge", "PROGEA"}{1}(:,1);
l(1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

aT = efrfDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = efrfDetScores{"kge", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig2(2,:));

aT = efsrDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT); aTXtick([2,3,5,7]) = "";
val = efsrDetScores{"kge", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = cicloDetScores{"kge", "ciclostationary"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.gray);

l(end+1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);

title( 'KGE(AT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'KGE [-]', 'FontSize', Set.labFSize );
ylim( [0.3, 1.05] )
xticks( aTXcord )
xticklabels( aTXtick );
grid on
kge_at_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'cyclostationary', 'ideal'});
kge_at_leg.FontSize = Set.legFSize;
kge_at_leg.Location = "northeast";

saveas( kge_at, 'kge_at.png' );
clear kge_at kge_at_leg ax l aT aTXcord aTXtick val

%% efrf efsr PROGEA ciclost NSE(LT)
nse_lt = figure;
l = [];
lT2p = [1,2,3,5,7:7:42,52:10:183]';
lT = 1:size(PROGEADetScores{1,1}{1},2);
val = PROGEADetScores{"nse", "PROGEA"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

lT = 1:size(efrfDetScores{1,1}{1},2);
val = efrfDetScores{"nse", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig2(2,:));

lT = 1:size(efsrDetScores{1,1}{1},2);
val = efsrDetScores{"nse", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = repmat(cicloDetScores{"nse", "ciclostationary"}{1}(1,:), 1, lT(end) );
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.gray);

l(end+1) = plot( [1, lT2p(end)], [1, 1], '--', 'Color', Set.red);

title( 'NSE(LT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize-2;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'NSE [-]', 'FontSize', Set.labFSize );
ylim( [-0.5, 1.05] )
xlim( [0, 183] );
xticks( lT2p );
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on
nse_lt_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'cyclostationary', 'ideal'});
nse_lt_leg.FontSize = Set.legFSize;
nse_lt_leg.Location = "northeast";

saveas( nse_lt, 'nse_lt.png' );
clear nse_lt nse_lt_leg ax l lT lT2p val lT2pticklabels

%% efrf efsr PROGEA ciclost NSE(AT)
nse_at = figure;
l = [];
aT = PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = PROGEADetScores{"nse", "PROGEA"}{1}(:,1);
l(1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

aT = efrfDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = efrfDetScores{"nse", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig2(2,:));

aT = efsrDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT); aTXtick([2,3,5,7]) = "";
val = efsrDetScores{"nse", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = cicloDetScores{"nse", "ciclostationary"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.gray);

l(end+1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);

title( 'NSE(AT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'NSE [-]', 'FontSize', Set.labFSize );
ylim( [-1.2, 1.05] )
xticks( aTXcord )
xticklabels( aTXtick );
grid on
nse_at_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'cyclostationary', 'ideal'});
nse_at_leg.FontSize = Set.legFSize;
nse_at_leg.Location = "northeast";

saveas( nse_at, 'nse_at.png' );
clear nse_at nse_at_leg ax l aT aTXcord aTXtick val

%% efrf efsr PROGEA 3d-dec(LT)
kge_dec_lt = figure;
kge_dec_lt_tl = tiledlayout(2,2);

lT2p = [1,2,3,5,7:7:42,52:10:183]';
% alpha
ax(1) = nexttile;
lT = 1:size(PROGEADetScores{1,1}{1},2);
val = PROGEADetScores{"alpha", "PROGEA"}{1}(1,:);
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

lT = 1:size(efrfDetScores{1,1}{1},2);
val = efrfDetScores{"alpha", "LakeComo_ave"}{1}(1,:);
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig2(2,:));

lT = 1:size(efsrDetScores{1,1}{1},2);
val = efsrDetScores{"alpha", "LakeComo_ave"}{1}(1,:);
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = repmat(cicloDetScores{"alpha", "ciclostationary"}{1}(1,:), 1, lT(end) );
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.gray);

plot( [1, lT2p(end)], [1, 1], '--', 'Color', Set.red);

xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Relative variability: \alpha [-]', 'FontSize', Set.labFSize );
ylim( [0.35, 1.1] )
xlim( [0, 183] );
xticks( lT2p )
xticklabels( {} );
grid on

% beta
ax(end+1) = nexttile;
lT = 1:size(PROGEADetScores{1,1}{1},2);
val = PROGEADetScores{"beta", "PROGEA"}{1}(1,:);
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

lT = 1:size(efrfDetScores{1,1}{1},2);
val = efrfDetScores{"beta", "LakeComo_ave"}{1}(1,:);
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig2(2,:));

lT = 1:size(efsrDetScores{1,1}{1},2);
val = efsrDetScores{"beta", "LakeComo_ave"}{1}(1,:);
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = repmat(cicloDetScores{"beta", "ciclostationary"}{1}(1,:), 1, lT(end) );
plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.gray);

plot( [1, lT2p(end)], [1, 1], '--', 'Color', Set.red);

xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Bias: \beta [-]', 'FontSize', Set.labFSize );
ylim( [0.4, 1.2] );
xlim( [0, 183] );
xticks( lT2p )
xticklabels( {} );
grid on

% r
l = [];
ax(end+1) = nexttile( [1,2] );
lT = 1:size(PROGEADetScores{1,1}{1},2);
val = PROGEADetScores{"r", "PROGEA"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

lT = 1:size(efrfDetScores{1,1}{1},2);
val = efrfDetScores{"r", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig2(2,:));

lT = 1:size(efsrDetScores{1,1}{1},2);
val = efsrDetScores{"r", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = repmat(cicloDetScores{"r", "ciclostationary"}{1}(1,:), 1, lT(end) );
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.gray);

l(end+1) = plot( [1, lT2p(end)], [1, 1], '--', 'Color', Set.red);

xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'Correlation: r [-]', 'FontSize', Set.labFSize );
ylim( [0.2, 1.05] )
xlim( [0, 183] );
xticks( lT2p )
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on

% sets
title(kge_dec_lt_tl, 'KGE decomposition(LT)', 'FontSize', Set.tFSize );
for idx = 1:3
    ax(idx).XAxis.FontSize = Set.axFSize;
    ax(idx).YAxis.FontSize = Set.axFSize;
end

kge_dec_lt_tl.Padding = 'compact';
kge_dec_lt_tl.TileSpacing = 'compact';

kge_dec_lt_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'cyclostationary', 'ideal'});
kge_dec_lt_leg.FontSize = Set.legFSize;
kge_dec_lt_leg.Location = "southoutside";
kge_dec_lt_leg.Orientation = "horizontal";

saveas( kge_dec_lt, 'kge_dec_lt.png' );
clear kge_dec_lt kge_dec_lt_tl kge_dec_lt_leg ax l lT lT2p val idx lT2pticklabels

%% efrf efsr PROGEA 3d-dec(AT)
kge_dec_at = figure;
kge_dec_at_tl = tiledlayout(2,2);

%alpha
ax(1) = nexttile;
aT = PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = PROGEADetScores{"alpha", "PROGEA"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

aT = efrfDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = efrfDetScores{"alpha", "LakeComo_ave"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig2(2,:));

aT = efsrDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT); aTXtick([2,3,5,7]) = "";
val = efsrDetScores{"alpha", "LakeComo_ave"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = cicloDetScores{"alpha", "ciclostationary"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.gray);

plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);

xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'Relative variability: \alpha [-]', 'FontSize', Set.labFSize );
ylim( [0.4, 1.2] )
xlim( [0, 156] );
xticks( aTXcord )
xticklabels( {} );
grid on

% beta
ax(2) = nexttile;
aT = PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = PROGEADetScores{"beta", "PROGEA"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

aT = efrfDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = efrfDetScores{"beta", "LakeComo_ave"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig2(2,:));

aT = efsrDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT); aTXtick([2,3,5,7]) = "";
val = efsrDetScores{"beta", "LakeComo_ave"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = cicloDetScores{"beta", "ciclostationary"}{1}(:,1);
plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.gray);


plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);

xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'Bias: \beta [-]', 'FontSize', Set.labFSize );
ylim( [0.4, 1.2] )
xlim( [0, 156] );
xticks( aTXcord )
xticklabels( {} );
grid on

% r
ax(3) = nexttile([1,2]);
aT = PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = PROGEADetScores{"r", "PROGEA"}{1}(:,1);
l(1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

aT = efrfDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = efrfDetScores{"r", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig2(2,:));

aT = efsrDetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT); aTXtick([2,3,5,7,11]) = "";
val = efsrDetScores{"r", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig3(2,:));
val = cicloDetScores{"r", "ciclostationary"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.gray);


l(end+1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);

xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'Correlation: r [-]', 'FontSize', Set.labFSize );
ylim( [0.4, 1.2] )
xlim( [0, 156] );
xticks( aTXcord )
xticklabels( aTXtick );
grid on

%
title(kge_dec_at_tl, 'KGE decomposition (AT)', 'FontSize', Set.tFSize );
for idx = 1:3
    ax(idx).XAxis.FontSize = Set.axFSize;
    ax(idx).YAxis.FontSize = Set.axFSize;
end

kge_dec_at_tl.Padding = 'compact';
kge_dec_at_tl.TileSpacing = 'compact';

kge_dec_at_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'cyclostationary', 'ideal'});
kge_dec_at_leg.FontSize = Set.legFSize;
kge_dec_at_leg.Location = "southoutside";
kge_dec_at_leg.Orientation = "horizontal";

saveas( kge_dec_at, 'kge_dec_at.png' );
clear kge_dec_at kge_dec_at_tl kge_dec_at_leg ax l aT aTXcord aTXtick val idx

%% efrf efsr PROGEA & benchmarks VE(LT)
progea_ve = figure;

lT = 1:3;
colorOrd = [Set.sig1(2,:);Set.gray;Set.gray;
    Set.sig2];
l =[];

for idx = [1,3:7]
    val =  PROGEADetScores{"ve", idx}{1}(1, :);
    if idx == 1
        l(end+1) = plot( lT, val, 'LineWidth', 2, 'Color', colorOrd(idx,:));
    else
        l(end+1) = plot( lT, val, 'LineWidth', 2, 'Color', colorOrd(idx,:), 'Marker', 'o', 'MarkerSize', 11);
    end
    hold on;
end
val = efrfDetScores{"ve", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT, val(1:3), 'LineWidth', 2,  'Color', Set.sig2(2,:));

val = efsrDetScores{"ve", "LakeComo_ave"}{1}(1,:);
l(end+1) = plot( lT, val(1:3), 'LineWidth', 2,  'Color', Set.sig3(2,:));

l(end+1) = plot( [1, lT(end)], [1, 1], '--', 'Color', Set.red);

title( 'VE(LT)', 'FontSize', Set.tFSize );
xlabel( 'Lead time [h]', 'FontSize', Set.labFSize );
ylabel( 'VE [-]', 'FontSize', Set.labFSize );
xlim( [0.95, 3.05] )
xticks( [1,2,3] )
xticklabels( ["24", "48", "72"] )
ylim( [0.1, 1.05])
grid on
ax = gca;
ax(1).XAxis.FontSize = Set.axFSize;
ax(1).YAxis.FontSize = Set.axFSize;

progea_ve_leg = legend( l, {'PROGEA', 'Cyclostationary', 'Last obs','Average 3d','Average 7d','Average 30d', 'efrf', 'efsr', 'Ideal'} );
progea_ve_leg.FontSize = Set.legFSize;
progea_ve_leg.Location = "southeast";
progea_ve_leg.NumColumns = 2;

saveas( progea_ve, 'progea_ve.png' );
clear progea_ve progea_ve_leg l ax lT val

%% PROGEA & efrf & efsr CRPS(AT)
crps_at = figure;
l = [];

aT = PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = PROGEADetScores{"mae", "PROGEA"}{1}(:,1);
l(1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

aT = efrfProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = efrfProbScores{"crps", "LakeComo"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig2(2,:) );

aT = efsrProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT);
val = efsrProbScores{"crps", "LakeComo"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig3(3,:) );

title( 'CRPS(AT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'CRPS [m^3/s]', 'FontSize', Set.labFSize );
ylim( [0, 80] )
xticks( aTXcord )
aTXtick([2,3,5,7,11]) = "";
xticklabels( aTXtick );
grid on
crps_at_leg = legend( l, {'PROGEA', 'efrf', 'efsr'});
crps_at_leg.FontSize = Set.legFSize;
crps_at_leg.Location = "northeast";

saveas( crps_at, 'crps_at.png' );
clear aT aTXcord aTXtick ax colorOrd crps_at crps_at_leg idx l markerpos val

%% PROGEA & efrf & efsr CRPS(LT)
crps_lt = figure;
l = [];
lT2p = [1,2,3,5,7:7:42,52:10:183]';
lT = 1:size(PROGEADetScores{1,1}{1},2);
val = PROGEADetScores{"mae", "PROGEA"}{1}(1,:);
l(1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

lT = 1:size(efrfDetScores{1,1}{1},2);
val = efrfProbScores{"crps", "LakeComo"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig2(2,:) );

lT = 1:size(efsrDetScores{1,1}{1},2);
val = efsrProbScores{"crps", "LakeComo"}{1}(1,:);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig3(3,:) );

title( 'CRPS(LT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'CRPS [m^3/s]', 'FontSize', Set.labFSize );
ylim( [0, 80] )
xlim( [0, 183] )
xticks( lT2p )
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on
crps_lt_leg = legend( l, {'PROGEA', 'efrf', 'efsr'});
crps_lt_leg.FontSize = Set.legFSize;
crps_lt_leg.Location = "southeast";

saveas( crps_lt, 'crps_lt.png' );
clear crpss_lt crpss_lt_leg val ax l lT lT2p val idx lT2pticklabels

%% PROGEA & efrf & efsr benchmarks CRPSS(AT)
crpss_at = figure;
l = [];

aT = PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = 1-PROGEADetScores{"mae", "PROGEA"}{1}(:,1)./cicloDetScores{"mae", "ciclostationary"}{1}(1:2,1);
l(1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

aT = efrfProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);
val = 1-efrfProbScores{"crps", "LakeComo"}{1}(:,1)./[cicloDetScores{"mae", "ciclostationary"}{1}(1:7,1);cicloDetScores{"mae", "ciclostationary"}{1}(9,1)];
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig2(2,:) );

aT = efsrProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT);
val = 1-efsrProbScores{"crps", "LakeComo"}{1}(:,1)./cicloDetScores{"mae", "ciclostationary"}{1}(:,1);
l(end+1) = plot( aTXcord, val, 'LineWidth', 2,  'Color', Set.sig3(3,:) );

l(end+1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);
l(end+1) = plot( [1, aTXcord(end)], [0, 0], '--', 'Color', Set.black, 'LineWidth', 1.25);

title( 'CRPSS(AT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Aggregation time-dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'CRPSS [-]', 'FontSize', Set.labFSize );
ylim( [-0.6, 1.05] )
xticks( aTXcord )
aTXtick([2,3,5,7,11]) = "";
xticklabels( aTXtick );
grid on
crpss_at_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'ideal', 'no skill'});
crpss_at_leg.FontSize = Set.legFSize;
crpss_at_leg.Location = "northeast";

saveas( crpss_at, 'crpss_at.png' );
clear aT aTXcord aTXtick ax colorOrd crpss_at crpss_at_leg idx l markerpos val

%% PROGEA & efrf & efsr benchmarks CRPSS(LT)
crpss_lt = figure;
l = [];
lT2p = [1,2,3,5,7:7:42,52:10:183]';
lT = 1:size(PROGEADetScores{1,1}{1},2);
val = 1-PROGEADetScores{"mae", "PROGEA"}{1}(1,:)./cicloDetScores{"mae", "ciclostationary"}{1}(1,1);
l(1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig1(2,:));
hold on;

lT = 1:size(efrfDetScores{1,1}{1},2);
val = 1-efrfProbScores{"crps", "LakeComo"}{1}(1,:)./cicloDetScores{"mae", "ciclostationary"}{1}(1,1);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig2(2,:) );

lT = 1:size(efsrDetScores{1,1}{1},2);
val = 1-efsrProbScores{"crps", "LakeComo"}{1}(1,:)./cicloDetScores{"mae", "ciclostationary"}{1}(1,1);
l(end+1) = plot( lT(any(lT==lT2p)), val(any(lT==lT2p)), 'LineWidth', 2,  'Color', Set.sig3(3,:) );

l(end+1) = plot( [1, max(lT2p)], [1, 1], '--', 'Color', Set.red);
l(end+1) = plot( [1, max(lT2p)], [0, 0], '--', 'Color', Set.black, 'LineWidth', 1.25);

title( 'CRPSS(LT)', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'CRPSS [-]', 'FontSize', Set.labFSize );
ylim( [-0.6, 1.05] )
xlim( [0, 183] )
xticks( lT2p )
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on
crpss_lt_leg = legend( l, {'PROGEA', 'efrf', 'efsr', 'ideal', 'no skill'});
crpss_lt_leg.FontSize = Set.legFSize;
crpss_lt_leg.Location = "northeast";

saveas( crpss_lt, 'crpss_lt.png' );
clear crpss_lt crpss_lt_leg val ax l lT lT2p val idx lT2pticklabels

%% efrf BRIER biased vs unbiased qtA:0.2(LT)
brier_bvsub_lt = figure;
l = [];
lT2p = [1,2,3,5,7:7:41,41]';

%lT = 1:size(efrfBrierScores{1,1}{1},2);
val = efrfBrierScores{"Bbs_annual0.2", "LakeComo"}{1}(1,lT2p);
val = cat(1,val.bs);
l(end+1) = plot( lT2p ,val , 'LineWidth', 2,  'Color', Set.sig2(2,:), 'Marker', '*' );
hold on;
val = efrfBrierScores{"Ubs_annual0.2", "LakeComo"}{1}(1,lT2p);
val = cat(1,val.bs);
l(end+1) = plot( lT2p ,val , 'LineWidth', 2,  'Color', Set.sig2(4,:) );

title( 'BS(LT) - biased vs unbiased', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'BS [-]', 'FontSize', Set.labFSize );
ylim( [-0.05, 2.05] )
xlim( [0, 42] )
xticks( lT2p )
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on
brier_bvsub_lt_leg = legend( l, {'Biased', 'Unbiased'});
brier_bvsub_lt_leg.FontSize = Set.legFSize;
brier_bvsub_lt_leg.Location = "northeast";

saveas( brier_bvsub_lt, 'brier_bvsub_lt.png' );
clear brier_bvsub_lt brier_bvsub_lt_leg val ax l lT lT2p val idx lT2pticklabels

%% efrf efsr unbiased qtDrought(LT)
brier_d = figure;

l = [];
lT2p = [1,2,3,5,7:7:41,41]';

ax = nexttile;
for idx = 1:4
    val = efrfBrierScores{idx, "LakeComo"}{1}(1,lT2p);
    val = cat(1,val.bs);
    l(end+1) = plot( lT2p ,val , 'LineWidth', 2,  'Color', Set.sig2(idx,:));
    hold on;
end

lT2p = [1,2,3,5,7:7:42,52:10:183]';
for idx = 1:4
    val = efsrBrierScores{idx, "LakeComo"}{1}(1,lT2p);
    val = cat(1,val.bs);
    l(end+1) = plot( lT2p ,val , 'LineWidth', 2,  'Color', Set.sig3(idx,:));
    hold on;
end

title( 'BS(LT) - Drought quantile', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'BS [-]', 'FontSize', Set.labFSize );
ylim( [-0.05, 0.8] )
xlim( [0, 183] )
xticks( lT2p )
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on

legname = strcat( '-qtA:', num2str(efrfBrierScores.Properties.CustomProperties.quant2test(1:4)', '%.2f'));
legname = [strcat( 'efrf', legname );strcat( 'efsr', legname )];
brier_d_leg = legend( l, cellstr(legname) );
brier_d_leg.FontSize = Set.legFSize;
brier_d_leg.Location = "northeast";

saveas( brier_d, 'brier_d.png' );
clear brier_d  brier_d_leg val ax l lT lT2p val idx lT2pticklabels legname

%% efrf efsr unbiased qtFlood(LT)
brier_f = figure;

l = [];
lT2p = [1,2,3,5,7:7:41,41]';

for idx = 1:4
    val = efrfBrierScores{idx+4, "LakeComo"}{1}(1,lT2p);
    val = cat(1,val.bs);
    l(end+1) = plot( lT2p ,val , 'LineWidth', 2,  'Color', Set.sig2(5-idx,:));
    hold on;
end
lT2p = [1,2,3,5,7:7:42,52:10:183]';
for idx = 1:4
    val = efsrBrierScores{idx+4, "LakeComo"}{1}(1,lT2p);
    val = cat(1,val.bs);
    l(end+1) = plot( lT2p ,val , 'LineWidth', 2,  'Color', Set.sig3(5-idx,:));
    hold on;
end

title( 'BS(LT) - Flood quantile', 'FontSize', Set.tFSize );

ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Lead time [d]', 'FontSize', Set.labFSize );
ylabel( 'BS [-]', 'FontSize', Set.labFSize );
ylim( [-0.05, 0.8] )
xlim( [0, 183] )
xticks( lT2p )
lT2pticklabels = string(lT2p);
lT2pticklabels(2:4) = "";
xticklabels( lT2pticklabels );
grid on

legname = strcat( '-qtA:', num2str(efrfBrierScores.Properties.CustomProperties.quant2test(5:end)', '%.2f'));
legname = [strcat( 'efrf', legname );strcat( 'efsr', legname )];
brier_f_leg = legend( l, cellstr(legname) );
brier_f_leg.FontSize = Set.legFSize;
brier_f_leg.Location = "northeast";

saveas( brier_f, 'brier_f.png' );
clear brier_f brier_f_leg val ax l lT lT2p val idx lT2pticklabels legname

%% efrf efsr unbiasedBSS qtDrought(AT)
brierss_d = figure;

l = [];
aT = efrfProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);

for idx = 1:4
    val = efrfBrierScores{idx, "LakeComo"}{1}(:,1);
    norm = cat(1,val.unc);
    val = cat(1,val.bs);
    l(end+1) = plot( aTXcord , 1-val./norm , 'LineWidth', 2,  'Color', Set.sig2(idx,:));
    hold on;
end

aT = efsrProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT);
for idx = 1:4
    val = efsrBrierScores{idx, "LakeComo"}{1}(:,1);
    norm = cat(1,val.unc);
    val = cat(1,val.bs);
    l(end+1) = plot( aTXcord , 1-val./norm , 'LineWidth', 2,  'Color', Set.sig3(idx,:));
    hold on;
end

l(end+1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);
l(end+1) = plot( [1, aTXcord(end)], [0, 0], '--', 'Color', Set.black, 'LineWidth', 1.25);


title( 'BSS(AT) - Drought quantile', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Aggregation time - dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'BSS [-]', 'FontSize', Set.labFSize );
ylim( [-1.05, 1.05] )
xlim( [0, 156] )
xticks( aTXcord )
aTXtick([2,3,5,7,11]) = "";
xticklabels( aTXtick );
grid on

legname = strcat( '-qtA:', num2str(efrfBrierScores.Properties.CustomProperties.quant2test(1:4)', '%.2f'));
legname = [strcat( 'efrf', legname );strcat( 'efsr', legname )];
brierss_d_leg = legend( l, [cellstr(legname)', {'ideal', 'no skill'}] );
brierss_d_leg.FontSize = Set.legFSize;
brierss_d_leg.Location = "southeast";
brierss_d_leg.Orientation = "horizontal";
brierss_d_leg.NumColumns = 2;

saveas( brierss_d, 'brierss_d.png' );
clear brierss_d  brierss_d_leg val ax l lT lT2p val idx lT2pticklabels legname

%% efrf efsr unbiasedBSS qtFlood(AT)
brierss_f = figure;

l = [];
aT = efrfProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
%aTXtick = string(aT);

for idx = 1:4
    val = efrfBrierScores{idx+4, "LakeComo"}{1}(:,1);
    norm = cat(1,val.unc);
    val = cat(1,val.bs);
    l(end+1) = plot( aTXcord , 1-val./norm , 'LineWidth', 2,  'Color', Set.sig2(5-idx,:));
    hold on;
end

aT = efsrProbScores.Properties.CustomProperties.agg_times;
aTXcord = split(aT, 'days') + 31*split(aT, 'months');
aTXtick = string(aT);
for idx = 1:4
    val = efsrBrierScores{idx+4, "LakeComo"}{1}(:,1);
    norm = cat(1,val.unc);
    val = cat(1,val.bs);
    l(end+1) = plot( aTXcord , 1-val./norm , 'LineWidth', 2,  'Color', Set.sig3(5-idx,:));
    hold on;
end

l(end+1) = plot( [1, aTXcord(end)], [1, 1], '--', 'Color', Set.red);
l(end+1) = plot( [1, aTXcord(end)], [0, 0], '--', 'Color', Set.black, 'LineWidth', 1.25);


title( 'BSS(AT) - Flood quantile', 'FontSize', Set.tFSize );
ax = gca;
ax.XAxis.FontSize = Set.axFSize;
ax.YAxis.FontSize = Set.axFSize;
xlabel( 'Aggregation time - dis_{x}^{x}', 'FontSize', Set.labFSize );
ylabel( 'BSS [-]', 'FontSize', Set.labFSize );
ylim( [-1.05, 1.05] )
xlim( [0, 156] )
xticks( aTXcord )
aTXtick([2,3,5,7,11]) = "";
xticklabels( aTXtick );
grid on

legname = strcat( '-qtA:', num2str(efrfBrierScores.Properties.CustomProperties.quant2test(5:8)', '%.2f'));
legname = [strcat( 'efrf', legname );strcat( 'efsr', legname )];
brierss_d_leg = legend( l, [cellstr(legname)', {'ideal', 'no skill'}] );
brierss_d_leg.FontSize = Set.legFSize;
brierss_d_leg.Location = "southeast";
brierss_d_leg.Orientation = "horizontal";
brierss_d_leg.NumColumns = 2;

saveas( brierss_f, 'brierss_f.png' );
clear brierss_f  brierss_f_leg val ax l lT lT2p val idx lT2pticklabels legname

%%
system( 'mkdir images' );
system( 'mv *.png images/');
close all
clear