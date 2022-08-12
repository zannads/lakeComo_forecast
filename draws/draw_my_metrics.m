function [outputArg1, outputArg2] = draw_my_metrics( sols )
    %DRAW_MY_METRICS Summary of this function goes here
    %   Detailed explanation goes here
   
    nS = length( sols );
    
    % preallocate and add at the end  POP
    Hv   = ones(  nS+1, 1);
    dmin = zeros( 1, nS+1 );
    davg = zeros( 1, nS+1 );
    
    for idx = 1:nS
        Hv(idx)   = sols(idx).metrics.Hypervolume;
        dmin(idx) = sols(idx).metrics.Dmin;
        davg(idx) = sols(idx).metrics.Davg;
    end
    
    outputArg1 = figure;
    t = tiledlayout( 1, 3) ;
    b = nexttile;
    bar( 1, Hv );
    hold on;
    for idx = 1:nS
        plot([-0.05*(nS+3)+1,1+0.05*(nS+3)],[Hv(idx),Hv(idx)], 'LineStyle', '--', 'LineWidth', 2);  % I add 1 for POP, plus 2 for the sides
    end
    xticklabels(b, {''} );
    title( b, 'HV' );
    % arrow to insert b.Position
    
    b = nexttile;
    bar( 1, dmin );
    hold on;
    for idx = 1:nS
        plot([-0.05*(nS+3)+1,1+0.05*(nS+3)],[dmin(idx),dmin(idx)], 'LineStyle', '--', 'LineWidth', 2);  % I add 1 for POP, plus 2 for the sides
    end
    xticklabels(b, {''} );
    set(b, 'YDir','reverse')
    title( b, 'Dmin' );
    outputArg2 = legend(b);
    outputArg2.Location = 'southoutside';
    %outputArg2.Orientation = 'horizontal';
    
    b = nexttile;
    bar( 1, davg );
    hold on;
    for idx = 1:nS
        plot([-0.05*(nS+3)+1,1+0.05*(nS+3)],[davg(idx),davg(idx)], 'LineStyle', '--', 'LineWidth', 2);  % I add 1 for POP, plus 2 for the sides
    end
    xticklabels(b, {''} );
    set(b, 'YDir','reverse')
    title( b, 'Davg' );
    
end

