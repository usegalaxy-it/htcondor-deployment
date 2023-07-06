# HTCondor Deployment

This repository contains a Terraform configuration for creating an HTCondor10 cluster within an OpenStack cloud environment. It also includes the allocation of floating IPs.  

## Requirements

API access to OpenStack  
Terraform >= 1.3.9  
Ansible >= 2.9

## How to use

The HTCondor10 cluster deployed within the OpenStack cloud environment consists of several components. These components include an HTCondor Central Manager (CM), an NFS server with an attached volume, and a minimum of one executor. It is possible to connect a submit machine to the existing cluster.  

Follow these steps to use the configuration:  

1. Install Terraform  
   `sudo <PM> install terraform`  
2. Install Ansible
   `sudo <PM> install ansible`
3. Source your openstack credentials  
   `source <openstack-cred-file>`    
   ```
    export OS_AUTH_URL=https://openstack.your.fqdn:5000/v2.0
    export OS_TENANT_NAME=...
    export OS_PASSWORD=...
    export OS_PROJECT_NAME=...
    export OS_REGION_NAME=...
    export OS_TENANT_ID=...
    export OS_USERNAME=...
   ```
4. Fork the repository and clone it.
5. `cd htcondor-deployment`  
6. Generate a key pair:  
   - Generate new key by running `ssh-keygen`.  
   - Specify the public SSH key as the value of the `public_key` variable in the `vars.tf` file.
   - Create the `terraform.tfvars` file. This file will not be exposed on github, specify sensitive values here in the form:  
   ```
    pvt_key     = "<path_to_private_ssh_key>"
    condor_pass = "<condor_password>"
   ```
7. Review and configure other variables in `vars.tf` file according to your OpenStack cloud setup.  
8. Review `pre_tasks.tf` file and comment out any resources that are already present in your tennant.
9.  Initialize Terraform:  
    `terraform init`  
10. Preview the execution plan:  
    `terraform plan`  
11. Apply the Terraform configuration:  
    `terraform apply`  
12. The produced output contains:  
   - central manager public IP  
   - central manager private IP  
   - central manager hostname  
   - executors IPs  
   - NFS server IP  

**NOTE!**
If you don't want to use `terraform.tfvars`, you can specify the sensitive values directly using the -var flag when running terraform apply:
```bash
terraform apply -var "pvt_key=<path_to_private_ssh_key>" -var "condor_pass=<condor_password>"
``` 
## Basic configuration

The following table shows the OpenStack machine flavors used for each VM in the cluster:  

| VM              | OpenStack Machine Flavours |
| --------------- | -------------------------- |
| central manager | m1.small                   |
| nfs server      | m1.medium                  |
| exec nodes      | m1.xlarge                  |

Additional configuration details:  

- Image: Rocky Linux 9 
- Number of executors : 2  
- 300 GB NFS attached volume  

## Variables

| Variable        | Default value       | Description                                                                                                       |
| --------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| public_key      | ...                 | SSH public key to access VMs from your control machine                                                            |
| public_network  | ...                 | Name of your public network to access internet. Necessary to associate floating IPs                               |
| private_network | ...                 | Name, subnet_name and cidr4 of the private network                                                                |
| pvt_key         | ...                 | **Sensitive**. Path to the private SSH key                                                                        |
| condor_pass     | ...                 | **Sensitive**. HTCondor password. Needed for authentication and authorization of machines inside HTCondor cluster |
| nfs             | name = nfs-htcondor | Name for NFS attached volume                                                                                      |
| nfs             | disk_size = 300     | The size of volume in GB                                                                                          |
| flavors         | ...                 | Flavour map from the list of available OpenStack flavours for computing insyances                                 |
| exec_node_cont  | 2                   | Number of executors                                                                                               |
| image           | ...                 | The name and the source url of the image to upload in your openstack environment                                  |
| name_prefix     | htcondor-           | Every machine name will start with this prefix                                                                    |
| secgroups_cm    | ...                 | List of security groups of Central Manager                                                                        |
| secgroups       | ...                 | List of security groups of NFS server and exec nodes                                                              |
| domain_name     | htcondor            | Filesystem domain and UID domain for HTCondor configuration                                                       |
| ssh-port        | 22                  | Default SSH port                                                                                                  |

## Verify Successfull Deployment

The executors require some time to run installation and configuration scripts in the background. A few minutes after Terraform has successfully finished, you can verify the deployment by running the following commands from your control VM:
```bash
ssh -i <path_to_private_ssh_key> rocky@<CM_public_IP> 
condor_status
```
You should see a similar output:
```
Name                                     OpSys      Arch   State     Activity LoadAv Mem    ActvtyTime

slot1@htcondor-exec-node-0.garr.cloud.pa LINUX      X86_64 Unclaimed Idle      0.000 15736  0+00:04:37
slot2@htcondor-exec-node-1.garr.cloud.pa LINUX      X86_64 Unclaimed Idle      0.000 15736  0+00:05:17

               Total Owner Claimed Unclaimed Matched Preempting Backfill  Drain

  X86_64/LINUX     2     0       0         2       0          0        0      0

         Total     2     0       0         2       0          0        0      0


```

Additionally, you can manually create and run a simple job in the shared directory.  

1. Create simple test script `test.sh`:
```bash
#!/bin/bash
sleep 10
echo "HTCondor is up!"
```
2. Make the script executable:
```
chmod +x test.sh
```
3. Create a submit file `submit.sub` that will be run by HTCondor:
```
executable  = my_first_script.sh
universe    = vanilla
output      = output.out
error       = error.err
log         = log.log
queue
```
4. Submit the job:
```bash
condor_submit submit.sub
```

You will see a similar result
```bash
Submitting job(s).
1 job(s) submitted to cluster 1.
```

Check the `/data/share` directory to view the produced output and log files.

## Optionally: Connect Submit Machine

Starting from version 9.0.0, HTCondor introduces a new authentication mechanism called IDTOKENS. This method requires the same password to be set for all machines of the cluster. The condor_collector process (on Central Manager in this configuration) will automatically generate the pool signing key named POOL on startup if that file does not exist.
Cron job running on CM allows to automatically approve tokens from machines within the CIDR range.  

You can run the following play to install and configure HTCondor10 on the Submit VM.

```YAML
- name: Install HTCondor Submit
  become: yes
  hosts: <submit_vm>
  pre_tasks:
    - name: Disable SELinux
      selinux:
        state: disabled
  roles:
    - name: usegalaxy_eu.htcondor
      vars:
         condor_role: submit
         condor_host: <condor_CM_private_IP>
         condor_password: <condor_pass>
         condor_allow_write: "*" 
         condor_daemons:
           - MASTER
           - SCHEDD
         condor_allow_negotiator: $(ALLOW_WRITE)
         condor_allow_administrator: $(ALLOW_NEGOTIATOR)
         condor_fs_domain: <domain_name>
         condor_uid_domain: <domain_name>
         condor_enforce_role: false
```

**NOTE!** If in some case you re-install HTCondor on CM, the signing key will be regenerated and other machines of the cluster will not be able to connect to CM automatically. From here 2 options are possible:
1. You will need to rebuild other machines as well after CM is ready. The authentication will be done automatically.  
2. Issue new token and specify it on Executors and Submit. 
   - Signing key is generated during installation and is stored by default in `/etc/condor/passwords.d/POOL`.
   - Create new IDTOKEN file with identity "condor" on CM:
      ```
      condor_token_create -identity condor@<domain_name>
      ```
   - Append the token to the file `~/.condor/tokens.d` on all the servers you want to join.