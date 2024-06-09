function add_labels(ax, style, p2d, solStruct, Sett, solColor )
    if style==0
        return;
    end
    allp = solStruct.reference;

    xShift = -150;
    yShift = -1;

    at_ = [3;42;183];
    tag_ = ["PRO","EFRF","EFSR"];
    
    for kdx = 1:size(p2d,1)
        % 1) find the number
        ref_idx = find( allp(:,2) == p2d(kdx,1) & allp(:,3) == p2d(kdx,2) );
        % 2) extract the parameters, the AT is in  the last position
        pTheta = extract_params(solStruct, ref_idx );
        % 3) write the text where you have to
        if style==1  
            % automatic selection just take the last number, that is the at
            at = floor(pTheta(end))+1; % plus one to move from c++ to MATLAB
            txt = int2str(at);
        elseif style==2
            % select forecast and at 
            fc = floor(pTheta(end-1));
            at = floor( pTheta(end)*at_(fc+1))+1;% plus one to move from c++ to MATLAB
            txt = strcat(int2str(at), '^{', tag_(fc+1),'}');
        elseif style==3
            % select forecast and at twice
            fc = floor(pTheta(end-1));
            at = floor( pTheta(end)*at_(fc+1))+1;% plus one to move from c++ to MATLAB
            txt = strcat(int2str(at), '^{', tag_(fc+1),'}');
            fc = floor(pTheta(end-3));
            at = floor( pTheta(end-2)*at_(fc+1))+1;% plus one to move from c++ to MATLAB
            txt = strcat(int2str(at), '^{', tag_(fc+1),'},',txt);
                
            % since it always selects PRO 3d remove it and then remove the
            % comma
            txt=erase(txt, "3^{PRO}");
            txt=erase(txt, ",");

        elseif style==4
            % select forecast and at once, but the forecast indicates also
            % the quantile
            fc = fix(floor(pTheta(end-1))/5); %div 5 because I have 5 quantiles for each solution
            at = floor( pTheta(end)*at_(fc+1))+1;% plus one to move from c++ to MATLAB
            if fc==0 %PROGEA
                txt = strcat(int2str(at), '^{', tag_(fc+1),'}');
            else
                %
                qts = ["min", "0.25", "0.5", "0.75", "max"];
                qt = rem(floor(pTheta(end-1)), 5)+1;
                txt = strcat(int2str(at), '^{', tag_(fc+1),'}_{', qts(qt),'}');
            end
            
        else
            % same as style 4 but progea is not included
            fc = fix(floor(pTheta(end-1))/5)+1; %div 5 because I have 5 quantiles for each solution, +1 because I know it is not PROGEA so start from the second
            at = floor( pTheta(end)*at_(fc+1))+1;% plus one to move from c++ to MATLAB
            
            qts = ["min", "0.25", "0.5", "0.75", "max"];
            qt = rem(floor(pTheta(end-1)), 5)+1;
            txt = strcat(int2str(at), '^{', tag_(fc+1),'}_{', qts(qt),'}');
        
        end
        text(ax, p2d(kdx,1)+xShift, p2d(kdx,2)+yShift, txt, 'FontSize', Sett.axFSize, 'Color',  solColor );
    end
end