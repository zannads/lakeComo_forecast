setup_draws;
POP.reference = cat(1, ddpsol( cat(1,ddpsol.flag_ref)>0 ).J );
%% POP pareto e parallel plot
sel_w = [86, 127, 15];
gr = ones(length(POP.reference), 1);    % group data for parallel plot
colorOrd = [Tcolor.sig1(3,:); Tcolor.sig2(3,:); Tcolor.sig3(3,:)];
for idx = 1:3
    xx = ddpsol(sel_w(idx)).flag_ref;
    gr(xx) = gr(xx)+idx;
end

POP_pareto_parallel = figure('WindowState','fullscreen');
POP_pareto_parallelTL = tiledlayout(1,2);
ax(1) = nexttile;
l(1) = plot3( POP.reference(gr==1,1), POP.reference(gr==1,2), POP.reference(gr==1,3), '.', 'MarkerSize', 24, 'Color', Tcolor.black );
ax(1).XAxis.FontSize = axFSize;
ax(1).YAxis.FontSize = axFSize;
ax(1).ZAxis.FontSize = axFSize;
xlabel( 'Flood Days [day/year]', 'FontSize', labFSize );
ylabel( 'Deficit [m^3/s^{eq}]',  'FontSize', labFSize );
zlabel( 'Static low [day/year]', 'FontSize', labFSize);
grid on;
hold on;
for idx = 1:3
    l(1+idx) = plot3( POP.reference(gr==(idx+1),1), POP.reference(gr==(idx+1),2), POP.reference(gr==(idx+1),3), '.', 'MarkerSize', 30, 'Color', colorOrd(idx,:));
end

ax(2) = nexttile;
p = parallelplot( POP.reference, 'GroupData', gr);
p.CoordinateTickLabels = ["Flood Days [d/y]", "Deficit [m^3/s^{eq}]", "Static low [d/y]" ];
p.FontSize = axFSize;
p.Jitter = 0;
p.LineWidth = [4,2,4,4];
p.Color = hex2rgb( [Tcolor.sig3(3,:);Tcolor.black;Tcolor.sig1(3,:); Tcolor.sig2(3,:)] );
title(POP_pareto_parallelTL, "3d - Parallel Pareto front POP", 'FontSize', tFSize );
legend( 'off' );

POP_pareto_parallelTL.Padding = 'compact';
POP_pareto_parallelTL.TileSpacing = 'compact';

POP_pareto_parallelLeg = legend( l, {'POP', 'sol86', 'sol127', 'sol15'} );
POP_pareto_parallelLeg.FontSize = legFSize;
POP_pareto_parallelLeg.Location = "northeastoutside";

clear ax l POP_pareto_parallel POP_pareto_parallelLeg
%% BOP pareto e parallel
POP_BOP_pareto_parallel = figure('WindowState','fullscreen');
POP_BOP_pareto_parallelTL = tiledlayout(1,2);
ax(1) = nexttile;
l(1) = plot3( POP.reference(:,1), POP.reference(:,2), POP.reference(:,3), '.', 'MarkerSize', 24, 'Color', Tcolor.black , 'LineWidth' , 2);
ax(1).XAxis.FontSize = axFSize;
ax(1).YAxis.FontSize = axFSize;
ax(1).ZAxis.FontSize = axFSize;
xlabel( 'Flood Days [day/year]', 'FontSize', labFSize );
ylabel( 'Deficit [m^3/s^{eq}]',  'FontSize', labFSize );
zlabel( 'Static low [day/year]', 'FontSize', labFSize);
grid on;
hold on;
l(2) = plot3( BOP.reference(:,1), BOP.reference(:,2), BOP.reference(:,3), '.', 'MarkerSize', 24, 'Color', Tcolor.gray );
gr = [ones(length(POP.reference), 1);
    2*ones(length(BOP.reference), 1)];  % group data for parallel plot

ax(2) = nexttile;
p = parallelplot( [POP.reference;BOP.reference], 'GroupData', gr);
p.CoordinateTickLabels = ["Flood Days [d/y]", "Deficit [m^3/s^{eq}]", "Static low [d/y]" ];
p.FontSize = axFSize;
p.Jitter = 0;
p.LineWidth = [2,2];
p.Color = hex2rgb( [Tcolor.black;Tcolor.gray] );

title(POP_BOP_pareto_parallelTL, "3d - Parallel Pareto front POP-BOP", 'FontSize', tFSize );

legend( 'off' );

POP_BOP_pareto_parallelTL.Padding = 'compact';
POP_BOP_pareto_parallelTL.TileSpacing = 'compact';

