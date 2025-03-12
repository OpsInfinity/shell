#!/bin/bash

source common.sh

echo Installing Nginx
dnf install nginx -y &>>$log_file
stat_check


echo copy conf files
# shellcheck disable=SC2216
yes | cp -rf nginx.conf /etc/nginx/nginx.conf &>>$log_file
# shellcheck disable=SC2216
yes | cp -rf nodejs.conf /etc/nginx/conf.d/nodejs.conf &>>$log_file
setenforce 0
stat_check

echo "restart & enable nginx"
systemctl enable nginx
systemctl restart nginx
stat_check

