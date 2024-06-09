%% setup
setup_base;
data_folder=[data_folder, '/Solutions/EMODPS/'];
Sett.tFSize = 10;    % title
Sett.axFSize = 10;   % axis tick and stuff
Sett.labFSize = 10;  % label
Sett.legFSize = 10;  % legend

Sett.black = '#000000';  % per perfect, measurements
Sett.gray = '#929292';   % per average e baseline in generale
Sett.red = '#FF2600';    % per limiti
% Colors from tab20 of matplotlib
                    blu_ = 1;             arancio_=3;            verde_=5;            viola_=7;             rosso_=9;
                               chiaro=1; %+1
Sett.quali_tab20 = ['#1F78B4'; '#ADC6E7'; '#FC7F0F'; '#FDBB78'; '#2CA02D'; '#99DF8A'; '#9567BD'; '#C5B0D5'; '#D62728'; '#FF9896'];
Sett.quali_Dark2 = ['#1C9E78'; '#D95F01'; '#7570B3'];
Sett.ParetoXLim = [1000, 1850];
Sett.ParetoYLim = [0, 35];

%% efrf efsr PROGEA KGE & 3d-dec(AT)
%load( [data_folder,'../Scores/Scores_PROGEA_efrf_efsr/ScoresTable.mat'] );

aT_pro=PROGEADetScores.Properties.CustomProperties.agg_times;
aTXcord_pro=split(aT_pro, 'days') + 31*split(aT_pro, 'months');

aT_efrf=efrfDetScores.Properties.CustomProperties.agg_times;
aTXcord_efrf=split(aT_efrf, 'days') + 31*split(aT_efrf, 'months');

aT_efsr = efsrDetScores.Properties.CustomProperties.agg_times;
aTXcord_efsr = split(aT_efsr, 'days') + 31*split(aT_efsr, 'months');
aTXtick = string(aT_efsr); aTXtick([1,2,3,5,7,10]) = "";

fFcstInsp.f = figure;
fFcstInsp.tl = tiledlayout(2,6, 'TileSpacing','compact','Padding','compact');

%---kge---
fFcstInsp.ax(1) = nexttile([1, 3]);
val = PROGEADetScores{"kge", "PROGEA"}{1}(:,1);
plot( aTXcord_pro, val, 'LineWidth', 4,  'Color', Sett.quali_Dark2(1,:));
hold on;

val = efrfDetScores{"kge", "LakeComo_ave"}{1}(:,1);
plot( aTXcord_efrf, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(2,:));

val = efsrDetScores{"kge", "LakeComo_ave"}{1}(:,1);
plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(3,:));

val = cicloDetScores{"kge", "ciclostationary"}{1}(:,1);
plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.gray);

plot( [1, aTXcord_efsr(end)], [1, 1], '--', 'Color', Sett.red);

ylabel( 'KGE: [-]', 'FontSize', Sett.labFSize );
ylim( [0.2, 1.05] )
xlim( [0, 156] );
xticks( aTXcord_efsr )
xticklabels( aTXtick );
grid on

%---crpss---
fFcstInsp.ax(2)=nexttile([1, 3]);

val = PROGEADetScores{"mae", "PROGEA"}{1}(:,1);
plot( aTXcord_pro, val, 'LineWidth',4, 'Color', Sett.quali_Dark2(1,:));
hold on;

val = efrfProbScores{"crps","LakeComo"}{1}(:,1);
plot( aTXcord_efrf, val, 'LineWidth', 2, 'Color', Sett.quali_Dark2(2,:));

val = efsrProbScores{"crps", "LakeComo"}{1}(:,1);
plot( aTXcord_efsr, val, 'LineWidth', 2, 'Color', Sett.quali_Dark2(3,:));

val = cicloDetScores{"mae", "ciclostationary"}{1}(:,1);
plot(aTXcord_efsr, val, 'LineWidth', 2, 'Color', Sett.gray);

ylabel( 'CRPS: [m^3/s]', 'FontSize', Sett.labFSize );
%ylim( [0.2, 1.05] )
xlim( [0, 156] );
xticks( aTXcord_efsr )
xticklabels( aTXtick );
grid on

%---alpha---
fFcstInsp.ax(3) = nexttile([1,2]);

val = PROGEADetScores{"alpha", "PROGEA"}{1}(:,1);
plot( aTXcord_pro, val, 'LineWidth', 4,  'Color', Sett.quali_Dark2(1,:));
hold on;

val = efrfDetScores{"alpha", "LakeComo_ave"}{1}(:,1);
plot( aTXcord_efrf, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(2,:));

val = efsrDetScores{"alpha", "LakeComo_ave"}{1}(:,1);
plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(3,:));

val = cicloDetScores{"alpha", "ciclostationary"}{1}(:,1);
plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.gray);

plot( [1, aTXcord_efsr(end)], [1, 1], '--', 'Color', Sett.red);

xlabel( 'Aggregation Time (q_{x})', 'FontSize', Sett.labFSize );
ylabel( 'Relative variability: \alpha [-]', 'FontSize', Sett.labFSize );
ylim( [0.4, 1.2] )
xlim( [0, 156] );
xticks( aTXcord_efsr )
xticklabels( aTXtick );
grid on

