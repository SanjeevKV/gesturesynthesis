import pandas as pd
import numpy as np
import argparse
import os

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-o", "--output", help = "Output file", required = True)
    parser.add_argument("-l", "--lower_limit", help = "Least window size", default = 5, required = False)
    parser.add_argument("-s", "--steps", help = "Duration to skip before next window size", default = 5, required = False)
    parser.add_argument("-d", "--data_folder", help = "Consolidated Data Folder", default = "/home/sanjeev/Documents/HeadMotionData/ConsolidatedOutput", required = False)
    parser.add_argument("-u", "--upper_limit", help = "Max window size", default = 70, required = False)
    parser.add_argument("-g", "--log_folder", help = "Folder containing logs", default = "Logs/", required = False)
    argument = parser.parse_args()
    
    ll = int(argument.lower_limit)
    ul = int(argument.upper_limit)
    steps = int(argument.steps)
    
    consolidated_performance = []
    for i in range(ll, ul + 1, steps):
        current_folder = os.path.join(argument.data_folder, str(i), argument.log_folder)
        current_files = os.listdir(current_folder)
        for cur_file in current_files:
            with open(os.path.join(current_folder, cur_file), "r") as perf_rep:
                performance = perf_rep.readline()
                individual_performance = performance.split("-")
                epoch, acc, val_acc = np.array(individual_performance).astype(float)
                fold = int(cur_file.split("-")[-1])
                consolidated_performance.append([i, fold, epoch, acc, val_acc])
                
    df = pd.DataFrame(consolidated_performance, columns = ["WindowLength","Fold", "Epoch", "Accuracy", "Val_Accuracy"])
    df.to_csv(argument.output, index = False)                
    
