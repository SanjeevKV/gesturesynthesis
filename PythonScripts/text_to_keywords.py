#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug  8 10:04:15 2019

@author: sanjeev

This script is just meant to be a helper script. Extracts out the keywords (Length greater than LENGTH) from input file and
writes it to the output file
"""

import argparse
import io
import re
import pandas as pd

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-i", "--input", help = "Input text", default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/StimuliText/Story5En.txt")
    parser.add_argument("-o", "--output", help = "Output location of the segments", default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/StimuliWords/Story5En.csv")
    
    LENGTH = 2

    argument = parser.parse_args()
    with open(argument.input, 'r') as f:
        text = f.read()
        
    text = text.lower()
    pattern = re.compile(r"[^a-z0-9]")
    text_replaced = list(filter(lambda x : len(x) > LENGTH,set(re.sub(pattern, " ", text).split())))
    df_words = pd.DataFrame(text_replaced, columns = ["Words"])
    df_words.to_csv(argument.output, index = False)