l = [];
%---beta---
fFcstInsp.ax(4) = nexttile([1,2]);

val = PROGEADetScores{"beta", "PROGEA"}{1}(:,1);
l(end+1) = plot( aTXcord_pro, val, 'LineWidth', 4,  'Color', Sett.quali_Dark2(1,:));
hold on;

val = efrfDetScores{"beta", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord_efrf, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(2,:));

val = efsrDetScores{"beta", "LakeComo_ave"}{1}(:,1);
l(end+1) = plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(3,:));

val = cicloDetScores{"beta", "ciclostationary"}{1}(:,1);
l(end+1) = plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.gray);

l(end+1) = plot( [1, aTXcord_efsr(end)], [1, 1], '--', 'Color', Sett.red);

xlabel( 'Aggregation Time (q_{x})', 'FontSize', Sett.labFSize );
ylabel( 'Bias: \beta [-]', 'FontSize', Sett.labFSize );
ylim( [0.4, 1.2] )
xlim( [0, 156] );
xticks( aTXcord_efsr )
xticklabels( aTXtick );
grid on

%---r---
fFcstInsp.ax(5) = nexttile([1,2]);

val = PROGEADetScores{"r", "PROGEA"}{1}(:,1);
plot( aTXcord_pro, val, 'LineWidth', 4,  'Color', Sett.quali_Dark2(1,:));
hold on;

val = efrfDetScores{"r", "LakeComo_ave"}{1}(:,1);
plot( aTXcord_efrf, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(2,:));

val = efsrDetScores{"r", "LakeComo_ave"}{1}(:,1);
plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.quali_Dark2(3,:));

val = cicloDetScores{"r", "ciclostationary"}{1}(:,1);
plot( aTXcord_efsr, val, 'LineWidth', 2,  'Color', Sett.gray);

plot( [1, aTXcord_efsr(end)], [1, 1], '--', 'Color', Sett.red);

xlabel( 'Aggregation Time (q_{x})', 'FontSize', Sett.labFSize );
ylabel( 'Correlation: r [-]', 'FontSize', Sett.labFSize );
ylim( [0.4, 1.2] )
xlim( [0, 156] );
xticks( aTXcord_efsr )
xticklabels( aTXtick );
grid on

%
%title(fFcstInsp.tl, 'KGE and components (AT)', 'FontSize', Sett.tFSize );
for idx = 1:length(fFcstInsp.ax)
    fFcstInsp.ax(idx).XAxis.FontSize = Sett.axFSize;
    fFcstInsp.ax(idx).YAxis.FontSize = Sett.axFSize;
end

fFcstInsp.leg = legend( l, {'PROGEA', 'EFRF', 'EFSR', 'Climatology', 'Ideal'});
fFcstInsp.leg.FontSize = Sett.legFSize;
fFcstInsp.leg.Location = "southoutside";   
fFcstInsp.leg.Orientation = "horizontal";

% TO DO before saving:
% - add arrow on KGE
% - move legend and plots(Ideal dim: [0.42,0.31])
%saveas( fFcstInsp.f, 'fFcstInsp.png' );

%% SI: Biased and unbiased brier score

qtl=[0.5, 0.2, 0.1, 0.05];
lnstl=["-.","-", "--", ":"];

fBSInsp.f=figure;
fBSInsp.tl=tiledlayout(1,2, 'TileSpacing','compact','Padding','compact');

fBSInsp.ax(1)=nexttile(); hold on;
fBSInsp.ax(2)=nexttile(); hold on;
mask = [true, true, true, true, true, true, true, false,true];
for qt=qtl
    test="Ubs_annual"+string(1-qt);
    val=efrfBrierScores{test, "LakeComo"}{1}(mask,1);
    y = 1- cat(1, val.bs)./cat(1, val.unc);
    plot(fBSInsp.ax(2), aTXcord_efrf, y, 'LineWidth',2, 'LineStyle',lnstl(qtl==qt), 'Color',Sett.quali_Dark2(2,:), 'Marker','none', 'MarkerSize',6);
%{
    test="Ubs_annual"+string(1-qt);
    val=efsrBrierScores{test, "LakeComo"}{1}(mask,1);
    y = 1- cat(1, val.bs)./cat(1, val.unc);
    plot(fBSInsp.ax(2), aTXcord_efsr, y, 'LineWidth',2, 'LineStyle',lnstl(qtl==qt), 'Color',Sett.quali_Dark2(3,:), 'Marker','none', 'MarkerSize',6);
%}
    test="Ubs_annual"+string(qt);
    val=efrfBrierScores{test, "LakeComo"}{1}(mask,1);
    y = 1- cat(1, val.bs)./cat(1, val.unc);
    plot(fBSInsp.ax(1), aTXcord_efrf, y, 'LineWidth',2, 'LineStyle',lnstl(qtl==qt), 'Color',Sett.quali_Dark2(2,:), 'Marker','none', 'MarkerSize',6);
%{
    test="Ubs_annual"+string(qt);
    val=efsrBrierScores{test, "LakeComo"}{1}(mask,1);
    y = 1- cat(1, val.bs)./cat(1, val.unc);
    plot(fBSInsp.ax(1), aTXcord_efsr, y, 'LineWidth',2, 'LineStyle',lnstl(qtl==qt), 'Color',Sett.quali_Dark2(3,:), 'Marker','none', 'MarkerSize',6);  
%}
end

