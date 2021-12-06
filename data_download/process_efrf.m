function process_efrf( e, c )

pos = {'/Fuentes/', '/Mandello/', '/LakeComo/', '/Olginate/' };
ro = [356, 354, 355, 356];
co = [589, 594, 595, 596];

sch1 = ncinfo( strcat(e, '.nc' ) );

% remove useless things
% remove the 2 first dimensions
sch1.Dimensions(1:2) = [];
% remove y and x and ens num
sch1.Variables(1:3) = [];
% % remove surface
% sch1.Variables(4) = []
% % remove valid_time
% sch1.Variables(4) = []
% %remove lat, lon, land, up area
% sch1.Variables(end-4:end) = []
% save only data and valid time
sch1.Variables(2) = sch1.Variables(5);
sch1.Variables(3:end) = [];


% load
de = ncread( strcat(e, '.nc' ), 'dis06' );
dc = ncread( strcat(c, '.nc' ), 'dis06' );


for idx = 1:4 
    % extract 1 2D-array for point.
    de_ = squeeze( de( ro(idx), co(idx), :, : ) );
    dc_ = squeeze( dc( ro(idx), co(idx), : ) );
    
    
    % move from dis06 to dis24 and remove lead 0
    d = cat(2, dc_, de_);
    d = d(2:end, :);
    d = reshape( d, 4, 46, 11 );
    d = squeeze( mean( d, 1 ) );
    
    % change dimensions and co
    % dim step
    sch1.Dimensions(2).Length = 46;
    sch1.Variables(2).Dimensions(1:2) = [];
    sch1.Variables(2).Dimensions(1) = sch1.Dimensions(2);
    
    
    % ens num
    sch1.Dimensions(1).Length = 11;
    sch1.Variables(2).Dimensions(2) = sch1.Dimensions(1);
    
    % size
    sch1.Variables(2).Size = size(d);
    
    % name change
    sch1.Variables(2).Name = 'dis24';
    
    % writeschema
    
    n = strcat( cd, pos{idx} , e(5:end-2), '.nc');
    ncwriteschema( n , sch1 );
    
    % write data: di24 and time
    ncwrite( n, 'dis24', d );
    ncwrite( n, 'time', ncread(  strcat(e, '.nc' ), 'time' ) );

end

% delete the files
delete( strcat(e, '.nc' ) );
delete( strcat(c, '.nc' ) );
end
