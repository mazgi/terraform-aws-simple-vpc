# example: Create VMs with Local and Network Filesystems

## Recommends

- [direnv](https://github.com/direnv/direnv)
- [tfenv](https://github.com/tfutils/tfenv)

## Before use

Edit the `.envrc` file with `direnv edit .` command.

```
export PROJECT_UUID='YOUR_UNIQ_STRING'
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCESS_KEY_ID=$(tail -1 credentials.csv | cut -d, -f3)
export AWS_SECRET_ACCESS_KEY=$(tail -1 credentials.csv | cut -d, -f4)
export TF_VAR_aws_account_id="123456789012"
export TF_VAR_current_external_ipaddr="$(curl -Ls ifconfig.io)/32"
```

Create a S3 bucket for save tfstate.

see https://docs.aws.amazon.com/cli/latest/reference/s3api/

```shellsession
$ aws s3api create-bucket --bucket "${PROJECT_UUID}" --region us-east-1
{
    "Location": "/YOUR_UNIQ_STRING"
}
$ aws s3api put-bucket-versioning --bucket "${PROJECT_UUID}" --versioning-configuration Status=Enabled
$ aws s3api get-bucket-versioning --bucket "${PROJECT_UUID}"
{
    "Status": "Enabled"
}
```

## How to use

1. Install Terraform via tfenv.

```shellsession
$ tfenv install min-required
```

or

```shellsession
$ tfenv use min-required
```

2. `terraform init`

```shellsession
$ terraform init -backend-config="bucket=${PROJECT_UUID}"
```

3. `terraform apply`

```shellsession
$ terraform apply
```
```
Outputs:

aws_instance-multiple-volumes-instances = {
  "multiple-volumes-instance-01" = "50.19.*.55"
  "multiple-volumes-instance-02" = "18.209.*.197"
}
```

4. Login via SSH

```shellsession
$ ssh $IPADDR -lubuntu hostname
ip-10-0-0-136
```

### Additional samples: Using EBS

List block devices.

```shellsession
$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0         7:0    0 88.4M  1 loop /snap/core/6964
loop1         7:1    0   18M  1 loop /snap/amazon-ssm-agent/1335
nvme0n1     259:0    0  200G  0 disk 
nvme1n1     259:1    0  1.1T  0 disk 
nvme2n1     259:2    0  100G  0 disk 
└─nvme2n1p1 259:3    0  100G  0 part /
nvme3n1     259:4    0  1.3T  0 disk 
```

Create a partition on the EBS block device.

```shellsession
$ sudo gdisk /dev/nvme0n1
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries.

Command (? for help): n
Partition number (1-128, default 1): 
First sector (34-419430366, default = 2048) or {+-}size{KMGTP}: 
Last sector (2048-419430366, default = 419430366) or {+-}size{KMGTP}: 
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/nvme0n1.
The operation has completed successfully.
```

Check the partition.

```shellsession
$ sudo gdisk -l /dev/nvme0n1
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.
Disk /dev/nvme0n1: 419430400 sectors, 200.0 GiB
Model: Amazon Elastic Block Store              
Sector size (logical/physical): 512/512 bytes
Disk identifier (GUID): D75C69BB-0D30-4B35-AA27-C8CBAF9F5F11
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 34, last usable sector is 419430366
Partitions will be aligned on 2048-sector boundaries
Total free space is 2014 sectors (1007.0 KiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048       419430366   200.0 GiB   8300  Linux filesystem
```

Format the partition.

```shellsession
$ sudo mkfs.ext4 /dev/nvme0n1p1
mke2fs 1.44.1 (24-Mar-2018)
Creating filesystem with 52428539 4k blocks and 13107200 inodes
Filesystem UUID: a7d60c9f-7f70-49da-94a2-6fa174e1c496
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done    
```

Mount the partition.

```shellsession
$ sudo mkdir -p /mnt/ebs-gp2
$ sudo mount /dev/nvme2n1p1 /mnt/ebs-gp2
```

```shellsession
$ lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0         7:0    0 88.4M  1 loop /snap/core/6964
loop1         7:1    0   18M  1 loop /snap/amazon-ssm-agent/1335
nvme0n1     259:0    0  1.3T  0 disk 
└─nvme0n1p1 259:6    0  1.3T  0 part /mnt/ebs-io1
nvme1n1     259:1    0  1.1T  0 disk 
└─nvme1n1p1 259:7    0  1.1T  0 part /mnt/ebs-local-nvme
nvme3n1     259:2    0  500G  0 disk 
└─nvme3n1p1 259:4    0  500G  0 part /
nvme2n1     259:3    0  500G  0 disk 
└─nvme2n1p1 259:8    0  500G  0 part /mnt/ebs-gp2
```

### Additional samples: Using EFS

Install `nfs-common` package.

```shellsession
$ sudo apt update
$ sudo apt install -y --no-install-recommends nfs-common
```

Mount the EFS volume.

```shellsession
$ sudo mkdir -p /mnt/efs-generalPurpose-bursting
$ sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-****.efs.us-east-1.amazonaws.com:/ /mnt/efs-generalPurpose-bursting
```

```shellsession
$ df -h --type=nfs4
Filesystem                                 Size  Used Avail Use% Mounted on
fs-15a031f6.efs.us-east-1.amazonaws.com:/  8.0E     0  8.0E   0% /mnt/efs-generalPurpose-bursting
fs-11a031f2.efs.us-east-1.amazonaws.com:/  8.0E     0  8.0E   0% /mnt/efs-generalPurpose-provisioned
fs-17a031f4.efs.us-east-1.amazonaws.com:/  8.0E     0  8.0E   0% /mnt/efs-maxIO-bursting
fs-10a031f3.efs.us-east-1.amazonaws.com:/  8.0E     0  8.0E   0% /mnt/efs-maxIO-provisioned
```

### Additional samples: Benchmarking filesystems

```shellsession
$ sudo chmod a+rwx /mnt/*
```

Install `fio` package.

```shellsession
$ sudo apt update
$ sudo apt install -y --no-install-recommends fio
```

```shellsession
(your-local)$ tar c sample-files | ssh $IPADDR -lubuntu tar x
```

```shellsession
$ sh ~/sample-files/generate_fio.sh > exec.sh
$ . exec.sh
```

## Links

- [Amazon EBS Volume Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html)
- [Mounting File Systems Without the EFS Mount Helper](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-old.html)
- [Mounting on Amazon EC2 with a DNS Name](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html)
- [Amazon EFS Performance](https://docs.aws.amazon.com/efs/latest/ug/performance.html)
- https://github.com/axboe/fio
