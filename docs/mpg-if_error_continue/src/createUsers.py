#!/usr/bin/python3

import os


### function to read users from text file -----

def getUsers(txt = "/home/jupyter/users.txt"):

    # read comma separated text file
    fl = open(txt)
    ln = fl.readlines()

    # extract users
    usr = ln[0].replace("\n", "").split(", ")
    return(usr)


### function to create new users with default passwords -----

def createUsers(txt = "/home/jupyter/users.txt", dsn = "/home/jupyter", quiet = True):

    # get users
    usr = getUsers(txt)

    # add each user to 'jupyter' group, create sub-folder in /home/jupyter, 
    # and set default password
    for i in usr:
        dir = os.path.join(dsn, i)
        cmd = 'adduser ' + i + ' --gecos "" --home ' + dir + ' --ingroup jupyter --disabled-password'
        os.system(cmd)

        pwd = 'echo "' + i + ':1q2w3e" | chpasswd'
        os.system(pwd)

    if not quiet:
        print("Creation of users finished successfully!\n")

    return(usr)


### function to add users to jupyterhub's whitelist -----

def add2Whitelist(cfg = "/root/jupyterhub/jupyterhub_config.py", txt = "/home/jupyter/users.txt"):

    fl = open(cfg)
    lns = fl.readlines()
    fl.close()

    ## extract users on whitelist
    awl = [ln for ln in lns if "c.Authenticator.whitelist" in ln][0]
    old = awl.split("[")[1].split("]")[0]

    ## add new users
    usr = getUsers(txt)

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


### create users -----

jnk1 = createUsers()
jnk2 = add2Whitelist()

print("User creation finished successfully.\n")