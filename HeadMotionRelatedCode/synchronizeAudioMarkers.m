%
%Function to synchronize the delay between markerData and the audio data
%Input - Audio File Path, Marker File Path
%Output - Delay written to a txt file
%
function synchronizeAudioMarkers(audioFilePath, handDistanceFilePath, delayFilePath)
  
    % y - Amplitudes normalized to 1; Fs - Sampling rate
    [y ,Fs] = wavread(audioFilePath); 
    % Sampling rate of the optitrack device which we have is 120 Fs
    hFs = 120;
    
    load(handDistanceFilePath); %Loads the variable handDist
    d=(handDist-min(handDist))/range(handDist); %Normalizing the hand distances
    [amplitude, audioFirstPeak] = FindAudioFirstPeak(y(1:Fs*30), Fs); %Returns the first peak amplitude and it's absolute timeInstant
    [distance, handDistanceFirstPeak] = FindHandDistanceFirstPeak(d(1:hFs*30), hFs); %Returns the first minimum of handDistance and it's absolute timeInstant
    initDelay = audioFirstPeak - handDistanceFirstPeak; %Calculates the delay between audio and handDistance signals
    %Sending first 30 seconds of data - Audio and distances to the finddelay function
    delay=finddelay(y(1:Fs*30), Fs, d(1:hFs*30), hFs, initDelay);
    %$$$$$$$$$$$$$$$$$$$$$$ If you want to automate the entire
    %synchronization, comment the above line $$$$$$$$$$$$$$$$$$$$$$$
    fid=fopen(delayFilePath, 'w');
    fprintf(fid,'%.4f', delay);
    fclose(fid);
    
    clear;

end

%
%Input - Audio data - time Vs amplitude
%Output - First max(amplitude) - Amplitude within a certain threshold of the max amplitude. timeInstant of First Max
%
function [amplitude, timeInstant] = FindAudioFirstPeak(audioData, Fs)
  positive_audio = abs(audioData);
  max_amplitude = max(positive_audio);
  amplitude = 0;
  timeInstant = 0;
  for i=1:length(positive_audio)
    if positive_audio(i) >= max_amplitude * 0.4
      amplitude = positive_audio(i);
      timeInstant = i / Fs;
      break;
    end
  end
end

%
%Input - HandDistance data - time Vs distance b/w hands
%Output - First V's minimum - HandDistance within a certain threshold of the starting handDistance. timeInstant of First Minimum
%
function [distance, timeInstant] = FindHandDistanceFirstPeak(distanceData, hFs)
  max_amplitude = distanceData(hFs);
  distance = 0;
  timeInstant = 0;
  for i=hFs:length(distanceData)
    if distanceData(i) <= max_amplitude * 0.9
      while distanceData(i) > distanceData(i+1)
        i = i + 1;
      end
      distance = distanceData(i);
      timeInstant = i / hFs;
      break;   
    end
  end
end 