% parse_prob2det
%% EFRF
% I need the average and the first ensamble
% first ensamble
efrfForecastFE = efrfForecast{1};
% average ensamble
efrfForecastAE = efrfForecastFE; %preallocate like this since they have the same shape.

e_n = length( efrfForecast );   %ensamble number
d_n = size(efrfForecastAE, 1);  %days number
data = zeros( d_n, e_n );
 %one row for each day, one column for each ensamble. Repeat for each lead
 %day.
for idx = 1:size( efrfForecastAE, 2 )   % for each column/lead day
    for jdx = 1:e_n
        data(:, jdx) = efrfForecast{jdx}.(idx);
    end
    efrfForecastAE.(idx) = mean(data, 2); % mean along row, i.e. for each day
end
%% MISSING STATS

%% EFSR
% I need the average and the first ensamble
% first ensamble
efsrForecastFE = efsrForecast{1};
% average ensamble
efsrForecastAE = efsrForecastFE; %like this since they have the same shape.

e_n = length( efsrForecast );   %ensamble number
d_n = size(efsrForecastAE, 1);  %days number
data = zeros( d_n, e_n );
 %one row for each day, one column for each ensamble. Repeat for each lead
 %day.
for idx = 1:size( efsrForecastAE, 2 )   % for each column/lead day
    for jdx = 1:e_n
        data(:, jdx) = efsrForecast{jdx}.(idx);
    end
    efsrForecastAE.(idx) = mean(data, 2); % mean along row, i.e. for each day
end

efsrFAEdetStats = detStats;
% populate with zeros;
t_ = zeros(1, length(efsrFdetStats.agg_times) );
n = fieldnames(detStats);
for j = 1:length(n)
    efsrFAEdetStats.(n{j}) = t_;
end
clear t_ j n
efsrFFEdetStats = efsrFAEdetStats;
av_efsrFdetStats = efsrFAEdetStats;
cs_efsrFdetStats = efsrFAEdetStats;
con_efsrFdetStats = efsrFAEdetStats;

clear data idx jdx e_n d_n
