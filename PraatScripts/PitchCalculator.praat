#Praat Script used to calculate Pitch and Intensity for a given sound file
#Input : 1. Sound file location 2. File Suffix without extension 2. Output folder location
#Output : Pitch and Intensity values written to output location
#Eg usage from Mac : /Applications/Praat.app/Contents/MacOS/Praat --run /Users/sanjeev/Documents/Projects/ProjectAssistant/gesturesynthesis/PraatScripts/PitchCalculator.praat "/Users/sanjeev/Documents/Projects/
#				   ProjectAssistant/HeadMotionData/Telugu/Aravind/Audio/
#				   2016-06-08_18-11-50_Aravind_Story1En.wav" "2016-06-08_18-11-50_Aravind_Story1En" "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Telugu/Aravind/PitchIntensity/"

form Pitch Intensity Inputs
    sentence sound_file /Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Telugu/Aravind/Audio/2016-06-08_18-11-50_Aravind_Story1En.wav
    sentence output_file /Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Telugu/Aravind/PitchIntensity/2016-06-08_18-11-50_Aravind_Story1En.txt
endform

sound = do ("Read from file...", sound_file$)
do ("Rename...", "Sound")

dELIMITER$ = ","
mFCC_NUM_COEFFICIENTS = 12
hEADER$ = ""
pRecision = 10

hEADER$ = hEADER$ + "Time"
hEADER$ = hEADER$ + dELIMITER$ + "Pitch"
selectObject ("Sound Sound")
tmin = Get start time
tmax = Get end time
# do ("To Pitch (ac)...", 0, 75, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 600)
#do ("To Pitch (SPINET)...", 0.0167, 0.04, 70, 5000, 250, 500, 15)
do ("To Pitch...", 0.0167, 75, 600)
do ("Rename...", "Pitch")

hEADER$ = hEADER$ + dELIMITER$ + "Intensity"
selectObject ("Sound Sound")
do ("To Intensity...", 70, 0.0167, "yes")
do ("Rename...", "Intensity")

for i to mFCC_NUM_COEFFICIENTS
    hEADER$ = hEADER$ + dELIMITER$ + "MFCC_" + string$ (i)
endfor
selectObject ("Sound Sound")
# Num of coefficients, Window_length, Time_step, PositionOfFirstFilter (mel), DistanceBWfilters(mel), MaxFreq (mel)
do ("To MFCC...", mFCC_NUM_COEFFICIENTS, 0.015, 0.005, 100, 100, 0)
do ("Rename...", "MFCC")

writeInfoLine("Here are the results:")
deleteFile(output_file$)

appendFileLine(output_file$, hEADER$)

for i to (tmax-tmin) * 60
    output_line$ = ""
    time = tmin + i / 60
    output_line$ = output_line$ + string$ (time)

    selectObject("Pitch Pitch")
    pitch = do ("Get value at time...", time, "Hertz", "Linear")
    output_line$ = output_line$ + dELIMITER$ + fixed$ (pitch, pRecision)

    selectObject("Intensity Intensity")
    intensity = do ("Get value at time...", time, "Cubic")
    output_line$ = output_line$ + dELIMITER$ + fixed$ (intensity, pRecision)

    selectObject("MFCC MFCC")
    for j to mFCC_NUM_COEFFICIENTS
        cur_mfcc = do ("Get value...", time, j)
        output_line$ = output_line$ + dELIMITER$ + fixed$ (cur_mfcc, pRecision)
    endfor

    appendInfoLine(output_line$)
    appendFileLine(output_file$, output_line$)
endfor
