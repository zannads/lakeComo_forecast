%efrf
clear 
max_download = 3;
current_download = 0;
fl_old = 0;

py_path = fullfile(cd, 'data_download', 'efas_simple_download.py');

cmd_base = strcat("python3  ", py_path, " ");

st_year = 2014;
end_year = 2014;
period = datetime(st_year, 1, 1):caldays(1):datetime(end_year,12,31);
%period = datetime(st_year, 7, 30):caldays(1):datetime(end_year,12,31);

% efrf is issued on mondays (2nd day of the week according to english
% calendar) and thursdays (fifth) of the 2019. every number of the day for
% all the previous years.
idx = 1;
while idx <= length(period)
    [y,m,d] = ymd(period(idx));
    
    if weekday( datetime(2019, m, d) ) == 2 | weekday( datetime(2019, m, d) ) == 5
        idx = idx+1;
    else
        period(idx) = [];
    end
end
                                % e downloaded started        %c download started
referenceD = table( repmat( "", length(period), 1), repmat( "", length(period), 1), ...
    false( length(period), 1), false( length(period), 1), ... %c and e download completed
    period', period', ... % datetime array for starting and ending time of download
    false( length(period), 1) );

e2down = 1;
edownloaded = 0;
merge_next = true;
while edownloaded < length(period)
    
    
    while current_download < max_download
        [y,m,d] = ymd(period(e2down));
        
        %perturbed ensamble reforecasts
        referenceD(e2down, 5) = {datetime()};
        fname = strcat( string(y), num2str(m,  '%0.2d'), num2str(d,  '%0.2d') );
        cmd_arg = strcat( string(y), " ", num2str(m,  '%0.2d'), " ", num2str(d,  '%0.2d') );
        %cmd_red1 = strcat( " >> e_", fname, ".txt" );
        %cmd_red2 = strcat( " >> c_", fname, ".txt" );
        
        cmmd = strcat(cmd_base, "e ", cmd_arg, " & ");
        system(cmmd);
        referenceD(e2down, 1) = {strcat( "raw_efrf_",fname, "_e" )};
        % control reforecast
        cmmd = strcat(cmd_base, "c ", cmd_arg, " & ");
        system(cmmd);
        referenceD(e2down, 2) = {strcat( "raw_efrf_", fname, "_c" )};
        
        current_download = current_download+1;
        
        e2down = e2down +1;
        
        pause('on');
    end
    
    referenceD( (~strcmpi(referenceD.(1), "") & ~referenceD.(3) & ~referenceD.(4)) & ...
        ~referenceD.(7) , : )
    %%
    while merge_next
        fid = fopen('efrf_downloaded.txt');
        fseek( fid, 0, 'eof');
        
        if ftell(fid) > fl_old
            fl_old = ftell(fid);
            fseek( fid, 0, 'bof');
        
            tline = string.empty;
            while ~feof(fid)
                tline(end+1) = fgetl(fid); %#ok<SAGROW>
            end
            
            for idx = 1:length(tline)
                referenceD.(3) = referenceD.(3) | strcmpi(tline(idx), referenceD.(1) );
                referenceD.(4) = referenceD.(4) | strcmpi(tline(idx), referenceD.(2) );
            end
            
            if any( referenceD.(3) & referenceD.(4) & ~referenceD.(7) )
                % mi prendo l'idx e li unisco
                dw_c_idx = find( referenceD.(3) & referenceD.(4) & ~referenceD.(7), 1, 'first');
                
                disp( strcat(table2array(referenceD(dw_c_idx, 1)), " & ", ...
                    table2array(referenceD(dw_c_idx, 2)),...
                    " download complete!") );
                
                %li unisco
                process_efrf( char(table2array(referenceD(dw_c_idx, 1))), ...
                    char(table2array(referenceD(dw_c_idx, 2)) ) );
                current_download = current_download-1;
                edownloaded = edownloaded+1;
                
                % li rimuovo
                referenceD(dw_c_idx, 7) = {true};
                referenceD(dw_c_idx, 6) = {datetime};
                
                % update the stats
                % average download time
                disp( 'average download time');
                dT = table2array(referenceD( referenceD.(7), 6)) - table2array(referenceD( referenceD.(7), 5));
                disp( (datetime-table2array(referenceD(1, 6)))/height(referenceD( referenceD.(7), 6)) );
                
                % prediction end time
                disp( 'Should end at');
                disp( (length(period)-edownloaded)*mean(dT) + datetime() );
                
                figure;
                % download time
                plot( 1:edownloaded, dT );
                
                %quit the merge process
                merge_next = false;
                pause('off');
            end
        end
        fclose( fid );
        
        %wait a little bit before reading agian
        pause(60);
    end
    %reactivate the merge process
    merge_next = true;
end

