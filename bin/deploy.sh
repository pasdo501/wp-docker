#!/usr/bin/env bash
# INCOMPLETE
# Script to deploy a wordpress theme to a server.
# Currently based on just one theme, with the standard WP folder layout,
# sitting at /var/www/html.

if [ $# != 3 ] 
then
    echo -e 'Incorrect number of arguments\nUsage: deploy <username> <address> <theme name>'
    exit 1
fi

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
tar -zcf $3.tar.gz $3;
mv $3.tar.gz $start_dir/$temp_dir/;

# Get the uploads
echo 'Getting uploads ...';
cd ../uploads;
tar -zcf uploads.tar.gz *;
mv uploads.tar.gz $start_dir/$temp_dir/;

cd $start_dir/$temp_dir;
echo 'Transferring files to server ...';
scp * $1@$2:/var/www;

echo 'Doing stuff with the files ...';
# TODO: Continue here
ssh -t $1@$2 'cd /var/www; \
touch i_was_here';

echo 'Cleaning up ...';
rm -rf $start_dir/$temp_dir;

echo 'Done';