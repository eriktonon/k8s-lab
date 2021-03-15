#!/bin/bash
## Generate key 
ssh-keygen -b 2048 -t rsa -f id_rsa -q -N ''
#start lab
vagrant up 