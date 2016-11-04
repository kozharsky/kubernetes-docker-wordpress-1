

for i in "$@"
do
case $i in
    --volume-wp=*)
    VOLUME_ID_WP=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
    ;;
    --stack-name=*)
    STACK_NAME=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
    echo "Unknown option ${i}"
    ;;
esac
done

if [ -d "$STACK_NAME" ]; then
   echo "Dicretory $STACK_NAME already exists"
   exit 1
fi

mkdir $STACK_NAME

echo $VOLUME_ID_WP
echo $STACK_NAME
sed 's/%VOLUME_ID_WP%/'${VOLUME_ID_WP}'/g' templates/wordpress.yml.tpl > $STACK_NAME/wordpress.yml
