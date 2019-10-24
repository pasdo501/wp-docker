#!/usr/bin/env bash

# Script to deploy a wordpress theme to a server.
# Currently based on just one theme, with the standard WP folder layout,
# sitting at /var/www/html.
# Assumes web user is www-data

# LIVE_URL & DEV_URL variables need to be set in .env one directory up from
# the script's location.

if [ $# != 3 ] 
then
    echo -e 'Incorrect number of arguments\nUsage: deploy <username> <address> <theme name>'
    exit 1
fi

DEV_URL=$(grep -oP '^DEV_URL=\K.*' .env)
LIVE_URL=$(grep -oP '^LIVE_URL=\K.*' .env)

[ -z $DEV_URL ] && { echo "DEV_URL not set in .env, exiting ..."; exit 1; }
[ -z $LIVE_URL ] && { echo "LIVE_URL not set in .env, exiting ..."; exit 1; }
[ -f data/dump.sql ] || { echo "Database dump doesn't exist, please run export-db.sh first! Exiting ..."; exit 1; }

temp_dir=DEPLOY_TEMP;
cd $(dirname $0)/..;
start_dir=$(pwd);
cd $start_dir;
mkdir $temp_dir;

# Get the plugins
echo 'Getting plugins ...';
cd app/wp-content/plugins;
tar -zcf plugins.tar.gz *;
mv plugins.tar.gz $start_dir/$temp_dir/;

# Get the theme
echo 'Getting theme ...';
cd ../themes;
[ -d $3 ] || { echo "$3 theme doesn't exist, exiting ..."; rm -rf $start_dir/$temp_dir; exit 1; }
tar -zcf $3.tar.gz $3;
mv $3.tar.gz $start_dir/$temp_dir/;

# Get the uploads
echo 'Getting uploads ...';
cd ../uploads;
tar -zcf uploads.tar.gz *;
mv uploads.tar.gz $start_dir/$temp_dir/;

echo 'Getting the database dump ...'
cp $start_dir/data/dump.sql $start_dir/$temp_dir

cd $start_dir;
echo 'Transferring files to server ...';
scp -r $temp_dir $1@$2:~;

config_parse() {
    grep -xoP "define\(\s?['\`\"]$1['\`\"][^'\`\"]*['\`\"]\K([^'\`\"]+)['\`\"]\s?\);" wp-config.php |\
    sed -r "s/['\`\\\"]/'/g" | cut -d "'" -f 1
}

ssh -t $1@$2 "$(declare -f config_parse); \
cd /var/www/html; \
DB_USER=\$(config_parse DB_USER); \
DB_NAME=\$(config_parse DB_NAME); \
DB_PASSWORD=\$(config_parse DB_PASSWORD); \
echo 'Importing the DB ...'; \
mysql -u \$DB_USER -p\$DB_PASSWORD \$DB_NAME < ~/$temp_dir/dump.sql; \
echo 'Updating the DB ...'; \
su www-data -c 'wp search-replace $DEV_URL $LIVE_URL --skip-columns=guid' -s /bin/bash; \
echo 'Unpacking the plugins ...'; \
cd wp-content/plugins; \
mv ~/$temp_dir/plugins.tar.gz .; \
tar -zxf plugins.tar.gz; \
echo 'Unpacking uploads ...'; \
cd ../uploads; \
mv ~/$temp_dir/uploads.tar.gz .; \
tar -zxf uploads.tar.gz; \
echo 'Unpacking the theme ...'; \
cd ../themes; \
mv ~/$temp_dir/$3.tar.gz .; \
tar -zxf $3.tar.gz; \
echo 'Cleaning up on server ...'; \
cd /var/www; \
chown -R www-data:www-data html; \
chown \$USER:\$USER html/wp-config.php; \
rm -rf ~/$temp_dir;"

echo 'Cleaning up temporary files ...';
rm -rf $start_dir/$temp_dir;

echo 'Done!';