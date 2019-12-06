function markerData=getIEMOCAPMarkerData(filePath, markerName)

fid = fopen(filePath, 'r');
header = fgetl(fid);
fgetl(fid);
buffer = fread(fid, Inf);
fclose(fid);
fid = fopen('data.txt', 'w');
fwrite(fid, buffer);
fclose(fid);
clear buffer fid;
load data.txt;
header = strsplit(header);
markerId = find(strcmp(header, markerName))-2;
dataCols = markerId*3:markerId*3+2;
markerData=data(:,dataCols);

end


