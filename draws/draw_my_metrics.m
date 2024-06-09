function draw_my_metrics( sols, ax )
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
    
    if nargin == 1
        figure;
        t = tiledlayout( 1, 3) ;
        ax(1)  = nexttile;
        ax(2) = nexttile;
        ax(3) = nexttile;
    end
    
    hold(ax, 'on');
    for idx = 1:(nS+1)
        bar(ax(1), idx, Hv(idx) );
    end
    xticklabels(ax(1), {''} );
    title( ax(1), 'HV' );
    text( ax(1), 1:nS, Hv(1:nS), num2str(Hv(1:nS), '%.2f'), 'VerticalAlignment','bottom','HorizontalAlignment','center');
    % arrow to insert b.Position
    
    for idx = 1:(nS+1)
        bar(ax(2), idx, dmin(idx) );
    end
    xticklabels(ax(2), {''} );
    set(ax(2), 'YDir','reverse')
    title(ax(2), 'Dmin' );
    text( ax(2), 1:nS, dmin(1:nS), num2str(dmin(1:nS)', '%.2f'), 'VerticalAlignment','top','HorizontalAlignment','center');
    
    for idx = 1:(nS+1)
        bar(ax(3), idx, davg(idx) );
    end
    xticklabels(ax(3), {''} );
    set(ax(3), 'YDir','reverse')
    title(ax(3), 'Davg' );
    text( ax(3), 1:nS, davg(1:nS), num2str(davg(1:nS)', '%.2f'), 'VerticalAlignment','top','HorizontalAlignment','center');
end

