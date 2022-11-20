aT = std_aggregation(efrfForecast(1).valid_agg_time( std_aggregation ));

%#ok<*UNRCH>
redo_mean           = false;
redo_var            = false;
redo_maxmin         = false;
redo_qtA            = false;
redo_qtM            = false;
redo_meanAnomaly    = false;
redo_qtD            = false;
redo_pI             = false;
redo_pIAnomaly      = false;
redo_det            = false;
redo_allefrf        = false;
redo_allBS          = false;
redo_allpI          = false;
redo_allNorm        = true;

qt2gen = 0.1:0.1:0.9;
%%
for idx = 1:4 % location iter
    for aT_ = 1:length(aT) %agg time iter
        
        tsShort = efrfForecast(idx).getTimeSeries( aT(aT_), 0, true);
        add_day = [mean(tsShort{tsShort.Time.Day==1 & tsShort.Time.Month==1 , :},1);
            mean(tsShort{tsShort.Time.Day==2 & tsShort.Time.Month==1 , :},1)];
        
        ts = [array2timetable(add_day, 'RowTimes', datetime(1999,1,1):datetime(1999,1,2), 'VariableNames', tsShort.Properties.VariableNames);
            tsShort];
        
        if redo_mean
            %
            sign2w = mean( ts.Variables, 2);
            
            %mkdir
            if ~exist('candidate_variables/Mean', 'dir')
                mkdir('candidate_variables/Mean')
            end
            fid = fopen( fullfile( 'candidate_variables/Mean', strcat( efrfForecast(idx).name, '_efrf_',...
                string(aT(aT_)), ...
                '_mean', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
        end
        
        if redo_var
            %
            sign2w = var( ts.Variables,0, 2);% 0 is for the correct normalization (N-1), 2 is the dimension on which operate
            
            %mkdir
            if ~exist('candidate_variables/Variances', 'dir')
                mkdir('candidate_variables/Variances')
            end
            fid = fopen( fullfile( 'candidate_variables/Variances', strcat( efrfForecast(idx).name, '_efrf_',...
                string(aT(aT_)), ...
                '_var', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
        end
        
        if redo_maxmin
            %
            sign2w = max( ts.Variables, [], 2);
            
            %mkdir
            if ~exist('candidate_variables/MaxMin', 'dir')
                mkdir('candidate_variables/MaxMin')
            end
            fid = fopen( fullfile( 'candidate_variables/MaxMin', strcat( efrfForecast(idx).name, '_efrf_',...
                string(aT(aT_)), ...
                '_max', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
            
            sign2w = min( ts.Variables, [], 2);
            
            fid = fopen( fullfile( 'candidate_variables/MaxMin', strcat( efrfForecast(idx).name, '_efrf_',...
                string(aT(aT_)), ...
                '_min', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
        end
        
        if redo_qtA
            
            %mkdir
            if ~exist('candidate_variables/qtA', 'dir')
                mkdir('candidate_variables/qtA')
            end
            
            for qt = qt2gen
                bnd = brier_score.extract_bounds( tsShort, qt,  'annual');
                sign2w = brier_score.parse( ts, bnd, 'annual', 'linear');
                
                
                fid = fopen( fullfile( 'candidate_variables/qtA', strcat( efrfForecast(idx).name, '_efrf_',...
                    string(aT(aT_)), ...
                    '_qtA', cell2mat(split(sprintf('%0.2f',qt), '.', 2)), ...
                    '.txt') ), 'w');
                fprintf( fid, '%d\n', sign2w(:,2) ); % I save above
                fclose(fid);
            end
            clear bnd
        end
        
        if redo_qtM
            
            %mkdir
            if ~exist('candidate_variables/qtM', 'dir')
                mkdir('candidate_variables/qtM')
            end
            
            for qt = qt2gen
                bnd = brier_score.extract_bounds( tsShort, qt,  'monthly');
                sign2w = brier_score.parse( ts, bnd, 'monthly', 'linear');
                
                
                fid = fopen( fullfile( 'candidate_variables/qtM', strcat( efrfForecast(idx).name, '_efrf_',...
                    string(aT(aT_)), ...
                    '_qtM', cell2mat(split(sprintf('%0.2f',qt), '.', 2)), ...
                    '.txt') ), 'w');
                fprintf( fid, '%d\n', sign2w(:,2) ); % I save above
                fclose(fid);
            end
            clear bnd
        end
        
        if redo_meanAnomaly
            %extract ciclo
            tsShortMean = array2timetable( mean( tsShort.Variables, 2), 'RowTimes', tsShort.Time );
            
            csShort = ciclostationary( tsShortMean ); %get one realization(365 d) of ciclostationary mean of release
            %get ciclo per time
            cs = cicloseriesGenerator( csShort, ts.Time );
            
            sign2w = mean( ts.Variables, 2)-cs.dis24;
            
            %mkdir
            if ~exist('candidate_variables/Mean', 'dir')
                mkdir('candidate_variables/Mean')
            end
            fid = fopen( fullfile( 'candidate_variables/Mean', strcat( efrfForecast(idx).name, '_efrf_',...
                string(aT(aT_)), ...
                '_meanAnom', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
            clear cs tsShortMean csShort
        end
        
        if redo_qtD
            
            %mkdir
            if ~exist('candidate_variables/qtD', 'dir')
                mkdir('candidate_variables/qtD')
            end
            
            for qt = qt2gen
                bnd = brier_score.extract_bounds( tsShort, qt,  'daily');
                sign2w = brier_score.parse( ts, bnd, 'daily', 'linear');
                
                
                fid = fopen( fullfile( 'candidate_variables/qtD', strcat( efrfForecast(idx).name, '_efrf_',...
                    string(aT(aT_)), ...
                    '_qtD', cell2mat(split(sprintf('%0.2f',qt), '.', 2)), ...
                    '.txt') ), 'w');
                fprintf( fid, '%d\n', sign2w(:,2) ); % I save above
                fclose(fid);
            end
            clear bnd
        end
    end
end

%%
aT = std_aggregation(efsrForecast(1).valid_agg_time( std_aggregation ));

for idx = 1:4 % location iter
    for aT_ = 1:length(aT) %agg time iter
        
        ts = efsrForecast(idx).getTimeSeries( aT(aT_), 0, true);
        
        if redo_mean
            %
            sign2w = mean( ts.Variables, 2);
            
            %mkdir
            if ~exist('candidate_variables/Mean', 'dir')
                mkdir('candidate_variables/Mean')
            end
            fid = fopen( fullfile( 'candidate_variables/Mean', strcat( efsrForecast(idx).name, '_efsr_',...
                string(aT(aT_)), ...
                '_mean', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
        end
        
        if redo_var
            %
            sign2w = var( ts.Variables,0, 2);% 0 is for the correct normalization (N-1), 2 is the dimension on which operate
            
            %mkdir
            if ~exist('candidate_variables/Variances', 'dir')
                mkdir('candidate_variables/Variances')
            end
            fid = fopen( fullfile( 'candidate_variables/Variances', strcat( efsrForecast(idx).name, '_efsr_',...
                string(aT(aT_)), ...
                '_var', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
        end
        
        if redo_maxmin
            %
            sign2w = max( ts.Variables, [], 2);
            
            %mkdir
            if ~exist('candidate_variables/MaxMin', 'dir')
                mkdir('candidate_variables/MaxMin')
            end
            fid = fopen( fullfile( 'candidate_variables/MaxMin', strcat( efsrForecast(idx).name, '_efsr_',...
                string(aT(aT_)), ...
                '_max', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
            
            sign2w = min( ts.Variables, [], 2);
            
            fid = fopen( fullfile( 'candidate_variables/MaxMin', strcat( efsrForecast(idx).name, '_efsr_',...
                string(aT(aT_)), ...
                '_min', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
        end
        
        if redo_qtA
            
            %mkdir
            if ~exist('candidate_variables/qtA', 'dir')
                mkdir('candidate_variables/qtA')
            end
            
            for qt = qt2gen
                bnd = brier_score.extract_bounds( ts, qt,  'annual');
                sign2w = brier_score.parse( ts, bnd, 'annual', 'linear');
                
                
                fid = fopen( fullfile( 'candidate_variables/qtA', strcat( efsrForecast(idx).name, '_efsr_',...
                    string(aT(aT_)), ...
                    '_qtA', cell2mat(split(sprintf('%0.2f',qt), '.', 2)), ...
                    '.txt') ), 'w');
                fprintf( fid, '%d\n', sign2w(:,2) ); % I save above
                fclose(fid);
            end
            clear bnd
        end
        
        if redo_qtM
            
            %mkdir
            if ~exist('candidate_variables/qtM', 'dir')
                mkdir('candidate_variables/qtM')
            end
            
            for qt = qt2gen
                bnd = brier_score.extract_bounds( ts, qt,  'monthly');
                sign2w = brier_score.parse( ts, bnd, 'monthly', 'linear');
                
                
                fid = fopen( fullfile( 'candidate_variables/qtM', strcat( efsrForecast(idx).name, '_efsr_',...
                    string(aT(aT_)), ...
                    '_qtM', cell2mat(split(sprintf('%0.2f',qt), '.', 2)), ...
                    '.txt') ), 'w');
                fprintf( fid, '%d\n', sign2w(:,2) ); % I save above
                fclose(fid);
            end
            clear bnd
        end
        
        if redo_meanAnomaly
            %extract ciclo
            tsMean = array2timetable( mean( ts.Variables, 2), 'RowTimes', ts.Time );
            
            csShort = ciclostationary( tsMean ); %get one realization(365 d) of ciclostationary mean of release
            %get ciclo per time
            cs = cicloseriesGenerator( csShort, ts.Time );
            
            sign2w = mean( ts.Variables, 2)-cs.dis24;
            
            %mkdir
            if ~exist('candidate_variables/Mean', 'dir')
                mkdir('candidate_variables/Mean')
            end
            fid = fopen( fullfile( 'candidate_variables/Mean', strcat( efsrForecast(idx).name, '_efsr_',...
                string(aT(aT_)), ...
                '_meanAnom', ...
                '.txt') ), 'w');
            fprintf( fid, '%d\n', sign2w );
            fclose(fid);
            clear cs tsMean csShort
        end
        
        if redo_qtD
            
            %mkdir
            if ~exist('candidate_variables/qtD', 'dir')
                mkdir('candidate_variables/qtD')
            end
            
            for qt = qt2gen
                bnd = brier_score.extract_bounds( tsShort, qt,  'daily');
                sign2w = brier_score.parse( ts, bnd, 'daily', 'linear');
                
                
                fid = fopen( fullfile( 'candidate_variables/qtD', strcat( efsrForecast(idx).name, '_efsr_',...
                    string(aT(aT_)), ...
                    '_qtD', cell2mat(split(sprintf('%0.2f',qt), '.', 2)), ...
                    '.txt') ), 'w');
                fprintf( fid, '%d\n', sign2w(:,2) ); % I save above
                fclose(fid);
            end
            clear bnd
        end
    end
end

%% pI
aT = std_aggregation;
if redo_pI
    %mkdir
    if ~exist('candidate_variables/perfect_inflows', 'dir')
        mkdir('candidate_variables/perfect_inflows')
    end
    
    for aT_ = 1:length(aT)
        fid = fopen( fullfile( 'candidate_variables/perfect_inflows', strcat( 'qAgg_',...
            string(aT(aT_)), ...
            '.txt') ), 'w');
        fprintf( fid, '%d\n', qAgg{:,aT_} ); % I save above
        fclose(fid);
    end
end

if redo_pIAnomaly
    if ~exist('candidate_variables/perfect_inflows', 'dir')
        mkdir('candidate_variables/perfect_inflows')
    end
    
    for aT_ = 1:length(aT)
        mm = cicloForecast.getTimeSeries( aT(aT_), 0 );
        
        fid = fopen( fullfile( 'candidate_variables/perfect_inflows', strcat( 'qAgg_',...
            string(aT(aT_)), ...
            '_anom', ...
            '.txt') ), 'w');
        fprintf( fid, '%d\n', (qAgg{:,aT_}-mm{:,1}) ); % I save above
        fclose(fid);
    end
end

%%
if redo_det
    aT = caldays(1:3);
    if ~exist('candidate_variables/progea', 'dir')
        mkdir('candidate_variables/progea')
    end
    
    for aT_ = 1:length(aT)
        mm = SynPROGEAForecast.getTimeSeries( aT(aT_), 0 );
        
        fid = fopen( fullfile( 'candidate_variables/progea', strcat( 'progea_',...
            string(aT(aT_)), ...
            '.txt') ), 'w');
        fprintf( fid, '%d\n', mm{:,19} ); % I save above
        fclose(fid);
    end
end
%%
if redo_allefrf
    sign2w = zeros(7305,42);
    fid = fopen( "LakeComo_efrf_all_anom.txt", 'w');
    for idx = 3 % location iter
        for aT_ = 1:42 %agg time iter
            ts = efrfForecast(idx).getTimeSeries( aT_, 0, true);
            ts = array2timetable( mean( ts.Variables, 2), 'RowTimes', ts.Time );
            
            %get one realization(365 d) of ciclostationary mean of release
            csShort = ciclostationary( ts );
            %get ciclo per time
            cs = cicloseriesGenerator( csShort, ts.Time );
            
            %add_day = [mean(tsShort{tsShort.Time.Day==1 & tsShort.Time.Month==1 , :},1);
            % mean(tsShort{tsShort.Time.Day==2 & tsShort.Time.Month==1 , :},1)];
            
            %ts = [array2timetable(add_day, 'RowTimes', datetime(1999,1,1):datetime(1999,1,2), 'VariableNames', tsShort.Properties.VariableNames);
            %   tsShort];
            %extract ciclo
            %tsMean = array2timetable( mean( ts.Variables, 2), 'RowTimes', ts.Time );
            
            sign2w(3:end, aT_) = ts.Variables-cs.(1);
        end
    end
    fprintf( fid, '%d\n', sign2w(:) ); % I save above
    fclose(fid);
end

%%
if redo_allBS
    PROGForecast = forecast( SynPROGEAForecast.time, SynPROGEAForecast.data(:,:,19) );
    sign2w = zeros(7305,183);
    fid = fopen( "candidate_variables/LakeComo_BestSkill_all_anom.txt", 'w' );
    idx = 3; % location iter
    for aT_ = 1:183 %agg time iter
        
        if aT_ < 4
            %PROGEA
            ts = PROGForecast.getTimeSeries( aT_, 0, true );
            ts = ts(1:7305,:);
        elseif aT_ < 43
            % efrf
            ts = efrfForecast(idx).getTimeSeries( aT_, 0, true);
        else
            % efsr
            ts = efsrForecast(idx).getTimeSeries( aT_, 0, true);
            ts = ts(1:7305,:);
        end
        
        ts = array2timetable( mean( ts.Variables, 2), 'RowTimes', ts.Time );
        
        %get one realization(365 d) of ciclostationary mean of release
        csShort = ciclostationary( ts );
        %get ciclo per time
        cs = cicloseriesGenerator( csShort, ts.Time );
        
        if aT_ >=4 & aT_ <= 42
            sign2w(3:end, aT_) = ts.Variables-cs.(1);
        else
            sign2w(:, aT_) = ts.Variables-cs.(1);
        end
    end
    
    fprintf( fid, '%d\n', sign2w(:) ); % I save above
    fclose(fid);
end

%%
if redo_allpI
    sign2w = zeros(7305,183);
    fid = fopen( "candidate_variables/pI_all_anom.txt", 'w' );
    for aT_ = 1:183 %agg time iter
        
        ts = aggregate_historical( qAgg.Time, qAgg.agg_1d, aT_);
        ts = array2timetable( ts(1:7305,:), 'RowTimes', qAgg.Time(1:7305) );
        
        %get one realization(365 d) of ciclostationary mean of release
        csShort = ciclostationary( ts );
        %get ciclo per time
        cs = cicloseriesGenerator( csShort, ts.Time );
        
        sign2w(:, aT_) = ts.Variables-cs.(1);
        
    end
    
    fprintf( fid, '%d\n', sign2w(:) ); % I save above
    fclose(fid);
end

%%
if redo_allNorm
    PROGForecast = forecast( SynPROGEAForecast.time, SynPROGEAForecast.data(:,:,19) );
    sign2w = zeros(7305,3);
    fid = fopen( "candidate_variables/LakeComo_PROGEA_all_Norm.txt", 'w' );
    for aT_ = 1:3 %agg time iter
        %PROGEA
        ts = PROGForecast.getTimeSeries( aT_, 0, true );
        ts = ts(1:7305,:);
        sign2w(:, aT_) = ts.Variables;
    end
    ms2w = min( sign2w, [], 1);
    Ms2w = max( sign2w, [], 1);
    sign2w = (sign2w-ms2w)./(Ms2w-ms2w);
    
    fprintf( fid, '%d\n', sign2w(:) ); % I save above
    fclose(fid);
    
    sign2w = zeros(7305,42);
    fid = fopen( "candidate_variables/LakeComo_efrf_all_Norm.txt", 'w' );
    idx = 3; % location iter
    for aT_ = 1:42 %agg time iter
        %efrf
        ts = efrfForecast(idx).getTimeSeries( aT_, 0, true);
        %get one realization(365 d) of ciclostationary mean of release
        csShort = ciclostationary( ts );
        sign2w(1, aT_) = csShort{csShort.Time.Month==1 & csShort.Time.Day==1 , 1};
        sign2w(2, aT_) = csShort{csShort.Time.Month==1 & csShort.Time.Day==2 , 1};
        % efrf starts from 3 jan 1999
        sign2w(3:end, aT_) = mean(ts.Variables,2);
    end
    ms2w = min( sign2w, [], 1);
    Ms2w = max( sign2w, [], 1);
    sign2w = (sign2w-ms2w)./(Ms2w-ms2w);
    
    fprintf( fid, '%d\n', sign2w(:) ); % I save above
    fclose(fid);
    
    sign2w = zeros(7305,183);
    fid = fopen( "candidate_variables/LakeComo_efsr_all_Norm.txt", 'w' );
%    idx = 3; % location iter
    for aT_ = 1:183 %agg time iter
        %efrf
        ts = efsrForecast(idx).getTimeSeries( aT_, 0, true);
        sign2w(:, aT_) = mean(ts{1:7305,:},2);
    end
    ms2w = min( sign2w, [], 1);
    Ms2w = max( sign2w, [], 1);
    sign2w = (sign2w-ms2w)./(Ms2w-ms2w);
    
    fprintf( fid, '%d\n', sign2w(:) ); % I save above
    fclose(fid);
end

%%
clear add_day aT aT_ fid idx qt qt2gen redo_maxmin redo_mean redo_meanAnomaly redo_qtA mm
clear redo_qtA redo_qtM redo_var sign2w ts tsShort ans tsMean redo_qtD redo_pI redo_pIAnomaly