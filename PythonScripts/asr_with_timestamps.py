#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug  7 15:29:37 2019

@author: sanjeev
"""

import argparse
import io
from pydub import AudioSegment
import pandas as pd
"""
sentence_number - Either nan or 1 + multiple of SKIP_N
SKIP_N - Number of spoken regions detected by SAD sent to Google Apis at once
sentences - Never nan (optionally at the beginning). -1 only in large pauses and positive elsewhere (Contains the enumeration for continuous spoken regions)
Note**: This might cause the issue of Silence regions being detected as spoken regions in API calls
"""

def transcribe_file_with_word_time_offsets(speech_file, seg_num, lc, phrases, batch_start_time):
    """Transcribe the given audio file synchronously and output the word time
    offsets."""
    from google.cloud import speech
    from google.cloud.speech import enums
    from google.cloud.speech import types
    client = speech.SpeechClient()
    with io.open(speech_file, 'rb') as audio_file:
        content = audio_file.read()
    audio = types.RecognitionAudio(content=content)
    
    speech_contexts_element = {"phrases": phrases}
    speech_contexts = [speech_contexts_element]
    
    config = types.RecognitionConfig(
        encoding=enums.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code=lc,
        speech_contexts=speech_contexts,
        enable_word_time_offsets=True)
    
    print('Waiting for operation to complete...')
    response = client.recognize(config, audio)
    
    transcript = []
    for result in response.results:
        alternative = result.alternatives[0]
        #print(u'Transcript: {}'.format(alternative.transcript))
        for word_info in alternative.words:
            word = word_info.word
            start_time = word_info.start_time
            end_time = word_info.end_time
            transcript.append([seg_num, word, start_time.seconds + start_time.nanos * 1e-9, end_time.seconds + end_time.nanos * 1e-9, batch_start_time])
            
    return transcript

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-t", "--transcript", help = "Set of words in the IDEAL transcript", default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/StimuliWords/Story1En.csv")
    parser.add_argument("-o", "--output", help = "Output location of the segments", default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/asr_audio_segments/2016-05-28_16-17-34_PavanIn_Story1En")
    parser.add_argument("-w", "--wav", help = "Wav file to be transcripted", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/Audio/2016-05-28_16-17-34_PavanIn_Story1En.wav")
    parser.add_argument("-s", "--sad", help = "File containing speech activity timestamps", required =  False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/SAD/2016-05-28_16-17-34_PavanIn_Story1En.csv")
    parser.add_argument("-l", "--language", help = "Language of recitation", required = False, default = "en-IN")
    
    MUL_FACTOR = 1000 #pydub considers time in milliseconds
    SKIP_N = 10

    argument = parser.parse_args()
    
    wdf = pd.read_csv(argument.transcript)
    phrases = list(wdf["Words"])
    
    audio = AudioSegment.from_wav(argument.wav)
    sad = pd.read_csv(argument.sad, sep = " ")
    
    transcript = []
    for i in range(0, sad.shape[0], SKIP_N):
        if i + SKIP_N > sad.shape[0]:
            SKIP_N = sad.shape[0] - i
        small_audio = audio[sad["start_time"][i] * MUL_FACTOR : sad["end_time"][i + SKIP_N - 1] * MUL_FACTOR]
        small_audio.export(argument.output + "_seg_" + str(i), format = "wav")
        transcript.extend(transcribe_file_with_word_time_offsets(argument.output + "_seg_" + str(i), i + 1, argument.language, phrases, sad["start_time"][i]))
    
    df = pd.DataFrame(transcript, columns = ["sentence_number", "word", "word_start_time", "word_end_time", "batch_start_time"])   
    df.to_csv(argument.output + ".csv", index = False)
     
    #tr_test = transcribe_file_with_word_time_offsets("/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/asr/2016-05-28_16-17-34_PavanIn_Story1En.csv_seg_1", 2, "en-US")
    #transcript = transcribe_file_with_word_time_offsets(argument.wav, argument.language)