


## Setup Kubernetes on AWS

Note: pick aws region and use it always the same

1. Follow instructions on http://kubernetes.io/docs/getting-started-guides/aws/
2. Note: for test not production, to have more light weight config override this vairalbes from example
```bash
export NUM_NODES=2
export MASTER_SIZE=t2.medium
export NODE_SIZE=t2.medium
```
This will give you good start for experiemnts

### Create Volume snapshots 

1. create General Purpose SSD volume 10GB size http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html
1. create snapshot from volume, name snapshot mysql-base http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-snapshot.html
1. save snapshot id in your notes
1. create snapshot from same volume, name it wp-base
1. save snapshot id in your notes

## Create Container Registry Repository

1. Go to AWS Console -> ECR, http://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html
1. Create repo for haproxy
1. copy base url for repo from last screen http://i.prntscr.com/3a5ae574ece542448886bf9a29478484.png
1. fore example if in screen you'll see 11112222.dkr.ecr.us-west-1.amazonaws.com/haproxy, than save 11112222.dkr.ecr.us-west-1.amazonaws.com
1. repeat this operation to create 'nodejs', 'nginx' and 'wordpress' repos, notice base url will be always the same

## Configure access to ECR for kubernetes master and minion nodes

1. Go to AWS Console -> Services -> AIM, you shold see 2 roles http://i.prntscr.com/8e2e8043923344c4aca5397cc325cae8.png
1. click on first role, on next screen click Attach Policy, select "AmazonEC2ContainerRegistryReadOnly", add it, you should see this in result http://i.prntscr.com/b413ede861314a1ba300c8fe351fb34f.png
1. that action allows kubernetes to upload images from ECR resitries you've just created
1. repeat steps for second role as well

## build and publish images

1. cd to project_root/docker_images
2. run ./build-all.sh
3. run 
``` bash ECR_REPO='11112222.dkr.ecr.us-west-1.amazonaws.com' ./push-all.sh ```, where ECR_REPO is base url you've noted at 'Create Container Registry Repository' steps

after that all images will be builded and pushed to AWS ECR registry, so kubernetes will be able to upload them when you've create your first stack.

## To generate stack

1. cd to PROJECT_ROOT/cli
1. run script 
```bash
export MYSQL_EBS_SNAPSHOT_ID=snap-313058b3
export MYSQL_EBS_SIZE=20
export WP_EBS_SHAPSHOT_ID=snap-30694eb3
export WP_EBS_SIZE=20
export ECR_REPO=
./generate-stack-files.sh --stack-name=blog1
```
where:
 - MYSQL_EBS_SNAPSHOT_ID - snapshot id you nodet at step 3 of 'Create Volumes Section'
 - MYSQL_EBS_SIZE - size of volume will be created from snapshot, should be >= 
3. create full stack with
```bash
kubectl create -f blog1
```