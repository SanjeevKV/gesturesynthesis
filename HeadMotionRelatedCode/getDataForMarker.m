function [data,ind]=getDataForMarker(markerData, markerName)
%markerName
%size(markerData{2})
for i=1:2:length(markerData)
    markerName
    markerData{i}
    if(strcmp(lower(markerData{i}), lower(markerName)) == 1)
        markerName
        data=markerData{i+1};ind=i+1;break;
    end
end

end