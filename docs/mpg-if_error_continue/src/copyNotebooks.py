#!/usr/bin/python3

import os

from os.path import isdir, isfile, join, basename
from shutil import copyfile


### function to read users from text file -----

def getUsers(txt = "/home/jupyter/users.txt"):

    # read comma separated text file
    fl = open(txt)
    ln = fl.readlines()

    # extract users
    usr = ln[0].replace("\n", "").split(", ")
    return(usr)


### function to copy jupyter notebook files (.ipynb) to user-specific home folders -----

def copyJupyter(src = "/home/jupyter/fdetsch", dsn = "."):

    for suffix in [".ipynb", ".txt"]:

        # find jupyter notebook files in 'src'
        fls = os.listdir(src)
        jnb = [join(src, f) for f in fls if isfile(join(src, f)) and suffix in f]

        # create 'dsn' if it does not exist
        if not isdir(dsn):
            os.makedirs(dsn)

        # if required, copy jupyter notebook files
        for i in jnb:
            dst = join(dsn, basename(i))

            if not isfile(dst):
                copyfile(i, dst)


### copy files -----

usr = getUsers()

for i in usr:
    jnk = copyJupyter(dsn = join("/home/jupyter", i))

print("Copying the Jupyter Notebooks finished successfully!\n")