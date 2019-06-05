# example: Create a simple Machine Learning environment with AWS EC2

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

4. Login via SSH

```shellsession
$ ssh $IPADDR -lubuntu hostname
ip-10-0-0-136
```

### Additional samples

```shellsession
$ tar c sample-files | ssh $IPADDR -lubuntu tar x 
```

```shellsession
$ ssh $IPADDR -lubuntu
=============================================================================
       __|  __|_  )
       _|  (     /   Deep Learning AMI (Ubuntu) Version 23.0
      ___|\___|___|
=============================================================================

Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-1081-aws x86_64v)
```

```shellsession
ubuntu@ip-10-0-0-136:~$ cd sample-files/docker-compose-2.3-tensorflow/
ubuntu@ip-10-0-0-136:~/sample-files/docker-compose-2.3-tensorflow$ docker-compose up
Creating network "docker-compose-23-tensorflow_default" with the default driver
Creating docker-compose-23-tensorflow_tensorflow_1 ... done
Attaching to docker-compose-23-tensorflow_tensorflow_1
tensorflow_1  | 
tensorflow_1  | ________                               _______________                
tensorflow_1  | ___  __/__________________________________  ____/__  /________      __
tensorflow_1  | __  /  _  _ \_  __ \_  ___/  __ \_  ___/_  /_   __  /_  __ \_ | /| / /
tensorflow_1  | _  /   /  __/  / / /(__  )/ /_/ /  /   _  __/   _  / / /_/ /_ |/ |/ / 
tensorflow_1  | /_/    \___//_/ /_//____/ \____//_/    /_/      /_/  \____/____/|__/
tensorflow_1  | 
tensorflow_1  | 
tensorflow_1  | WARNING: You are running this container as root, which can cause new files in
tensorflow_1  | mounted volumes to be created as the root user on your host machine.
tensorflow_1  | 
tensorflow_1  | To avoid this, run the container by specifying your user's userid:
tensorflow_1  | 
tensorflow_1  | $ docker run -u $(id -u):$(id -g) args...
tensorflow_1  | 
tensorflow_1  | [I 07:13:25.676 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
tensorflow_1  | [I 07:13:26.737 NotebookApp] Serving notebooks from local directory: /tf
tensorflow_1  | [I 07:13:26.737 NotebookApp] The Jupyter Notebook is running at:
tensorflow_1  | [I 07:13:26.737 NotebookApp] http://(346c7f6415c0 or 127.0.0.1):8888/?token=2d6b3cf3803711b27a856915fb61da5bf1fd31ebf94b66a2
tensorflow_1  | [I 07:13:26.737 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
tensorflow_1  | [C 07:13:26.740 NotebookApp] 
tensorflow_1  |     
tensorflow_1  |     To access the notebook, open this file in a browser:
tensorflow_1  |         file:///root/.local/share/jupyter/runtime/nbserver-8-open.html
tensorflow_1  |     Or copy and paste one of these URLs:
tensorflow_1  |         http://(346c7f6415c0 or 127.0.0.1):8888/?token=2d6b3cf3803711b27a856915fb61da5bf1fd31ebf94b66a2
```

Open `http://$IPADDR:8888` in your browser.

```shellsession
ubuntu@ip-10-0-0-136:~/sample-files/docker-compose-2.3-tensorflow$ docker-compose run tensorflow nvidia-smi
Wed May 22 07:17:23 2019       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 418.40.04    Driver Version: 418.40.04    CUDA Version: 10.1     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla V100-SXM2...  On   | 00000000:00:1E.0 Off |                    0 |
| N/A   41C    P0    23W / 300W |      0MiB / 16130MiB |      1%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```
