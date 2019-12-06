from keras.models import load_model
from keras.metrics import top_k_categorical_accuracy
import numpy as np
import scipy.io as io
import sys

def top_k_accuracy(y_true, y_pred):
    return top_k_categorical_accuracy(y_true, y_pred, k=5)

MODEL_LOCATION = "/home/sanjeev/Documents/HeadMotionData/models/k-fold/2019-09-12/Mocap-functional_CNN_maxpool_lstm_glob-fold-3-weights-improvement-111-0.94-0.85-0.99.hdf5"

WEIGHTS_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/k-fold/2019-09-12/Mocap-functional_CNN_maxpool_lstm_glob-fold-3-weights-improvement-111-0.94-0.85-0.99.mat"

CUSTOM_OBJECTS = {"top_k_accuracy" : top_k_accuracy, "top_k_categorical_accuracy" : top_k_categorical_accuracy}

LAYERS = ["convolution", "lstm"]
data_dictionary = {}

model  = load_model(MODEL_LOCATION, custom_objects = CUSTOM_OBJECTS)
for layer in model.layers:
    print(layer.name)
for layer in LAYERS:
    data_dictionary[layer] = model.get_layer(layer).get_weights()

io.savemat( WEIGHTS_LOCATION, data_dictionary )    
#sys.exit()
#weights = model.get_layer(LAYER).get_weights()[0]
#weights_shape = weights.shape
#biases = model.get_layer(LAYER).get_weights()[1].reshape(1,-1)

#cell_filter_values = []
#for i in range(weights_shape[0]):
#    for j in range(weights_shape[1]):
#        cell_filter_values.append( weights[i][j].reshape(1,-1) )
#        
#filter_weights = np.concatenate(cell_filter_values, axis = 0)
#filter_weights_bias = np.concatenate( (filter_weights, biases) , axis = 0)

#io.savemat( WEIGHTS_LOCATION, {"weights" : filter_weights_bias} )


