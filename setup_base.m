% Folder when all the data and results are included.
global data_folder;
data_folder = '~/Documents/Data';

% steps used for cumulative inflow
std_aggregation = [caldays([1, 3, 5, 7:7:28])'; calmonths(1); caldays([42, 56])'; calmonths(2:7)'];