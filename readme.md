To generate stack

1. create volumes snapshots in aws
2. run script 
cd ./cli
export MYSQL_EBS_SNAPSHOT_ID=snap-313058b3
export WP_EBS_SHAPSHOT_ID=snap-30694eb3
./generate-stack-files.sh --stack-name=blog1

3. create full stack with
kubectl create -f blog1