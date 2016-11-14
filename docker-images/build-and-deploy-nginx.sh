#!/bin/bash
set -e

for i in "$@"
do
case $i in
    --stack-name=*)
    STACK_NAME=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
    ;;
    --version=*)
    VERSION=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
    ;;
    *)
    echo "Unknown option ${i}"
    ;;
esac
done

echo "Updating nginx $STACK_NAME, builded version ${VERSION}"
docker build -t nginx:${VERSION} ./nginx

#kubectl set image deployment/${STACK_NAME}-nginx ${STACK_NAME}-nginx=nginx
kubectl set image deployment/${STACK_NAME}-nginx ${STACK_NAME}-nginx=nginx:${VERSION}