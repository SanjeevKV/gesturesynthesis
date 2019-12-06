%
%Function to plot the markers (Fully connected graph)
%Input - Path of the file containing the marker data (Assumes data is in even locations in the markerData)
%Output - Dynamic plotting of the fully connected graph
%
function plot_motion(markerDataPath)
  
  load(markerDataPath);

  h = figure; 
  fps = 10;
  tic
  
  %Loop through the frames
  for i=1:fps:length(markerData{2})
    %Loop through all combinations of markers
    for j=2:2:8
      
      for k=j+2:2:8
        X=[markerData{j}(i,1),markerData{k}(i,1)];
        Y=[markerData{j}(i,2),markerData{k}(i,2)];
        Z=[markerData{j}(i,3),markerData{k}(i,3)];
        plot3(Z,X,Y);
        %axis([-10 20 80 100])
        hold on;
      end

    end
    
    for j=10:2:12
      
      for k=j+2:2:12
        X=[markerData{j}(i,1),markerData{k}(i,1)];
        Y=[markerData{j}(i,2),markerData{k}(i,2)];
        Z=[markerData{j}(i,3),markerData{k}(i,3)];
        plot3(Z,X,Y);
        %axis([-10 20 80 100])
        hold on;
      end

    end    
  
    title([num2str(i),'* time *',num2str(toc)]);
    pause(0.25);
    hold off;
    axis image
  end
  
end