import numpy as np
import sys
import glob
import pickle
arglist = sys.argv

tracksout = arglist[3]
timesout = arglist[2]
txts = arglist[1]+'*'

# get individual particle tracks for the 1000 particles simulated
posits = sorted(glob.glob(txts)) 

cur = np.genfromtxt(posits[0], delimiter = ',', usecols = [1,2,3, 9]) # open first txt file to get shape of data

tracks = np.zeros([cur.shape[0], 4, 0])
times = []

for i, posit in enumerate(posits):
    try:
        cur = np.genfromtxt(posit, delimiter = ',', usecols = [1,2,3, 9]) # lon, lat, height (m), BL height
        cur.shape = [cur.shape[0],4,1]
        tracks = np.append(tracks,cur, axis = 2)
        times=np.append(times, posit[posit.find('_202')+1:-4]) # edit this _201 to the relevent numbers of the partposit files
    except:
        continue

output = open(tracksout+'.pkl', 'wb')
pickle.dump(tracks, output)
output.close()

output = open(timesout+'.pkl', 'wb')
pickle.dump(times, output)
output.close()
