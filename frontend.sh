#!/bin/bash

source common.sh

echo "Installing Nginx"
dnf install -y nginx &>>$log_file
stat_check

echo "Copying configuration files"
yes | cp -rf nginx.conf /etc/nginx/nginx.conf &>>$log_file
yes | cp -rf nodejs.conf /etc/nginx/conf.d/nodejs.conf &>>$log_file
stat_check

echo "Disabling SELinux temporarily"
setenforce 0 || echo "Warning: Unable to set SELinux to permissive mode."

if sestatus | grep -q "enabled"; then
  echo "Disabling SELinux temporarily"
  setenforce 0 || echo "Warning: Unable to set SELinux to permissive mode."
else
  echo "SELinux is already disabled."
fi


echo "Restarting & enabling Nginx"
systemctl enable nginx &>>$log_file
systemctl restart nginx &>>$log_file
stat_check

