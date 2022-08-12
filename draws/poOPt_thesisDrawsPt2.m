%% second iteration start with cumulative R2 della IIS(1 fig perf e real)
IIS_res = load('/Users/denniszanutto/Documents/Data/ivs_solutions/sol86/ivsRes_mmA_sol86_n15.mat');

[IIS_res.X, IIS_res.R2, IIS_res.R2re] = summarize_IIS_result(IIS_res.results_iis_n);
print_names(IIS_res.c_v, IIS_res.X)
draw_R2( IIS_res.R2(:,1) )
ax = gca;
ax.XAxis.FontSize = axFSize*2;
ax.XLabel.FontSize= labFSize*2;
ax.YAxis.FontSize = axFSize*2;
ax.YLabel.FontSize= labFSize*2;
ax.Children(1).Color = hex2rgb(Tcolor.sig1(2,:));
ax.Children(2).FaceColor = hex2rgb(Tcolor.sig1(2,:));
title('R2 of the MISO models across iterations-single run','FontSize',tFSize*1.5);
ax.XTickLabel = {'h_t','d_t','dis_{14d-anom}^{efrf,LC}', 'dis_{5mo-anom}^{efsr,M}'};

draw_colorMap( IIS_res.X, IIS_res.R2 )
iis_r1_real = gcf;
iis_r1_real.Children(1).Children(2).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(2).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(2), 'Input ranking-multiple runs','FontSize',tFSize*1.5);

iis_r1_real.Children(1).Children(1).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(1).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(1), 'R2 final MISO model-multiple runs','FontSize',tFSize*1.5);

%% 
IIS_res = load('/Users/denniszanutto/Documents/Data/ivs_solutions/sol86/ivsRes_pI_pIA_sol86_n15.mat');

[IIS_res.X, IIS_res.R2, IIS_res.R2re] = summarize_IIS_result(IIS_res.results_iis_n);
print_names(IIS_res.c_v, IIS_res.X)
draw_R2( IIS_res.R2(:,1) )
ax = gca;
ax.XAxis.FontSize = axFSize*1.5;
ax.XLabel.FontSize= labFSize*2;
ax.YAxis.FontSize = axFSize*1.5;
ax.YLabel.FontSize= labFSize*2;
ax.Children(1).Color = hex2rgb(Tcolor.sig2(2,:));
ax.Children(2).FaceColor = hex2rgb(Tcolor.sig2(2,:));
title('R2 of the MISO models across iterations-single run','FontSize',tFSize*1.5);
ax.XTickLabel = {'h_t','d_t','dis_{21d-anom}^{perf}',  'dis_{24}^{perf}', 'dis_{7mo-anom}^{perf}'};

draw_colorMap( IIS_res.X, IIS_res.R2 )
iis_r1_real = gcf;
iis_r1_real.Children(1).Children(2).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(2).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(2), 'Input ranking-multiple runs','FontSize',tFSize*1.5);

iis_r1_real.Children(1).Children(1).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(1).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(1), 'R2 final MISO model-multiple runs','FontSize',tFSize*1.5);

%% IOP pareto 5d (1 fig perf real e anom)
iop_r2_pareto_slice = figure('WindowState','fullscreen');
iop_r2_pareto_sliceTL = tiledlayout(1,3);

sols = [BOP, IOP_LakeComo14dmeanAnom, IOP_LakeComo14dmeanAnom_Mandello5momeanAnom, IOP_qAgg21dAnom] ;
solsName = {'BOP(d_t,h_t)', 'IOP(d_t,h_t,dis_{14d-anom}^{efrf,LC})', 'IOP(d_t,h_t,dis_{14d-anom}^{efrf,LC},dis_{5mo-anom}^{efsr,M})', 'IOP(d_t,h_t,dis_{21d-anom}^{perf})'};
solsCol = [Tcolor.gray;Tcolor.sig1(2,:);Tcolor.sig1(3,:);Tcolor.sig2(2,:);];
solLS = ["-", "-", "--","-"];
steps = [4.2, 5.5, 7, 100];
names = ["4.5-5.5", "5.5-7", ">7"];

