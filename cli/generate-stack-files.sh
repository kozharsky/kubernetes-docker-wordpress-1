#!/bin/bash

################################################################
## FUNCTIONS
################################################################
# params snapshot-id, size
create_volume_from_snapshot() {
    local snapshot_id=$1
    local volume_size=$2
    local name=$3
    CREATE_SNAPSHOT_RESPONSE=$(aws ec2 create-volume --size ${volume_size} --volume-type gp2 --availability-zone us-west-1a --snapshot-id=${snapshot_id})
    echo "response ${CREATE_SNAPSHOT_RESPONSE}"
    checkme='\"VolumeId\": "(vol-[a-z0-9A-Z]*)"'
    if [[ $CREATE_SNAPSHOT_RESPONSE =~ $checkme ]]; then
      local VOLUME_ID=${BASH_REMATCH[1]}
      echo "Create Volume with id='${VOLUME_ID}'"
      create_volume_from_snapshot_RESULT=$VOLUME_ID
      CREATE_TAGS=$(aws ec2 create-tags --resources ${VOLUME_ID} --tags Key=Name,Value=${name})
    else
      echo "Error during create volume operation for response"
      echo $resonse
      exit 1
    fi
}

################################################################
## PARAMS PARSE
################################################################

FORCE=0

for i in "$@"
do
case $i in
    --volume-wp=*)
    VOLUME_ID_WP=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
    ;;
    --stack-name=*)
    STACK_NAME=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
    ;;
    -f)
    FORCE=1
    ;;
    *)
    echo "Unknown option ${i}"
    ;;
esac
done

################################################################
## INTIALIZAITION
################################################################

#MYSQL_EBS_SNAPSHOT_ID=snap-313058b3
#WP_EBS_SHAPSHOT_ID=snap-30694eb3

if [ -d "$STACK_NAME" ]; then
   if [ $FORCE == 0 ]; then
      echo "Dicretory $STACK_NAME already exists"
      exit 1
   else
      echo "Removing $STACK_NAME directory as long -f parameter present"
      mkdir -p ./backup
      NOW=$(date +"%Y-%m-%d-%H-%M")
      mv $STACK_NAME ./backup/$NOW-$STACK_NAME
   fi
fi

mkdir $STACK_NAME

################################################################
## CREATE WP AND MYSQL VOLUMES FROM SNAPTHOTS
################################################################

create_volume_from_snapshot $MYSQL_EBS_SNAPSHOT_ID 5 "${STACK_NAME}-mysql"
MYSQL_EBS_VOLUME_ID=$create_volume_from_snapshot_RESULT 

create_volume_from_snapshot $WP_EBS_SHAPSHOT_ID 2 "${STACK_NAME}-wp"
WP_EBS_VOLUME_ID=$create_volume_from_snapshot_RESULT



echo "Created volumes for mysql ${MYSQL_EBS_VOLUME_ID} and wp ${WP_EBS_VOLUME_ID}"


arr_files=( $(ls templates/kubernetes) )
for i in ${arr_files[@]}
do 
    sed -e 's/%MYSQL_EBS_VOLUME_ID%/'${MYSQL_EBS_VOLUME_ID}'/g' -e 's/%WP_EBS_VOLUME_ID%/'${WP_EBS_VOLUME_ID}'/g' -e 's/%STACK_NAME%/'${STACK_NAME}'/g' ./templates/kubernetes/$i > ./$STACK_NAME/$i
done


