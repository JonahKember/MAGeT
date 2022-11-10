import sys, os
import glob
import pandas as pd
import numpy as np
import scipy
import scipy.io
from scipy.io import savemat, loadmat
from numpy import dot
from numpy.linalg import norm
import errno
from sklearn.metrics.pairwise import cosine_similarity
n_splits = 5

for g in range(2,8):

    out_dir = "stability_correlations/" #name of output directory. MODIFY if you like
    stab_dir = "/home/jkember/scratch/NMF_stability/" #MODIFY path to location where .mat outputs from nmf for stability analysis are

    if not os.path.exists(out_dir): #make output directory
        try:
            os.makedirs(out_dir)
        except OSError as exc:
            if exc.errno == errno.EEXIST:
                pass
            else:
                raise

    cols = ["Granularity","Iteration","Corr_mean","Corr_median","Corr_std","Recon_errorA","Recon_errorB"]
    df = pd.DataFrame(columns = cols)
    for i in range(1,n_splits + 1):
        
        #load split input, get W mx for each
        fname = stab_dir + "k" + str(g) + "/A" + str(i) + ".mat" #MODIFY to match path to files, if appropriate
        resA = scipy.io.loadmat(fname)
        Wa = resA['W']
        ea = resA['recon']
            
        fname = stab_dir + "k" + str(g) + "/B" + str(i) + ".mat" #MODIDFY to match path to files, if appropriate
        resB = scipy.io.loadmat(fname)
        Wb = resB['W']
        eb = resB['recon']

        #assess correlation of identified parcel component scores - which parcels vary together?
        print(Wa)
        
        c_Wa = cosine_similarity(Wa)
        c_Wb = cosine_similarity(Wb)
            
        corr = np.zeros((1,np.shape(c_Wa)[0]))

        for parcel in range(0,np.shape(c_Wa)[0]):
            corr[0,parcel] = np.corrcoef(c_Wa[parcel,:],c_Wb[parcel,:])[0,1]

        df_curr = pd.DataFrame(data = [[g, i+1, np.mean(corr),np.median(corr),np.std(corr),ea,eb]], columns = cols)

        print(i, np.mean(corr))
        df = df.append(df_curr)
        del Wa,Wb,ea,eb,resA,resB
        
    fname = out_dir + "stability_corr_k" + str(g) + ".csv"
    print(fname)
    df.to_csv(fname)
    del df, df_curr

