    %DRAW_MY_PARETO Summary of this function goes here
    %   Detailed explanation goes here
    til = tiledlayout(1,3);
    p2d = POP.reference(:,2:3);
    
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
            p2d = order2plot(p2d);
            
            plot( p2d(:,1), p2d(:,2), '-o', 'LineWidth', 2 );
        end
    end
    %%
    l.String = {'POP', 'BOP(h_t,d_t)', 'IOP(h_t,d_t,pF_{21d,anom})', 'IOP(h_t,d_t,LC^{efrf}_{14d,anom})'};
    
    

