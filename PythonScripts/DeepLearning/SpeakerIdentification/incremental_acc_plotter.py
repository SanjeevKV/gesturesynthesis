import argparse
import pandas as pd
import os
from matplotlib import pyplot as plt
import numpy as np
import sys

if __name__ == "__main__":
    
    NUM_COLS = 2
    
    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-r", "--root", help = "Consolidated output root", required = True)
    parser.add_argument("-i", "--inc_folder", help = "Incremental acc Folder", default = "Incremental/", required = False)
    parser.add_argument("-u", "--ul", help = "Highest duration window", default = 70, required = False)
    parser.add_argument("-l", "--ll", help = "Least duration window", default = 5, required = False)
    parser.add_argument("-s", "--ws_delta", help = "Window size delta", default = 5, required = False)
    argument = parser.parse_args()
    
    upper_limit = int(argument.ul)
    lower_limit = int(argument.ll)
    ws_delta = int(argument.ws_delta)
    
    num_plots = int( (upper_limit - lower_limit) / ws_delta) + 1
    fig, ax = plt.subplots( nrows = int(np.ceil(num_plots / NUM_COLS)), ncols = NUM_COLS, sharex = True) 
    
    windows = np.array(os.listdir(argument.root)).astype(int)
    windows = sorted(windows)
    print(windows)
    #sys.exit()
    for wc, cur_window in enumerate(windows):
        folds = os.listdir( os.path.join(argument.root, str(cur_window), argument.inc_folder) )
        cur_row = wc // NUM_COLS
        cur_col = wc % NUM_COLS
        #print(cur_row, cur_col)
        for cur_fold in folds:
            if cur_fold.find("inc") != -1:
                df = pd.read_csv( os.path.join(argument.root, str(cur_window), argument.inc_folder, cur_fold) )
                #print(cur_row, cur_col, cur_window)
                ax[cur_row][cur_col].title.set_text(str(cur_window))
                ax[cur_row][cur_col].plot(df["Chunk"], df["Acc"])
            
    plt.show()
    
    
