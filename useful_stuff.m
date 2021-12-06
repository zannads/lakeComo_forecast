p1 = now;
fid = fopen('efrf_downloaded.txt');
tline = string.empty;
while ~feof(fid)
tline(end+1) = fgetl(fid); %#ok<SAGROW>
end
fclose(fid);
now-p1
%str2double(p2(end-2:end))-str2double(p1(end-2:end))
p1 = now;
a = dir('data_parser/');
length(a) > 3;
now-p2
%
p1 = now;
fid = fopen('efrf_downloaded.txt');
fseek( fid, 0, 'eof');
fl = ftell(fid);
fclose(fid);
now-p1

%%
%cd( 'Fuentes');
list_element = dir( '/Volumes/HD/EFAS_reforecast/RawData/*.nc' );

for idx = 1:length(list_element)
    n = list_element(idx).name;
    
    if length( n) == 22
        %do nothing
    elseif length( n) == 21
        %missing 0 in month;
        n = [n(1:9),'0',n(10:end)]
        movefile( list_element(idx).name, n);
    elseif length( n) == 14
        %missing 0 in month and day;
        n = [n(1:9),'0',n(10), '0', n(11:end)]
        movefile( list_element(idx).name, n);
    end
    
    
end

%% formula for space
x = 1000; y = 950; l = 185; e = 10;
((x+y+e+1+l+1+l)*8+(x*y*l*e+x*y+x*y+1+x*y)*4+x*y)+31799