plot(fBSInsp.ax(1), [1,aTXcord_efsr(end)], [0, 0], 'LineWidth',1, 'LineStyle', '--', 'Color', 'black');
plot(fBSInsp.ax(2), [1,aTXcord_efsr(end)], [0, 0], 'LineWidth',1, 'LineStyle', '--', 'Color', 'black');
ylim(fBSInsp.ax(1), [-0.2, 0.6] )
xlim(fBSInsp.ax(1), [0, 156] );
ylim(fBSInsp.ax(2), [-0.2, 0.6] )
xlim(fBSInsp.ax(2), [0, 156] );
xticks(fBSInsp.ax(1), aTXcord_efsr );
xticklabels(fBSInsp.ax(1), aTXtick );
xticks(fBSInsp.ax(2), aTXcord_efsr );
xticklabels(fBSInsp.ax(2), aTXtick );
yticklabels(fBSInsp.ax(2), {});
grid(fBSInsp.ax(1), "on");
grid(fBSInsp.ax(2), "on");

fBSInsp.ax(1).XAxis.FontSize = Sett.axFSize;
fBSInsp.ax(1).YAxis.FontSize = Sett.axFSize;
fBSInsp.ax(2).XAxis.FontSize = Sett.axFSize;
fBSInsp.ax(2).YAxis.FontSize = Sett.axFSize;
title(fBSInsp.ax(1), "UBSS for Low-flow threshold");
title(fBSInsp.ax(2), "UBSS for High-flow threshold");
xlabel(fBSInsp.ax(1), 'Aggregation Time', 'FontSize', Sett.labFSize );
xlabel(fBSInsp.ax(2), 'Aggregation Time', 'FontSize', Sett.labFSize );
ylabel(fBSInsp.ax(1), 'Brier Skill Score [-]', 'FontSize', Sett.labFSize );

clear y 
%% 
clear l aT_pro aT_efrf aT_efsr aTXcord_pro aTXcord_efrf aTXcord_efsr aTXtick val idx qt qtl test type types axidx
clear cicloDetScores efrfBrierScores efrfDetScores efrfProbScores efsrBrierScores efsrDetScores efsrProbScores PROGEADetScores

%% POP load
load( '~/Documents/Data/Solutions/DDP/ddpsol_99_18.mat' );
POP.reference = cat(1, ddpsol( cat(1,ddpsol.flag_ref)>0 ).J );
clear ddpsol qcr_h qcr_u Gbias Gk Gnorm H J period LakeComo
targetPOP = [4.45, 1.082067011416135e+03, 9.85];

%% BOP load
BOP = matlabize_solution( [data_folder,'BOP'], false, false );
%% RL main result
% rl wiht Best skill vs all Fore (1 input) vs all Fore (2input)
EOP_LakeComo_BestSkill_all_anom = matlabize_solution( [data_folder, 'EOP_LakeComo_BestSkill_all_anom'], false, false );
EOP_LakeComo_all_all_Norm = matlabize_solution( [data_folder, 'EOP_LakeComo_all_all_Norm'], false, false);
EOP_LakeComo_all_all_Norm_2input = matlabize_solution( [data_folder, 'EOP_LakeComo_all_all_Norm_2input'], false, false);
EOP_pro3d__and__allF_allAT_qtNorm = matlabize_solution( [data_folder, 'EOP_pro3d__and__allF_allAT_qtNorm'], false, false);

fRLmain.f = figure;
fRLmain.tl = tiledlayout(3,3);
fRLmain.tl.Padding = 'compact';
fRLmain.tl.TileSpacing = 'compact';

fRLmain.PF(1) = nexttile([2,1]); %2 rows 1 column
fRLmain.PF(2) = nexttile([2,1]);
fRLmain.PF(3) = nexttile([2,1]);
fRLmain.Metr(1) = nexttile;
fRLmain.Metr(2) = nexttile;
fRLmain.Metr(3) = nexttile;

sols = [BOP,            EOP_LakeComo_all_all_Norm, EOP_LakeComo_all_all_Norm_2input, EOP_LakeComo_BestSkill_all_anom, EOP_pro3d__and__allF_allAT_qtNorm] ;
solsCol = [Sett.gray;   Sett.quali_tab20(blu_,:);  Sett.quali_tab20(blu_+chiaro,:);  Sett.quali_tab20(arancio_,:); Sett.quali_tab20(rosso_+chiaro,:)];
solsLS = ["-", "-", "-","-","-"];
solsFRL = [0,0,3,0,5]; %shoudl be 0,2,3,1 but we don't want to repear the 3 so many times times
solsPS = [".",".",".",".","."];
steps = [4.2, 5.5, 7, 100];
names = ["4.5-5.5", "5.5-7", ">7"];
clear l

