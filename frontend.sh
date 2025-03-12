#!/bin/bash
#
## Ensure script runs as root
#if [ "$(id -u)" -ne 0 ]; then
#    echo "Please run as root"
#    exit 1
#fi
#
#echo "Starting setup..."
#
## Install MongoDB
#echo "Installing MongoDB..."
#yum install dnf -y
##curl -s https://raw.githubusercontent.com/ChaitanyaChandra/DevOps/main/2.ANSIBLE/roles/mongodb/files/mongo.repo > /etc/yum.repos.d/mongodb-org-6.0.repo
#cp mongodb-org-6.0.repo /etc/yum.repos.d/mongodb-org-6.0.repo
#dnf --disablerepo=AppStream install -y mongodb-org
#sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
#systemctl enable --now mongod
#
## Add user "spec"
#echo "Creating user 'spec'..."
#adduser spec
#
## Install Node.js
#echo "Installing Node.js..."
#curl -sL https://rpm.nodesource.com/setup_16.x | bash -
#yum install nodejs -y
#
## Install Git
#echo "Installing Git..."
#yum install git -y
#
## Clone application repo
#echo "Cloning application repository..."
#su - spec -c "git clone https://github.com/ChaitanyaChandra/app.git /home/spec/app"
#
## Change directory to app and execute package.sh
#echo "Executing package.sh..."
#su - spec -c "cd /home/spec/app && bash package.sh"
#
## Configure MongoDB environment variables
#db_user="chaitu"
#db_pass="123Chaitu"
#
#echo "Setting up environment variables..."
#echo Environment="MONGO_ENDPOINT=mongodb+srv://$db_user:$db_pass@cluster0.wdtudby.mongodb.net/login-app-db?retryWrites=true&w=majority" >> /home/spec/app/files/spec.service
#
## Move service file and start application service
#echo "Setting up application service..."
#cp /home/spec/app/files/spec.service /etc/systemd/system/
#systemctl daemon-reload
#systemctl enable --now spec
#
## Install Nginx
#echo "Installing Nginx..."
#yum install epel-release -y
#yum install nginx -y
#
## Configure Nginx
#echo "Configuring Nginx..."
#yes | cp -rf /home/spec/app/files/nginx.conf /etc/nginx/nginx.conf
#yes | cp -rf /home/spec/app/files/nodejs.conf /etc/nginx/conf.d/nodejs.conf
#setenforce 0
#systemctl enable --now nginx
#
## Start Node.js application
#echo "Starting Node.js application..."
#su - spec -c "cd /home/spec/app && nohup node index.js > node.logs 2>&1 &"
#
## Verify process
#ps -ef | grep "index.js" > /home/spec/app/run.log
#
#echo "Setup completed successfully!"



# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

LOG_FILE="/var/log/setup_script.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting setup..."

# Install dependencies
echo "Installing required dependencies..."
yum install -y dnf curl git epel-release nginx

# Install MongoDB
echo "Installing MongoDB..."
cp mongodb-org-6.0.repo /etc/yum.repos.d/mongodb-org-6.0.repo
dnf --disablerepo=AppStream install -y mongodb-org

# Configure MongoDB
echo "Configuring MongoDB..."
sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
systemctl enable --now mongod
sleep 5

# Create MongoDB user
echo "Creating MongoDB user..."
mongo <<EOF
use admin
db.createUser({
  user: "chaitu",
  pwd: "123Chaitu",
  roles: [{ role: "readWrite", db: "login-app-db" }]
})
EOF
systemctl restart mongod

# Add user "spec"
echo "Creating system user 'spec'..."
id -u spec &>/dev/null || adduser spec

# Install Node.js
echo "Installing Node.js..."
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs

# Clone application repo
echo "Cloning application repository..."
su - spec -c "git clone https://github.com/ChaitanyaChandra/app.git /home/spec/app"

# Execute package.sh
echo "Executing package.sh..."
su - spec -c "cd /home/spec/app && bash package.sh"

# Configure MongoDB environment variables
DB_USER="chaitu"
DB_PASS="123Chaitu"

echo "Setting up environment variables..."
echo "Environment='MONGO_ENDPOINT=mongodb://$DB_USER:$DB_PASS@localhost:27017/login-app-db'" >> /home/spec/app/files/spec.service

# Move service file and start application service
echo "Setting up application service..."
cp /home/spec/app/files/spec.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now spec

# Configure Nginx
echo "Configuring Nginx..."
yes | cp -rf /home/spec/app/files/nginx.conf /etc/nginx/nginx.conf
yes | cp -rf /home/spec/app/files/nodejs.conf /etc/nginx/conf.d/nodejs.conf
setenforce 0
systemctl enable --now nginx

# Start Node.js application
echo "Starting Node.js application..."
su - spec -c "cd /home/spec/app && nohup node index.js > node.logs 2>&1 &"

# Verify running processes
echo "Verifying running processes..."
ps -ef | grep "index.js" > /home/spec/app/run.log

echo "Setup completed successfully!"
