res="$(aws ec2 describe-volumes) | grep VolumeId"
echo $res
echo $url | awk -F':' '{print $2}' | awk -F'"' '{print $2}' 