for idx = 1:3
    ax = nexttile;
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        plot( p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 12,  'Color', Tcolor.black);
    else
        % since I don't have for the other levels
        plot( p2d(:,1), p2d(:,2), 'LineStyle', ':', 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 12, 'Color', Tcolor.black);
    end
    
    hold on
    for jdx = 1:length(sols)
        set = sols(jdx).reference;
        ref = [ round(set(:,1), 1), set(:,2), set(:,3) ];
        
        p2d = ref( ref(:,1) >= steps(idx) & ref(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        plot( p2d(:,1), p2d(:,2), 'LineStyle', solLS(jdx), 'Marker', 'o', 'MarkerSize', 14, 'LineWidth', 4, 'Color', solsCol(jdx,:) );
    end
    if idx == 2
        % legend
        iop_r2_pareto_sliceLeg = legend;
    end
    
    ax.XAxis.FontSize = axFSize;
    ax.YAxis.FontSize = axFSize;
    xlim(ax, [1000, 2000] )
    ylim(ax, [0, 50] )
    title(ax, strcat("Flood ",names(idx)," [d/y]"), 'FontSize', tFSize );
    grid on
    xlabel( 'Deficit [(m^3/s)^{eq}]', 'FontSize', labFSize);
end
iop_r2_pareto_sliceTL.Padding = 'compact';
iop_r2_pareto_sliceTL.TileSpacing = 'compact';

ylabel(iop_r2_pareto_sliceTL, 'Low level [day/year]', 'FontSize', labFSize);

iop_r2_pareto_sliceLeg.String = [{'POP'}, solsName];
iop_r2_pareto_sliceLeg.FontSize = legFSize;
iop_r2_pareto_sliceLeg.Location = 'southoutside';
iop_r2_pareto_sliceLeg.Orientation = 'horizontal';

%% metriche (1 fig perf real e real anom)
[iop_r2_metrics, iop_r2_metricsLeg] = draw_my_metrics( sols );
for idx = [1,3,4]
    iop_r2_metrics.Children(1).Children(idx).ColorOrder = hex2rgb([solsCol;Tcolor.black]);
    iop_r2_metrics.Children(1).Children(idx).XAxis.FontSize = axFSize;
    iop_r2_metrics.Children(1).Children(idx).YAxis.FontSize = axFSize;
    iop_r2_metrics.Children(1).Children(idx).Title.FontSize = tFSize;
end
iop_r2_metricsLeg.String = [solsName, {'POP'}];
iop_r2_metricsLeg.Orientation = 'horizontal';
iop_r2_metricsLeg.FontSize = legFSize;

%% ciclostaz usa file
draw_ciclostoragetraj;
cicLeg.FontSize = legFSize-2;
cicLeg.Location = 'southoutside';
cicLeg.Orientation = 'horizontal';

ciclev.XAxis.FontSize = axFSize;
ciclev.YAxis.FontSize = axFSize;
cicrel.XAxis.FontSize = axFSize;
cicrel.YAxis.FontSize = axFSize;

title(ciclev, 'Ciclostationary trajectory of level and release', 'FontSize',tFSize ) 

%% second iteration start with cumulative R2 della IIS(1 fig perf e real)
IIS_res = load('/Users/denniszanutto/Documents/Data/ivs_solutions/sol86/ivsRes_mmA_PRO_sol86_n15.mat');

[IIS_res.X, IIS_res.R2, IIS_res.R2re] = summarize_IIS_result(IIS_res.results_iis_n);
print_names(IIS_res.c_v, IIS_res.X)
draw_R2( IIS_res.R2(:,1) )
ax = gca;
ax.XAxis.FontSize = axFSize*1.5;
ax.XLabel.FontSize= labFSize*2;
ax.YAxis.FontSize = axFSize*1.5;
ax.YLabel.FontSize= labFSize*2;
ax.Children(1).Color = hex2rgb(Tcolor.sig1(2,:));
ax.Children(2).FaceColor = hex2rgb(Tcolor.sig1(2,:));
title('R2 of the MISO models across iterations-single run','FontSize',tFSize*1.5);
ax.XTickLabel = {'h_t','d_t','dis_{14d-anom}^{efrf,LC}','dis_{24}^{PROGEA}','dis_{5m-anom}^{efsr,LC}'};

draw_colorMap( IIS_res.X, IIS_res.R2 )
iis_r1_real = gcf;
iis_r1_real.Children(1).Children(2).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(2).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(2), 'Input ranking-multiple runs','FontSize',tFSize*1.5);

iis_r1_real.Children(1).Children(1).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(1).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(1), 'R2 final MISO model-multiple runs','FontSize',tFSize*1.5);

%% IOP pareto r3 (1 fig perf real e anom)
iop_r3_pareto_slice = figure('WindowState','fullscreen');
iop_r3_pareto_sliceTL = tiledlayout(1,3);

