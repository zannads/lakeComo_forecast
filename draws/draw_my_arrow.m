function draw_my_arrow(axis,direction)
    %DRAWMYARROW Summary of this function goes here
    %   Detailed explanation goes here
    pos = get(axis, 'Position');
    if direction >=0
        %upward 
        annotation( 'textarrow', [pos(1),pos(1)]-0.01, [pos(2)+0.02, pos(2)+0.12] );
    else
        annotation( 'textarrow', [pos(1),pos(1)]-0.01, [pos(2)+0.12, pos(2)+0.02] );
    end
end

