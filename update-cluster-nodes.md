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
4. go to command line and check if new nodes started with 
```
kubectl get nodes
```