sols = [BOP, IOP_LakeComo14dmeanAnom, IOP_LakeComo14dmeanAnom_PROGEA1d, IOP_LakeComo14dmeanAnom_PROGEA1d_Mandello5momeanAnom] ;
solsName = {'BOP(d_t,h_t)', 'IOP(d_t,h_t,dis_{14d-anom}^{efrf,LC})', 'IOP(d_t,h_t,dis_{14d-anom}^{efrf,LC},dis_{24}^{PROGEA})', 'IOP(d_t,h_t,dis_{14d-anom}^{efrf,LC},dis_{24}^{PROGEA},dis_{5mo-anom}^{efsr,M})'};
solsCol = [Tcolor.gray;Tcolor.sig1(2,:);Tcolor.sig1(3,:);Tcolor.sig1(4,:);];
solLS = ["-", "-", "--",":"];

for idx = 1:3
    ax = nexttile;
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        plot( p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 12, 'Color', Tcolor.black);
    else
        % since I don't have for the other levels
        plot( p2d(:,1), p2d(:,2), 'LineStyle', ':', 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 12, 'Color', Tcolor.black );
    end
    
    hold on
    for jdx = 1:length(sols)
        set = sols(jdx).reference;
        ref = [ round(set(:,1), 1), set(:,2), set(:,3) ];
        
        p2d = ref( ref(:,1) >= steps(idx) & ref(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        plot( p2d(:,1), p2d(:,2), 'LineStyle', solLS(jdx), 'Marker', 'o', 'MarkerSize', 14, 'LineWidth', 4, 'Color', solsCol(jdx,:) );
    end
    if idx == 2
        % legend
        iop_r3_pareto_sliceLeg = legend;
    end
    
    ax.XAxis.FontSize = axFSize;
    ax.YAxis.FontSize = axFSize;
    xlim(ax, [1000, 2000] )
    ylim(ax, [0, 50] )
    title(ax, strcat("Flood ",names(idx)," [d/y]"), 'FontSize', tFSize );
    grid on
    xlabel( 'Deficit [(m^3/s)^{eq}]', 'FontSize', labFSize);
end
iop_r3_pareto_sliceTL.Padding = 'compact';
iop_r3_pareto_sliceTL.TileSpacing = 'compact';
ylabel(iop_r3_pareto_sliceTL, 'Low level [day/year]', 'FontSize', labFSize);


iop_r3_pareto_sliceLeg.String = [{'POP'}, solsName];
iop_r3_pareto_sliceLeg.FontSize = legFSize-4;
iop_r3_pareto_sliceLeg.Location = 'southoutside';
iop_r3_pareto_sliceLeg.Orientation = 'horizontal';

%% metriche (1 fig perf real e real anom)
[iop_r3_metrics, iop_r3_metricsLeg] = draw_my_metrics( sols );
for idx = [1,3,4]
    iop_r3_metrics.Children(1).Children(idx).ColorOrder = hex2rgb([solsCol;Tcolor.black]);
    iop_r3_metrics.Children(1).Children(idx).XAxis.FontSize = axFSize;
    iop_r3_metrics.Children(1).Children(idx).YAxis.FontSize = axFSize;
    iop_r3_metrics.Children(1).Children(idx).Title.FontSize = tFSize;
end
iop_r3_metricsLeg.String = [solsName, {'POP'}];
iop_r3_metricsLeg.Orientation = 'horizontal';
iop_r3_metricsLeg.FontSize = legFSize-4;

%% ciclostaz usa file
draw_ciclostoragetraj;
cicLeg.FontSize = legFSize-6;
cicLeg.Location = 'southoutside';
cicLeg.Orientation = 'horizontal';

ciclev.XAxis.FontSize = axFSize;
ciclev.YAxis.FontSize = axFSize;
cicrel.XAxis.FontSize = axFSize;
cicrel.YAxis.FontSize = axFSize;

title(ciclev, 'Ciclostationary trajectory of level and release', 'FontSize',tFSize ) 

%% IOP pareto r3 (1 fig perf real e anom)
iop_r3Pf_pareto_slice = figure('WindowState','fullscreen');
iop_r3Pf_pareto_sliceTL = tiledlayout(1,3);

sols = [BOP, IOP_qAgg21dAnom, IOP_qAgg21dAnom_qAgg1d, IOP_qAgg21dAnom_qAgg1d_qAgg7moAnom] ;
solsName = {'BOP(d_t,h_t)', 'IOP(d_t,h_t,dis_{21d-anom}^{perf})', 'IOP(d_t,h_t,dis_{21d-anom}^{perf},dis_{24}^{perf})', 'IOP(d_t,h_t,dis_{21d-anom}^{perf},dis_{24}^{perf},dis_{7mo-anom}^{perf})'};
solsCol = [Tcolor.gray;Tcolor.sig2(2,:);Tcolor.sig2(3,:);Tcolor.sig2(4,:);];
solLS = ["-", "-", "--",":"];

for idx = 1:3
    ax = nexttile;
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        plot( p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 12, 'Color', Tcolor.black);
    else
        % since I don't have for the other levels
        plot( p2d(:,1), p2d(:,2), 'LineStyle', ':', 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 12, 'Color', Tcolor.black );
    end
    
    hold on
    for jdx = 1:length(sols)
        set = sols(jdx).reference;
        ref = [ round(set(:,1), 1), set(:,2), set(:,3) ];
        
        p2d = ref( ref(:,1) >= steps(idx) & ref(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        plot( p2d(:,1), p2d(:,2), 'LineStyle', solLS(jdx), 'Marker', 'o', 'MarkerSize', 14, 'LineWidth', 4, 'Color', solsCol(jdx,:) );
    end
    if idx == 2
        % legend
        iop_r3Pf_pareto_sliceLeg = legend;
    end
    
    ax.XAxis.FontSize = axFSize;
    ax.YAxis.FontSize = axFSize;
    xlim(ax, [1000, 2000] )
    ylim(ax, [0, 50] )
    title(ax, strcat("Flood ",names(idx)," [d/y]"), 'FontSize', tFSize );
    grid on
    xlabel( 'Deficit [(m^3/s)^{eq}]', 'FontSize', labFSize);
end
iop_r3Pf_pareto_sliceTL.Padding = 'compact';
iop_r3Pf_pareto_sliceTL.TileSpacing = 'compact';

ylabel(iop_r3Pf_pareto_sliceTL, 'Low level [day/year]', 'FontSize', labFSize);


iop_r3Pf_pareto_sliceLeg.String = [{'POP'}, solsName];
iop_r3Pf_pareto_sliceLeg.FontSize = legFSize-2;
iop_r3Pf_pareto_sliceLeg.Location = 'southoutside';
iop_r3Pf_pareto_sliceLeg.Orientation = 'horizontal';

%% metriche (1 fig perf real e real anom)
[iop_r3Pf_metrics, iop_r3Pf_metricsLeg] = draw_my_metrics( sols );
for idx = [1,3,4]
    iop_r3Pf_metrics.Children(1).Children(idx).ColorOrder = hex2rgb([solsCol;Tcolor.black]);
    iop_r3Pf_metrics.Children(1).Children(idx).XAxis.FontSize = axFSize;
    iop_r3Pf_metrics.Children(1).Children(idx).YAxis.FontSize = axFSize;
    iop_r3Pf_metrics.Children(1).Children(idx).Title.FontSize = tFSize;
end
iop_r3Pf_metricsLeg.String = [solsName, {'POP'}];
iop_r3Pf_metricsLeg.Orientation = 'horizontal';
iop_r3Pf_metricsLeg.FontSize = legFSize-2;

%% ciclostaz usa file
draw_ciclostoragetraj;
cicLeg.FontSize = legFSize-6;
cicLeg.Location = 'southoutside';
cicLeg.Orientation = 'horizontal';

ciclev.XAxis.FontSize = axFSize;
ciclev.YAxis.FontSize = axFSize;
cicrel.XAxis.FontSize = axFSize;
cicrel.YAxis.FontSize = axFSize;

title(ciclev, 'Ciclostationary trajectory of level and release', 'FontSize',tFSize ) 
%% 
IIS_res = load('/Users/denniszanutto/Documents/Data/ivs_solutions/sol86/ivsRes_mA_PRO_LCqtMD_sol86_n15.mat');

[IIS_res.X, IIS_res.R2, IIS_res.R2re] = summarize_IIS_result(IIS_res.results_iis_n);
print_names(IIS_res.c_v, IIS_res.X)
draw_R2( IIS_res.R2(:,1) )
ax = gca;
ax.XAxis.FontSize = axFSize*1.25;
ax.XLabel.FontSize= labFSize*2;
ax.YAxis.FontSize = axFSize*1.25;
ax.YLabel.FontSize= labFSize*2;
ax.Children(1).Color = hex2rgb(Tcolor.sig3(2,:));
ax.Children(2).FaceColor = hex2rgb(Tcolor.sig3(2,:));
title('R2 of the MISO models across iterations-single run','FontSize',tFSize*1.5);
ax.XTickLabel = {'h_t','d_t','dis_{42d-qtD:0.60}^{efrf,LC}','dis_{5mo-qtD:0.30}^{efsr,LC}','dis_{5mo-qtD:0.90}^{efsr,LC}'};

draw_colorMap( IIS_res.X, IIS_res.R2 )
iis_r1_real = gcf;
iis_r1_real.Children(1).Children(2).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(2).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(2).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(2), 'Input ranking-multiple runs','FontSize',tFSize*1.5);

iis_r1_real.Children(1).Children(1).XAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).XLabel.FontSize= labFSize*2;
iis_r1_real.Children(1).Children(1).YAxis.FontSize = axFSize*2;
iis_r1_real.Children(1).Children(1).YLabel.FontSize= labFSize*2;
title(iis_r1_real.Children(1).Children(1), 'R2 final MISO model-multiple runs','FontSize',tFSize*1.5);


%% IOP pareto r4 (1 fig perf real e anom)
iop_r4_pareto_slice = figure('WindowState','fullscreen');
iop_r4_pareto_sliceTL = tiledlayout(1,3);

sols = [BOP, IOP_LakeComo14dmeanAnom, IOP_LakeComo42dqtD060, IOP_qAgg21dAnom] ;
solsName = {'BOP(d_t,h_t)', 'IOP(d_t,h_t,dis_{14d-anom}^{efrf,LC})', 'IOP(d_t,h_t,dis_{42d-qtD:0.60}^{efrf,LC})', 'IOP(d_t,h_t,dis_{21d-anom}^{perf})'};
solsCol = [Tcolor.gray;Tcolor.sig1(2,:);Tcolor.sig3(2,:);Tcolor.sig2(2,:);];
solLS = ["-", "-", "-","-"];

for idx = 1:3
    ax = nexttile;
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        plot( p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 12, 'Color', Tcolor.black);
    else
        % since I don't have for the other levels
        plot( p2d(:,1), p2d(:,2), 'LineStyle', ':', 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 12, 'Color', Tcolor.black );
    end
    
    hold on
    for jdx = 1:length(sols)
        set = sols(jdx).reference;
        ref = [ round(set(:,1), 1), set(:,2), set(:,3) ];
        
        p2d = ref( ref(:,1) >= steps(idx) & ref(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        plot( p2d(:,1), p2d(:,2), 'LineStyle', solLS(jdx), 'Marker', 'o', 'MarkerSize', 14, 'LineWidth', 4, 'Color', solsCol(jdx,:) );
    end
    if idx == 2
        % legend
        iop_r4_pareto_sliceLeg = legend;
    end
    
    ax.XAxis.FontSize = axFSize;
    ax.YAxis.FontSize = axFSize;
    xlim(ax, [1000, 2000] )
    ylim(ax, [0, 50] )
    title(ax, strcat("Flood ",names(idx)," [d/y]"), 'FontSize', tFSize );
    grid on
    xlabel( 'Deficit [(m^3/s)^{eq}]', 'FontSize', labFSize);
end
iop_r4_pareto_sliceTL.Padding = 'compact';
iop_r4_pareto_sliceTL.TileSpacing = 'compact';
ylabel(iop_r4_pareto_sliceTL, 'Low level [day/year]', 'FontSize', labFSize);


iop_r4_pareto_sliceLeg.String = [{'POP'}, solsName];
iop_r4_pareto_sliceLeg.FontSize = legFSize;
iop_r4_pareto_sliceLeg.Location = 'southoutside';
iop_r4_pareto_sliceLeg.Orientation = 'horizontal';

%% metriche (1 fig perf real e real anom)
[iop_r4_metrics, iop_r4_metricsLeg] = draw_my_metrics( sols );
for idx = [1,3,4]
    iop_r4_metrics.Children(1).Children(idx).ColorOrder = hex2rgb([solsCol;Tcolor.black]);
    iop_r4_metrics.Children(1).Children(idx).XAxis.FontSize = axFSize;
    iop_r4_metrics.Children(1).Children(idx).YAxis.FontSize = axFSize;
    iop_r4_metrics.Children(1).Children(idx).Title.FontSize = tFSize;
end
iop_r4_metricsLeg.String = [solsName, {'POP'}];
iop_r4_metricsLeg.Orientation = 'horizontal';
iop_r4_metricsLeg.FontSize = legFSize;

%% ciclostationary usa file
draw_ciclostoragetraj;
cicLeg.FontSize = legFSize-2;
cicLeg.Location = 'southoutside';
cicLeg.Orientation = 'horizontal';

ciclev.XAxis.FontSize = axFSize;
ciclev.YAxis.FontSize = axFSize;
cicrel.XAxis.FontSize = axFSize;
cicrel.YAxis.FontSize = axFSize;

title(ciclev, 'Ciclostationary trajectory of level and release', 'FontSize',tFSize ) 
