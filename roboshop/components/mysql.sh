#!/bin/bash

source components/common.sh
COMPONENT=mysql

read -p 'Enter MySQL Password you wish to configure:' MYSQL_PWD


echo -n  "Configuring $COMPONENT repo"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/$COMPONENT/main/$COMPONENT.repo &>> $LOGFILE 
stat $?

echo -n "Installing $COMPONENT:"
yum install mysql-community-server -y &>> $LOGFILE 
stat $? 

echo -n "Starting $COMPONENT service: "
systemctl enable mysqld && systemctl start mysqld
stat $?

echo -n "Changing the default password:"
DEF_ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk -F ' ' '{print $NF}')


echo show databases | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} &>> $LOGFILE 
if [ $? -ne 0 ]
then
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PWD}';" > /tmp/root-pass-sql
  DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
  cat /tmp/root-pass-sql  | mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" &>> $LOGFILE 
  stat $? 
fi

echo -e "Removing Password Validate Plugin : "
echo "show plugins" |  mysql -uroot -p${MYSQL_PWD} | grep validate_password &>> $LOGFILE 
if [ $? -eq 0 ]; then
  echo " uninstall plugin validate_password;" | mysql -uroot -p${MYSQL_PWD}   &>> $LOGFILE 
  stat $? 
fi

echo -n "Downloading the $COMPONENT Schema:"
cd /tmp 
curl -s -L -o /tmp/mysql.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
unzip -o $COMPONENT.zip &>> $LOGFILE
stat $?

cd $COMPONENT-main &>>$LOG

echo -n "Injecting the $COMPONENT Schema:"
mysql -uroot -p${MYSQL_PWD} <shipping.sql &>> $LOGFILE 
stat $? 

echo -e "\e[32m __________ $COMPONENT Installation Completed _________ \e[0m"


