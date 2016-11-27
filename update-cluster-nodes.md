## Update/Upgrader cluster nodes on AWS

Short plan

1. create AMI with update/upgrade executed (can be created by instantinating old AMI and run 'apt-get update && apt get-upgrade'
2. create new minion launch configuration by copy and update existing configuration with new AMI id
3. update autoscalling group with new configuration and make new nodes to run in parallel with old ones at same time
4. migrate all pods to new nodes
5. terminate old nodes

### Create new launch configuration

First need to get old launch configuration userdata, see issue description here http://stackoverflow.com/questions/35806836/kubernetes-1-2a-how-can-we-add-aws-instances-of-a-different-type-to-our-cluster/35807985#35807985

1. Go to AWS confole -> EC2 -> Launch Configurations, copy minions launch configuration name unser "Launch Configuration" column, example "k8s-minion-group-us-west-2a"
2. with aws cli get details
```
aws autoscaling describe-launch-configurations --launch-configuration-names k8s-minion-group-us-west-2a
```
3. save all text for
```
"userdata": "THIS_IS_TEXT_TO_SAVE"
```

Now we can create new configuration

1. Go to AWS confole -> EC2 -> Launch Configurations
2. select minitons launch config and click "Copy Launch Configuration" button
3. On the next page click "Edit details" at the left of "Launch Configuration details" title ![](http://image.prntscr.com/image/7cbb6ff5219d431393753947ab8864cc.png)
4. On the next screen change launch configuration name, by default it would be "Copy" added to name, but recommended to add version suffix
5. Click on "Advanded details" to unfold it
6. For UserData select "Input already base64 encoded"
7. Copy paster UserData text you've stored in section above ![](http://image.prntscr.com/image/033a928578e749e78f24a4310d38a33b.png)
8. Save launch new config.

### Update Autoscalling group
1. Click on autscalling group, in details below click "Edit"
2. Change launch config to new 
3. Increase on 50% number of instances in group ![](http://image.prntscr.com/image/f5ffe78230c84d94beade2330d4f8329.png)


## Migrate all pods to new nodes

1. go to command line and check if new nodes started with command
```
kubectl get nodes
```
2. Get old nodes by Age !{}(http://image.prntscr.com/image/c9a18ce9942b4964862e9e94bb988c0b.png)
2. Mark each of old nodes (you can check if node old by AGE) as drain (maitenance)
```
kubectl drain ip-172-20-0-32.us-west-2.compute.internal --grace-period=180 --delete-local-data --force
```
3. Wait 5 min and check pods status, they all should be in Running state (means they all was discributed to new nodes.


### Remove old nodes

1. Go to EC2->AutoScalling Groups, click on minions autoscalling group, select Instances tab below http://image.prntscr.com/image/3cfe2ea73b604a3896635750eafe7364.png
2. Click on each old with old configuration and terminate 
3. Edit autoscalling group and set initial number of instances.


