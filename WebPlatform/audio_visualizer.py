#!/usr/bin/env python3
import pdb
import numpy as np
import scipy.io.wavfile
import matplotlib.pyplot as plt

def plot_waveform(filename, sample_rate):
    '''
    Plots the waveform of the input .wav file.

    Arguments:
    - filename (string) : the filename of the .wav file.
    - sample_rate (int) : plot data for every (1 / sample_rate) samples
    '''

    # Obtain the audio data from the .wav file
    rate, data = scipy.io.wavfile.read(filename) #Gets the sample rate in Hertz (samples/second)
   
    # Reshape the array if the audio is mono-channel 
    if data.ndim == 1:
        data = data.reshape(data.size, 1)

    # Calculate time axis in seconds
    t = sample_rate*np.arange(data.shape[0] / sample_rate) / rate

    # Plot audio data vs. time
    for channel in range(data.shape[1]):
        plt.plot(t, data[::sample_rate,channel], label = "Channel {}".format(channel))
    
    # Display the plot
    plt.legend()
    plt.xlabel("Time (seconds)")
    plt.ylabel("Signal Amplitude")
    plt.show()


if __name__ == "__main__":
    plot_waveform("/Users/isaacbevers/Hybrid-Physical-Digital-Spaces/WebPlatform/Breath-Recording-Tests/br3.wav", 100)
