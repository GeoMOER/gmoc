#!/usr/bin/python3

import os

def add2Whitelist(cfg = "/root/jupyterhub/jupyterhub_config.py", quiet = True):

    fl = open(cfg)
    lns = fl.readlines()
    fl.close()

    ## extract users on whitelist
    awl = [ln for ln in lns if "c.Authenticator.whitelist" in ln][0]
    old = awl.split("[")[1].split("]")[0]

    ## add new users
    usr = getUsers()

    n = 1
    for i in usr:
        if i not in old:
            if n == 1:
                new = old + ", '" + i + "'"
                n += 1
            else:
                new = new + ", '" + i + "'"

    ids = []
    for i in range(len(lns)):
        if "c.Authenticator.whitelist" in lns[i]:
            ids.append(i)

    lns[ids[0]] = awl.replace(old, new)

    ## write updated whitelist to file
    os.remove(cfg)

    fl = open(cfg, "w")
    for item in lns:
      jnk = fl.write("%s" % item)

    fl.close()

    if not quiet:
    print("Process finished successfully!\n")
