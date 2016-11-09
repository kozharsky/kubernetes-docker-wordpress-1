


## Setup Kubernetes on AWS

Note: pick aws region and use it always the same

1. Ensure AWS CLI is installed and configured with an access key / secret with enough permissions to create the containers, S3 buckets, security groups, etc and is in your path.
1. Start the following command to download the latest kubernetes but make sure to stop it (Ctrl-C) after it uncompresses and before it makes things as it will ship with a default config.
`export KUBERNETES_PROVIDER=aws; curl -sS https://get.k8s.io | bash`
1. Configure the following as you like (more details at [Kubernetes Getting Started Guides](http://kubernetes.io/docs/getting-started-guides/aws/))
```
export KUBE_AWS_ZONE=us-east-1d
export NUM_NODES=2
export MASTER_SIZE=t2.small
export NODE_SIZE=t2.small
export AWS_S3_REGION=us-east-1
export AWS_S3_BUCKET=anythingyoulike-kubernetes-artifacts
export KUBE_AWS_INSTANCE_PREFIX=k8s
```

Then enter the cluster subdirectory of your kubernetes install and run

`./kube-up.sh`

This will give you good start for experiments

### Create Volume snapshots 

1. Create General Purpose SSD volume 10GB size http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html
1. Create snapshot from volume, name snapshot mysql-base http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-snapshot.html
1. Save your snapshot id in your notes.
1. Create another snapshot from same volume, name it wp-base.
1. Save this other snapshot id in your notes.

## Create Container Registry Repository

We will only be using the container repository (ECR) feature of ECS so don't worry about tasks or other steps. Just make the repo entries.

1. Go to AWS Console -> ECR, http://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html
1. Create repo for haproxy
1. Copy base url for repo from last screen ![](http://i.prntscr.com/3a5ae574ece542448886bf9a29478484.png " ")
1. For example if in screen you'll see 11112222.dkr.ecr.us-west-1.amazonaws.com/haproxy, than save 11112222.dkr.ecr.us-west-1.amazonaws.com
1. Repeat this operation to create 'nodejs', 'nginx' and 'wordpress' repos, notice base url will be always the same

## Configure Access to ECR for kubernetes master and minion nodes

1. Go to AWS Console -> Services -> AIM, you shold see 2 roles ![](http://i.prntscr.com/8e2e8043923344c4aca5397cc325cae8.png)
1. Click on first role, on next screen click Attach Policy, select "**AmazonEC2ContainerRegistryReadOnly**", add it, you should see this in the result ![](http://i.prntscr.com/b413ede861314a1ba300c8fe351fb34f.png)
1. That action allows kubernetes to grab docker images from the ECR registries you've just created.
1. Repeat steps for the second role as well.

## Build and Publish Images

1. cd to PROJECT_ROOT/docker_images
2. Run `./build-all.sh`
3. Run `ECR_REPO='11112222.dkr.ecr.us-west-1.amazonaws.com' ./push-all.sh`, where ECR_REPO is base url you've noted at 'Create Container Registry Repository' steps

After that all images will be built and pushed to AWS ECR registry, so kubernetes will be able to access them when you've create your first stack.

## To generate stack

1. cd to PROJECT_ROOT/cli
1. Run script 
```
export MYSQL_EBS_SNAPSHOT_ID=snap-313058b3
export MYSQL_EBS_SIZE=20
export WP_EBS_SNAPSHOT_ID=snap-30694eb3
export WP_EBS_SIZE=20
export ECR_REPO=11112222.dkr.ecr.us-west-1.amazonaws.com
./generate-stack-files.sh --stack-name=blog1
```
where:
 - MYSQL\_EBS\_SNAPSHOT\_ID and WP\_EBS\_SNAPSHOT\_ID - snapshot ids you noted at step 3 of 'Create Volumes Section'
 - MYSQL\_EBS\_SIZE and WP\_EBS\_SIZE - size of volume will be created from snapshot, should be >= 

(optional)

If you have volumes created from the snapshot already you can specify those and the script will skip creating volumes from snapshot.
```
export MYSQL_EBS_VOLUME_ID=vol-0b958bc69b4cd5424
export WP_EBS_VOLUME_ID=vol-042018561c24554e7
./generate-stack-files.sh --stack-name=blog1 --skip-volume-creation -f
```

Create full stack with
```
kubectl create -f blog1
```

If you had an error and have a partially created stack you can delete it so you can try again

`kubectl delete -f blog1`

Run the following to confirm cluster state and get to it.

```
$ kubectl get deployments
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
bloga-haproxy     1         1         1            1           2m
bloga-mysql       1         1         1            1           2m
bloga-nginx       1         1         1            1           2m
bloga-nodejs      1         1         1            1           2m
bloga-wordpress   1         1         1            1           2m

$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: REDACTED
    server: https://<removed>
  name: aws_k8s
contexts:
- context:
    cluster: aws_k8s
    user: aws_k8s
  name: aws_k8s
current-context: aws_k8s
kind: Config
preferences: {}
users:
- name: aws_k8s
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
    token: <removed>
- name: aws_k8s-basic-auth
  user:
    password: <removed>
    username: admin
```
In the browser go to the IP for the cluster https://\<IP\>/ui and user the username/password for the file to log in.

Click on deployments and make sure all green. Click on services to see host name of the ELB load balancer pointing to the kubernetes minions for the cluster.

Click on it to see your HAProxy landing page.