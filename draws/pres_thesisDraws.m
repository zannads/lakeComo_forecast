for_plot = figure('WindowState','fullscreen');
for_axis = gca;
clear l

l(1) = plot( datetime(1999,1,3,8,0,0):(datetime(1999,1,3,8,0,0)+45), qAgg{2:47,1}, 'LineWidth', 4, 'Color', Tcolor.black, 'LineStyle', '--' );
hold on;
grid on;

qq = squeeze(efrfForecast(3).data(1,:,:));
qq2 = SynPROGEAForecast.data(2,:,19); 
ls = plot( datetime(1999,1,4,0,0,0):(datetime(1999,1,4,0,0,0)+45), qq(:,2:end), 'LineWidth', 4, 'Color', Tcolor.sig3(3,:), 'LineStyle', '-' );
l(2) = ls(1); clear ls
%l(3) = plot( datetime(1999,1,4,0,0,0):(datetime(1999,1,4,0,0,0)+45), qq(:,1), 'LineWidth', 4, 'Color', Tcolor.sig2(2,:), 'LineStyle', '-' );
%l(4) = plot( datetime(1999,1,4,0,0,0):(datetime(1999,1,4,0,0,0)+45), mean(qq,2), 'LineWidth', 4, 'Color', Tcolor.sig3(2,:), 'LineStyle', '-' );
l(3) = plot( datetime(1999,1,4,8,0,0):(datetime(1999,1,4,8,0,0)+2), qq2, 'LineWidth', 6, 'Color', Tcolor.sig1(3,:), 'LineStyle', '-' );

xlabel( 'Time', 'FontSize', 32);
ylabel( 'dis_{24} [m^3/s]', 'FontSize', 36 );
for_axis.XAxis.FontSize = 26;
for_axis.YAxis.FontSize = 26;

for_leg = legend(l, {'Observed', 'EFAS MT', 'PROGEA'} );
for_leg.FontSize = 36;
for_leg.Location = 'northeast';


%%
iop_r2_pareto_slice = figure('WindowState','fullscreen');
iop_r2_pareto_sliceTL = tiledlayout(1,3);

sols = BOP;
solsName = {'BOP(d_t,h_t)'};
solsCol = Tcolor.gray;
solLS = "-";
steps = [4.2, 5.5, 7, 100];
names = ["4.5-5.5", "5.5-7", ">7"];

for idx = 1:3
    ax = nexttile;
    
    p2d = order2plot(POP.reference(:,2:3));
    if idx == 1
        plot( p2d(:,1), p2d(:,2), 'LineStyle', '-', 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 12,  'Color', Tcolor.black);
    else
        % since I don't have for the other levels
        %plot( p2d(:,1), p2d(:,2), 'LineStyle', ':', 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 12, 'Color', Tcolor.black);
    end
    
    hold on
    for jdx = 1:length(sols)
        set = sols(jdx).reference;
        ref = [ round(set(:,1), 1), set(:,2), set(:,3) ];
        
        p2d = ref( ref(:,1) >= steps(idx) & ref(:,1) < steps(idx+1), 2:3);
        p2d = order2plot(p2d);
        
        plot( p2d(:,1), p2d(:,2), 'LineStyle', solLS(jdx), 'Marker', 'o', 'MarkerSize', 14, 'LineWidth', 4, 'Color', solsCol(jdx,:) );
    end
    if idx == 1
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