for idx = 1:3
    ax = fRLmain.PF(idx);
    grid(ax, 'on');
    hold(ax, 'on');
    ax.XAxis.FontSize = Sett.axFSize;
    ax.YAxis.FontSize = Sett.axFSize;
    xlim(ax, Sett.ParetoXLim )
    ylim(ax, Sett.ParetoYLim )
    xlabel(ax, 'Deficit [(m^3/s)^{eq}]', 'FontSize', Sett.labFSize);
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        l(1) = plot(ax,  p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 12,  'Color', Sett.black);
        title(ax, strcat("a) Flood: ", names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
        plot(ax,  1.082067011416135e+03, 9.85, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 12, 'Color', Sett.red );
    else
        title(ax, strcat( names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
    end
    
    for jdx = 1:length(sols)
        % for classic EMODPS
        set = sols(jdx).reference;
        
        p2d = set( set(:,1) >= steps(idx) & set(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        l(end+1) = plot(ax, p2d(:,1), p2d(:,2), 'LineStyle', solsLS(jdx), 'Marker', solsPS(jdx), 'MarkerSize', 12, 'LineWidth', 1.5, 'Color', solsCol(jdx,:) );
        
        add_labels(ax, solsFRL(jdx), p2d, sols(jdx), Sett, solsCol(jdx, :));
        
    end
end

ylabel(fRLmain.PF(1), 'Low level [day/year]', 'FontSize', Sett.labFSize);

clear idx jdx p2d ref set  ax
clear kdx pTheta ref_idx xShift yShift fc at_ at

% metrics for pareto front
draw_my_metrics( sols, fRLmain.Metr);
fRLmain.Metr(1).Title.String = "b) HV";
for idx = 1:3
    fRLmain.Metr(idx).ColorOrder = hex2rgb([solsCol;Sett.black]);
    fRLmain.Metr(idx).XAxis.FontSize = Sett.axFSize;
    fRLmain.Metr(idx).YAxis.FontSize = Sett.axFSize;
    fRLmain.Metr(idx).Title.FontSize = Sett.tFSize;
end

reorder = [1, 5, 4, 2, 3];
solsName = {'POP', 'EOP(d_t,h_t,q_{\lambda}^{BS})','EOP(d_t,h_t,q_{\lambda_1}^{\gamma_1},q_{\lambda_2}^{\gamma_2})','BOP(d_t,h_t)','EOP(d_t,h_t,q_{\lambda}^{\gamma})'};
fRLmain.leg = legend(l(reorder), solsName);
fRLmain.leg.Orientation = 'horizontal';
fRLmain.leg.FontSize = Sett.legFSize;
fRLmain.leg.Location = 'southoutside';
fRLmain.leg.NumColumns = 3;

clear idx reorder solsCol

fRLmain.f.Position(4) = fRLmain.f.Position(4)*1.2;

%saveas( iop_frl2.f, 'iop_frl2.png' );

clear reorder idx sols solsCol solsFRL solsLS solsName txt solsPS

%% RL vs ISA 
% R2 IIS real and perfect forecast residual
fRLvsISA.f = figure;
fRLvsISA.tl = tiledlayout(3,3);
fRLvsISA.PF(1) = nexttile([2,1]);
fRLvsISA.IIS(1) = nexttile([1,2]);
fRLvsISA.IIS(2) = nexttile([1,2]);
fRLvsISA.Metr(1) = nexttile([1,1]);
fRLvsISA.Metr(2) = nexttile([1,1]);
fRLvsISA.Metr(3) = nexttile([1,1]);

fRLvsISA.tl.Padding = 'compact';
fRLvsISA.tl.TileSpacing = 'compact';

IIS_res = load('~/Documents/Data/Solutions/IVS/sol86/ivsRes_mmA_PRO_sol86_n15.mat');

[IIS_res.X, IIS_res.R2, IIS_res.R2re] = summarize_IIS_result(IIS_res.results_iis_n);
draw_R2( IIS_res.R2([2,3,5],1), fRLvsISA.IIS(1));
%print_names( IIS_res.c_v, IIS_res.X)
fRLvsISA.IIS(1).XAxis.FontSize = Sett.axFSize;
fRLvsISA.IIS(1).XLabel.FontSize= Sett.labFSize;
fRLvsISA.IIS(1).YAxis.FontSize = Sett.axFSize;
fRLvsISA.IIS(1).YLabel.FontSize= Sett.labFSize;
fRLvsISA.IIS(1).Children(1).Color = hex2rgb(Sett.quali_tab20(verde_,:));
fRLvsISA.IIS(1).Children(2).FaceColor = hex2rgb(Sett.quali_tab20(verde_,:));
title(fRLvsISA.IIS(1), 'b) IIS with real forecasts','FontSize',Sett.tFSize);
fRLvsISA.IIS(1).XTickLabel = {'h_t,d_t','q_{14d}^{EFRF})', 'other vars'};
fRLvsISA.IIS(1).XLabel.String = {};

IIS_res = load('~/Documents/Data/Solutions/IVS/sol86/ivsRes_pI_pIA_sol86_n15.mat');

[IIS_res.X, IIS_res.R2, IIS_res.R2re] = summarize_IIS_result(IIS_res.results_iis_n);
draw_R2( IIS_res.R2([2,3,5],1), fRLvsISA.IIS(2))
%print_names( IIS_res.c_v, IIS_res.X)
fRLvsISA.IIS(2).XAxis.FontSize = Sett.axFSize;
fRLvsISA.IIS(2).XLabel.FontSize= Sett.labFSize;
fRLvsISA.IIS(2).YAxis.FontSize = Sett.axFSize;
fRLvsISA.IIS(2).YLabel.FontSize= Sett.labFSize;
fRLvsISA.IIS(2).Children(1).Color = hex2rgb(Sett.quali_tab20(viola_,:));
fRLvsISA.IIS(2).Children(2).FaceColor = hex2rgb(Sett.quali_tab20(viola_,:));
title(fRLvsISA.IIS(2), 'c) IIS with perfect forecasts','FontSize',Sett.tFSize);
fRLvsISA.IIS(2).XTickLabel = {'h_t,d_t','q_{21d}^{PF}',  'other vars'};
fRLvsISA.IIS(2).XLabel.String = {};

fRLvsISA.f.Position(4) = fRLvsISA.f.Position(4)*1.1;

clear IIS_res 
EOP_pI_all_anom = matlabize_solution( [data_folder, 'EOP_pI_all_anom'], false, false );
IOP_LakeComo14dmeanAnom = matlabize_solution( [data_folder, 'IOP_LakeComo14dmeanAnom'], false, false );
IOP_qAgg21dAnom = matlabize_solution( [data_folder, 'IOP_qAgg21dAnom'], false, false );

sols = [BOP,            IOP_LakeComo14dmeanAnom,    EOP_LakeComo_all_all_Norm,  IOP_qAgg21dAnom,            EOP_pI_all_anom] ;
solsCol = [Sett.gray;   Sett.quali_tab20(verde_,:); Sett.quali_tab20(blu_,:);   Sett.quali_tab20(viola_,:); Sett.quali_tab20(viola_ +chiaro,:);];
solsLS = ["-",          "-",                        "--",                       "-",                        "--"];
solsMS = [".",          ".",                        "none",                     ".",                        "none"]; 
solsFRL = [0,0,0,0,0];

clear l
for idx = 1
    ax = fRLvsISA.PF(idx);
    grid(ax, 'on');
    hold(ax, 'on');
    ax.XAxis.FontSize = Sett.axFSize;
    ax.YAxis.FontSize = Sett.axFSize;
    xlim(ax, Sett.ParetoXLim )
    ylim(ax, Sett.ParetoYLim )
    xlabel(ax, 'Deficit [(m^3/s)^{eq}]', 'FontSize', Sett.labFSize);
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        l(1) = plot(ax,  p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 12,  'Color', Sett.black);
        title(ax, strcat("a) Flood: ", names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
        plot(ax,  1.082067011416135e+03, 9.85, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 12, 'Color', Sett.red );
    else
        % since I don't have for the other levels
        title(ax, strcat( names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
    end
    
    for jdx = 1:length(sols)
        % for classic EMODPS
        set = sols(jdx).reference;
        
        p2d = set( set(:,1) >= steps(idx) & set(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        l(end+1) = plot(ax, p2d(:,1), p2d(:,2), 'LineStyle', solsLS(jdx), 'Marker', solsMS(jdx), 'MarkerSize', 12, 'LineWidth', 1.5, 'Color', solsCol(jdx,:) );
        
        add_labels(ax, solsFRL(jdx), p2d, sols(jdx), Sett, solsCol(jdx, :));
    end
end

ylabel(fRLvsISA.PF(1), 'Low level [day/year]', 'FontSize', Sett.labFSize);

clear ax idx jdx p2d set solsMS solsLS solsFRL

% metrics for pareto front
draw_my_metrics( sols, fRLvsISA.Metr);
fRLvsISA.Metr(1).Title.String = "d) HV";
for idx = 1:3
    fRLvsISA.Metr(idx).ColorOrder = hex2rgb([solsCol;Sett.black]);
    fRLvsISA.Metr(idx).XAxis.FontSize = Sett.axFSize;
    fRLvsISA.Metr(idx).YAxis.FontSize = Sett.axFSize;
    fRLvsISA.Metr(idx).Title.FontSize = Sett.tFSize;
end
reorder = [1,5,3,2,6,4];
solsName = {'POP', 'IOP(d_t,h_t,q_{21d}^{PF})','IOP(d_t,h_t,q_{14d}^{EFRF})','BOP(d_t,h_t)','EOP(d_t,h_t,q_{\lambda}^{PF})','EOP(d_t,h_t,q_{\lambda}^{\gamma})'};
fRLvsISA.leg = legend(l(reorder), solsName);
fRLvsISA.leg.Orientation = 'horizontal';
fRLvsISA.leg.FontSize = Sett.legFSize;
fRLvsISA.leg.Location = 'southoutside';
fRLvsISA.leg.NumColumns = 3;

clear idx reorder solsCol

fRLvsISA.f.Position(4) = fRLvsISA.f.Position(4)*1.1;

%saveas( modISA.f, 'modISA.png' );
% add arrows (PF e HV) and reorder objects

%% cyclostationary trajectories 
EOP_LakeComo_all_all_Norm = matlabize_solution('~/Documents/Data/Solutions/EMODPS/EOP_LakeComo_all_all_Norm_MATLAB', false, false);
sols = [BOP, IOP_LakeComo14dmeanAnom, IOP_qAgg21dAnom, EOP_LakeComo_all_all_Norm];
solsName = {'BOP(d_t,h_t)', 'IOP(d_t,h_t,q_{14d}^{EFRF})', 'IOP(d_t,h_t,q_{21d}^{PF})', 'EOP(d_t,h_t,q_\lambda^\gamma=q_{3d}^{PRO})'};
solsCol = [Sett.gray; Sett.quali_tab20(verde_,:); Sett.quali_tab20(viola_,:); Sett.quali_tab20(blu_,:)];
solsLS = ["-", "-", "-", "-"];
solMD = [false, false, false, true];

% cyclostationary
levelsol869918 = load( '~/Documents/Data/Solutions/DDP/level_sol86_99_18.txt', '-ascii' );
releasesol869918 = load( '~/Documents/Data/Solutions/DDP/release_sol86_99_18.txt', '-ascii' );
aggregateddemand = load( '~/Documents/Data/LakeComoRawData/utils/aggregated_demand.txt', '-ascii' );
labFSize = Sett.labFSize;

draw_ciclostoragetraj;
cycloSim.leg.FontSize = Sett.legFSize;
cycloSim.leg.Location = 'southoutside';
cycloSim.leg.Orientation = 'horizontal';

cycloSim.lev.XAxis.FontSize = Sett.axFSize;
cycloSim.lev.YAxis.FontSize = Sett.axFSize;
cycloSim.rel.XAxis.FontSize = Sett.axFSize;
cycloSim.rel.YAxis.FontSize = Sett.axFSize;

%title(ciclev, 'Cyclostationary trajectory of level and release', 'FontSize',Sett.tFSize );
title(cycloSim.lev, 'a) Level', 'FontSize',Sett.tFSize );
title(cycloSim.rel, 'b) Release', 'FontSize',Sett.tFSize );
cycloSim.leg.NumColumns = 3;

%saveas( cycloSim.f, 'cyclos.fig' );
%saveas( cycloSim.f, 'cyclos.png' );

clear labFSize cl h J jdx ls mdc r solnumber time ciclevlo
clear sols solsCol solsName solsLS
clear aggregateddemand levelsol869918 releasesol869918 

%% RL for Supplementary Material
% perfect forecast vs all forecasts vs only efrf
EOP_LakeComo_all_all_Norm =  matlabize_solution( '~/Documents/Data/Solutions/EMODPS/EOP_LakeComo_all_all_Norm', false, false );
EOP_LakeComo_efrf_all_anom = matlabize_solution( '~/Documents/Data/Solutions/EMODPS/EOP_LakeComo_efrf_all_anom', false, false );

fRLsupp2.f = figure;
fRLsupp2.tl = tiledlayout(3,3);
fRLsupp2.tl.Padding = 'compact';
fRLsupp2.tl.TileSpacing = 'compact';

fRLsupp2.PF(1) = nexttile([2,1]); %2 rows 1 column
fRLsupp2.PF(2) = nexttile([2,1]);
fRLsupp2.PF(3) = nexttile([2,1]);
fRLsupp2.Metr(1) = nexttile;
fRLsupp2.Metr(2) = nexttile;
fRLsupp2.Metr(3) = nexttile;

sols = [BOP,          EOP_LakeComo_efrf_all_anom,        EOP_LakeComo_all_all_Norm, EOP_pI_all_anom] ;
solsCol = [Sett.gray; Sett.quali_tab20(verde_+chiaro,:); Sett.quali_tab20(blu_,:);    Sett.quali_tab20(viola_+chiaro,:)];
solsLS = ["-",        "-",                                "-",                      "-"];
solsFRL = [0,1,2,1];

clear l

for idx = 1:3
    ax = fRLsupp2.PF(idx);
    grid(ax, 'on');
    hold(ax, 'on');
    ax.XAxis.FontSize = Sett.axFSize;
    ax.YAxis.FontSize = Sett.axFSize;
    xlim(ax, Sett.ParetoXLim )
    ylim(ax, Sett.ParetoYLim )
    xlabel(ax, 'Deficit [(m^3/s)^{eq}]', 'FontSize', Sett.labFSize);
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        l(1) = plot(ax,  p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 12,  'Color', Sett.black);
        title(ax, strcat("a) Flood: ", names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
        plot(ax,  1.082067011416135e+03, 9.85, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 12, 'Color', Sett.red );
    else
        title(ax, strcat( names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
    end
    
    for jdx = 1:length(sols)
        
        set = sols(jdx).reference;
        
        p2d = set( set(:,1) >= steps(idx) & set(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        l(end+1) = plot(ax, p2d(:,1), p2d(:,2), 'LineStyle', solsLS(jdx), 'Marker', '.', 'MarkerSize', 12, 'LineWidth', 1.5, 'Color', solsCol(jdx,:) );
        
        add_labels(ax, solsFRL(jdx), p2d, sols(jdx), Sett, solsCol(jdx, :));
    end
end

ylabel(fRLsupp2.PF(1), 'Low level [day/year]', 'FontSize', Sett.labFSize);

clear idx jdx p2d ref set ax
clear kdx pTheta ref_idx xShift yShift fc at_ at

% metrics for pareto front
draw_my_metrics( sols, fRLsupp2.Metr);
fRLsupp2.Metr(1).Title.String = "b) HV";
for idx = 1:3
    fRLsupp2.Metr(idx).ColorOrder = hex2rgb([solsCol;Sett.black]);
    fRLsupp2.Metr(idx).XAxis.FontSize = Sett.axFSize;
    fRLsupp2.Metr(idx).YAxis.FontSize = Sett.axFSize;
    fRLsupp2.Metr(idx).Title.FontSize = Sett.tFSize;
end

reorder = [1,5,4,2,3];
solsName = {'POP', 'EOP(d_t,h_t,q_{\lambda}^{PF})','EOP(d_t,h_t,q_{\lambda}^{\gamma})','BOP(d_t,h_t)','EOP(d_t,h_t,q_{\lambda}^{EFRF})'};
fRLsupp2.leg = legend(l(reorder), solsName);
fRLsupp2.leg.Orientation = 'horizontal';
fRLsupp2.leg.FontSize = Sett.legFSize;
fRLsupp2.leg.Location = 'southoutside';
fRLsupp2.leg.NumColumns = 3;

clear idx reorder solsCol

fRLsupp2.f.Position(4) = fRLsupp2.f.Position(4)*1.2;

%saveas( iop_frl.f, 'iop_frl.png' );

clear  reorder idx sols solsCol solsFRL solsLS solsName txt

%% RL supp info 3 uncertainty 
%IOP_LakeComo14dmeanAnom
IOP_LakeComo14dmeanAnom_LakeComo14dvar = matlabize_solution( [data_folder, 'IOP_LakeComo14dmean_LakeComo14dvar'], false, false);

fRLsupp3.f = figure;
fRLsupp3.tl = tiledlayout(3,3, 'TileSpacing', 'compact', 'Padding', 'compact');

fRLsupp3.PF(1) = nexttile([2,1]); %2 rows 1 column
fRLsupp3.PF(2) = nexttile([2,1]);
fRLsupp3.PF(3) = nexttile([2,1]);
fRLsupp3.Metr(1) = nexttile;
fRLsupp3.Metr(2) = nexttile;
fRLsupp3.Metr(3) = nexttile;

sols = [BOP,          IOP_LakeComo14dmeanAnom,        IOP_LakeComo14dmeanAnom_LakeComo14dvar]; 
solsCol = [Sett.gray; Sett.quali_tab20(verde_,:); Sett.quali_tab20(verde_+chiaro,:)];
solsLS = ["-",        "-",                                "--"];
solsFRL = [0,0,0,0];

clear l

for idx = 1:3
    ax = fRLsupp3.PF(idx);
    grid(ax, 'on');
    hold(ax, 'on');
    ax.XAxis.FontSize = Sett.axFSize;
    ax.YAxis.FontSize = Sett.axFSize;
    xlim(ax, Sett.ParetoXLim )
    ylim(ax, Sett.ParetoYLim )
    xlabel(ax, 'Deficit [(m^3/s)^{eq}]', 'FontSize', Sett.labFSize);
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        l(1) = plot(ax,  p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 12,  'Color', Sett.black);
        title(ax, strcat("a) Flood: ", names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
        plot(ax,  1.082067011416135e+03, 9.85, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 12, 'Color', Sett.red );
    else
        title(ax, strcat( names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
    end
    
    for jdx = 1:length(sols)
        
        set = sols(jdx).reference;
        
        p2d = set( set(:,1) >= steps(idx) & set(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        l(end+1) = plot(ax, p2d(:,1), p2d(:,2), 'LineStyle', solsLS(jdx), 'Marker', '.', 'MarkerSize', 12, 'LineWidth', 1.5, 'Color', solsCol(jdx,:) );
        
        add_labels(ax, solsFRL(jdx), p2d, sols(jdx), Sett, solsCol(jdx, :));
    end
end

ylabel(fRLsupp3.PF(1), 'Low level [day/year]', 'FontSize', Sett.labFSize);

clear idx jdx p2d ref set ax
clear kdx pTheta ref_idx xShift yShift fc at_ at

% metrics for pareto front
draw_my_metrics( sols, fRLsupp3.Metr);
fRLsupp3.Metr(1).Title.String = "b) HV";
for idx = 1:3
    fRLsupp3.Metr(idx).ColorOrder = hex2rgb([solsCol;Sett.black]);
    fRLsupp3.Metr(idx).XAxis.FontSize = Sett.axFSize;
    fRLsupp3.Metr(idx).YAxis.FontSize = Sett.axFSize;
    fRLsupp3.Metr(idx).Title.FontSize = Sett.tFSize;
end

reorder = [1,3,2,4];
solsName = {'POP', 'IOP(d_t,h_t,q_{14d}^{EFRF})','BOP(d_t,h_t)','IOP(d_t,h_t,q_{14d}^{EFRF}),var(\bmq\rm_{14d}^{EFRF}))'};
fRLsupp3.leg = legend(l(reorder), solsName);
fRLsupp3.leg.Orientation = 'horizontal';
fRLsupp3.leg.FontSize = Sett.legFSize;
fRLsupp3.leg.Location = 'southoutside';
fRLsupp3.leg.NumColumns = 2;

clear idx reorder solsCol

fRLsupp3.f.Position(4) = fRLsupp3.f.Position(4)*1.2;

%saveas( iop_frl.f, 'iop_frl.png' );

clear  reorder idx sols solsCol solsFRL solsLS solsName txt

%% RL supp info 4 quantile selection
% EOP_LakeComo_all_all_Norm
% EOP_LakeComo_efrf_all_anom  
EOP_LakeComo_all_all_qtNorm = matlabize_solution( [data_folder, 'EOP_LakeComo_all_all_qtNorm'], false, false);


fRLsupp4.f = figure;
fRLsupp4.tl = tiledlayout(3,3, 'TileSpacing', 'compact', 'Padding', 'compact');

fRLsupp4.PF(1) = nexttile([2,1]); %2 rows 1 column
fRLsupp4.PF(2) = nexttile([2,1]);
fRLsupp4.PF(3) = nexttile([2,1]);
fRLsupp4.Metr(1) = nexttile;
fRLsupp4.Metr(2) = nexttile;
fRLsupp4.Metr(3) = nexttile;
Sett.quali_tab20(verde_+chiaro,:); Sett.quali_tab20(blu_,:);
sols = [BOP,          EOP_LakeComo_all_all_Norm, EOP_LakeComo_all_all_Norm_2input, EOP_LakeComo_all_all_qtNorm, EOP_pro3d__and__allF_allAT_qtNorm]; 
solsCol = [Sett.gray; Sett.quali_tab20(blu_,:); Sett.quali_tab20(blu_+chiaro,:); Sett.quali_tab20(rosso_,:); Sett.quali_tab20(rosso_+chiaro,:) ];
solsLS = ["-",        "-",                                "-",                        "-",                        "-"];
solsFRL = [0,0,3,0,5];

clear l

for idx = 1:3
    ax = fRLsupp4.PF(idx);
    grid(ax, 'on');
    hold(ax, 'on');
    ax.XAxis.FontSize = Sett.axFSize;
    ax.YAxis.FontSize = Sett.axFSize;
    xlim(ax, Sett.ParetoXLim )
    ylim(ax, Sett.ParetoYLim )
    xlabel(ax, 'Deficit [(m^3/s)^{eq}]', 'FontSize', Sett.labFSize);
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        l(1) = plot(ax,  p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 12,  'Color', Sett.black);
        title(ax, strcat("a) Flood: ", names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
        plot(ax,  1.082067011416135e+03, 9.85, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 12, 'Color', Sett.red );
    else
        title(ax, strcat( names(idx)," [d/y]"), 'FontSize', Sett.tFSize );
    end
    
    for jdx = 1:length(sols)
        
        set = sols(jdx).reference;
        
        p2d = set( set(:,1) >= steps(idx) & set(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        l(end+1) = plot(ax, p2d(:,1), p2d(:,2), 'LineStyle', solsLS(jdx), 'Marker', '.', 'MarkerSize', 12, 'LineWidth', 1.5, 'Color', solsCol(jdx,:) );
        
        add_labels(ax, solsFRL(jdx), p2d, sols(jdx), Sett, solsCol(jdx, :));
    end
end

ylabel(fRLsupp4.PF(1), 'Low level [day/year]', 'FontSize', Sett.labFSize);

clear idx jdx p2d ref set ax
clear kdx pTheta ref_idx xShift yShift fc at_ at

% metrics for pareto front
draw_my_metrics( sols, fRLsupp4.Metr);
fRLsupp4.Metr(1).Title.String = "b) HV";
for idx = 1:3
    fRLsupp4.Metr(idx).ColorOrder = hex2rgb([solsCol;Sett.black]);
    fRLsupp4.Metr(idx).XAxis.FontSize = Sett.axFSize;
    fRLsupp4.Metr(idx).YAxis.FontSize = Sett.axFSize;
    fRLsupp4.Metr(idx).Title.FontSize = Sett.tFSize;
end

reorder = [1,3,5,2,4,6];
solsName = {'POP', 'EOP(d_t,h_t,q_{\lambda}^{\gamma})','EOP(d_t,h_t,q_{\lambda_1}^{\gamma_1},q_{\lambda_2}^{\gamma_2})','BOP(d_t,h_t)','EOP(d_t,h_t,quantile_\phi(\bfq\rm_{\lambda}^{\gamma}))', 'EOP(d_t,h_t,quantile_{\phi_1}(\bfq\rm_{\lambda_1}^{\gamma_1}),quantile_{\phi_2}(\bfq\rm_{\lambda_2}^{\gamma_2}))'};
fRLsupp4.leg = legend(l(reorder), solsName);
fRLsupp4.leg.Orientation = 'horizontal';
fRLsupp4.leg.FontSize = Sett.legFSize;
fRLsupp4.leg.Location = 'southoutside';
fRLsupp4.leg.NumColumns = 3;

clear idx reorder solsCol

fRLsupp4.f.Position(4) = fRLsupp4.f.Position(4)*1.2;

%saveas( iop_frl.f, 'iop_frl.png' );

clear  reorder idx sols solsCol solsFRL solsLS solsName txt