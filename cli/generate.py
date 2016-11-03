import boto
ec2 = boto.connect_ec2()


volume = ec2.create_volume(5, 'us-west-1a', 'snap-22caaea1')

print volume