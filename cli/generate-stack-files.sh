#!/bin/bash


################################################################
## FUNCTIONS
################################################################
# params snapshot-id, size
create_volume_from_snapshot() {
    local snapshot_id=$1
    local volume_size=$2
    local name=$3
    CREATE_SNAPSHOT_RESPONSE=$(aws ec2 create-volume --size ${volume_size} --volume-type gp2 --availability-zone us-east-1d --snapshot-id=${snapshot_id})
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
SKIP_VOLUME_CREATION=0
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
    --skip-volume-creation)
    SKIP_VOLUME_CREATION=1
    ;;
    *)
    echo "Unknown option ${i}"
    ;;
esac
done

################################################################
## INTIALIZAITION
################################################################

SCRIPT_PATH="${BASH_SOURCE[0]}";
if ([ -h "${SCRIPT_PATH}" ]) then
  while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null


if [ -d "$STACK_NAME" ]; then
   if [ $FORCE == 0 ]; then
      echo "Directory $STACK_NAME already exists"
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

if [ $SKIP_VOLUME_CREATION == 0 ]; then
    "Echo create volumes from shapshots"
    create_volume_from_snapshot $MYSQL_EBS_SNAPSHOT_ID "${MYSQL_EBS_SIZE}" "${STACK_NAME}-mysql"
    MYSQL_EBS_VOLUME_ID=$create_volume_from_snapshot_RESULT 

    create_volume_from_snapshot $WP_EBS_SHAPSHOT_ID "${WP_EBS_SIZE}" "${STACK_NAME}-wp"
    WP_EBS_VOLUME_ID=$create_volume_from_snapshot_RESULT
else
    "Skiping volume creation becase --skip-volume-creation flag"
fi

echo "Using volumes for mysql ${MYSQL_EBS_VOLUME_ID} and wp ${WP_EBS_VOLUME_ID}"

#echo "Copying files from template ${arr_files}"
arr_files=( $(ls $SCRIPT_PATH/templates/kubernetes) )
for i in ${arr_files[@]}
do 
    echo "Generating ./$STACK_NAME/$i"
    sed -e 's/%ECR_REPO%/'${ECR_REPO}'/g' -e 's/%MYSQL_EBS_VOLUME_ID%/'${MYSQL_EBS_VOLUME_ID}'/g' -e 's/%WP_EBS_VOLUME_ID%/'${WP_EBS_VOLUME_ID}'/g' -e 's/%STACK_NAME%/'${STACK_NAME}'/g' $SCRIPT_PATH/templates/kubernetes/$i > ./$STACK_NAME/$i
done


