# Contextualization
Start the instance by running "python ssc-instance-userdata.py", you will need to edit it with the relevant ssh key. The script will start the REST api which is ready to receive requests to run the BENCHOP problems.
Curl can be used to run problems in the following manner, for more info on parameters check ACC2-BENCHOP/matlab/README.md
```
curl -i "http://111.222.333.444:5000/p1a?S1=90&S2=100&S3=110"
```

## Old instructions:
To start instance: run the command "./init_instance.sh" in your command-line client. If you can't make it work on your local computer, just use an Openstack VM, follow Task-0 on Github for Lab 2, clone into this repository and execute the script from there to get the instance started. Then go into the Openstack dashboard, assign it a floating IP and then use our private key to ssh into it from your local computer. 


# It will take a while for the VM to be completely set up by the config-file!
OBS: Mind the maximum instance-quota in Openstack as you initiate the instance!