POP_BOP_pareto_parallelLeg = legend( l, {'POP', 'BOP(d_t,h_t)'} );
POP_BOP_pareto_parallelLeg.FontSize = legFSize;
POP_BOP_pareto_parallelLeg.Location = "northeastoutside";


% BOP e POP trajectory comparison

% BOP e POP metric

% le faccio nella prima IOP così riduco lo spazio e le commento da lì
%% reading IIS subsection
poOpt_thesisDraws_iis

%% first iteration start with cumulative R2 della IIS(1 fig perf e real)
IIS_res = load('/Users/denniszanutto/Documents/Data/ivs_solutions/sol86/ivs_m_sol86_n15.mat');

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
ax.XTickLabel = {'dis_{5d}^{efrf,LC}', 'd_t', 'h_t', 'dis_{4mo}^{efsr,LC}'};

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
IIS_res = load('/Users/denniszanutto/Documents/Data/ivs_solutions/sol86/ivs_pI_sol86_n15.mat');

[IIS_res.X, IIS_res.R2, IIS_res.R2re] = summarize_IIS_result(IIS_res.results_iis_n);
print_names(IIS_res.c_v, IIS_res.X)
draw_R2( IIS_res.R2(:,1) )
ax = gca;
ax.XAxis.FontSize = axFSize*2;
ax.XLabel.FontSize= labFSize*2;
ax.YAxis.FontSize = axFSize*2;
ax.YLabel.FontSize= labFSize*2;
ax.Children(1).Color = hex2rgb(Tcolor.sig2(2,:));
ax.Children(2).FaceColor = hex2rgb(Tcolor.sig2(2,:));
title('R2 of the MISO models across iterations-single run','FontSize',tFSize*1.5);
ax.XTickLabel = {'dis_{3d}^{perf}', 'h_t', 'dis_{4mo}^{perf}', 'd_t','dis_{21d}^{perf}'};

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
iop_r1_pareto_slice = figure('WindowState','fullscreen');
iop_r1_pareto_sliceTL = tiledlayout(1,3);

sols = ( [BOP, IOP_LakeComo5d, IOP_LakeComo5dmeanAnom, IOP_qAgg5d] );
solsName = {'BOP(d_t,h_t)', 'IOP(d_t,h_t,dis_{5d}^{efrf,LC})', 'IOP(d_t,h_t,dis_{5d-anom}^{efrf,LC})', 'IOP(d_t,h_t,dis_{5d}^{perf})'};
steps = [4.2, 5.5, 7, 100];
names = ["4.5-5.5", "5.5-7", ">7"];
solsCol = [Tcolor.gray;Tcolor.sig1(2,:);Tcolor.sig1(3,:);Tcolor.sig2(2,:);];
solLS = ["-", "-", "--","-"];

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
        iop_r1_pareto_sliceLeg = legend;
    end
    
    ax.XAxis.FontSize = axFSize;
    ax.YAxis.FontSize = axFSize;
    xlim(ax, [1000, 2000] )
    ylim(ax, [0, 50] )
    title(ax, strcat("Flood ",names(idx)," [d/y]"), 'FontSize', tFSize );
    grid on
    xlabel( 'Deficit [(m^3/s)^{eq}]', 'FontSize', labFSize);
end
iop_r1_pareto_sliceTL.Padding = 'compact';
iop_r1_pareto_sliceTL.TileSpacing = 'compact';

ylabel(iop_r1_pareto_sliceTL, 'Low level [day/year]', 'FontSize', labFSize);


iop_r1_pareto_sliceLeg.String = [{'POP'}, solsName];
iop_r1_pareto_sliceLeg.FontSize = legFSize;
iop_r1_pareto_sliceLeg.Location = 'southoutside';
iop_r1_pareto_sliceLeg.Orientation = 'horizontal';

%% metriche (1 fig perf real e real anom)
[iop_r1_metrics, iop_r1_metricsLeg] = draw_my_metrics( sols );

for idx = [1,3,4]
    iop_r1_metrics.Children(1).Children(idx).ColorOrder = hex2rgb([solsCol;Tcolor.black]);
    iop_r1_metrics.Children(1).Children(idx).XAxis.FontSize = axFSize;
    iop_r1_metrics.Children(1).Children(idx).YAxis.FontSize = axFSize;
    iop_r1_metrics.Children(1).Children(idx).Title.FontSize = tFSize;
end
iop_r1_metricsLeg.String = [solsName,{'POP'}];
iop_r1_metricsLeg.Orientation = 'horizontal';
iop_r1_metricsLeg.FontSize = legFSize;
% IIS tradeoff solutions mention but don't show


