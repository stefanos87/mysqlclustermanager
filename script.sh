#!/bin/bash
echo "Start mysql"
/etc/init.d/mysql start -D FOREGROUND

sleep 120

# mysql -uroot -proot \
#   -e "RESET MASTER;" \
#   -e "START GROUP_REPLICATION;" \
#   -e "SELECT * FROM performance_schema.replication_group_members;" 



for N in 1 2 3
do mysql -uroot -proot -h node$N \
  -e "SET SQL_LOG_BIN=0;" \
  -e "create user repl;" \
  -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'root';" \
  -e "GRANT ALL ON *.* TO 'root'@'%.%.%.%' identified by 'root';" \
  -e "GRANT ALL ON *.* TO 'root'@'localhost' identified by 'root';" \
  -e "GRANT ALL ON *.* TO 'repl'@'%.%.%.%' identified by 'root';" \
  -e "GRANT ALL ON *.* TO 'repl'@'localhost' identified by 'root';" \
  -e "flush privileges;" \
  -e "SET SQL_LOG_BIN=1;" \
  -e "change master to master_user='repl', master_password='root' for channel 'group_replication_recovery';" 
sleep 20
done



mysql -uroot -proot -h node1 \
  -e "SET GLOBAL group_replication_bootstrap_group=ON;" \
  -e "START GROUP_REPLICATION;" \
  -e "SET GLOBAL group_replication_bootstrap_group=OFF;" \
  -e "SELECT * FROM performance_schema.replication_group_members;" 
   
sleep 20


for N in 2 3
do mysql -uroot -proot -h node$N \
  -e "RESET MASTER;" \
  -e "START GROUP_REPLICATION;" \
  -e "SELECT * FROM performance_schema.replication_group_members;" 
sleep 10
done


mysql -uroot -proot -h node1 \
  -e "SELECT * FROM performance_schema.replication_group_members;" 

echo "creo database e inserisco un valore nella tabella test"
mysql -uroot -proot -h node1 \
  -e "create database TEST; use TEST; CREATE TABLE t1 (id INT NOT NULL PRIMARY KEY) ENGINE=InnoDB; show tables;" \
  -e "INSERT INTO TEST.t1 VALUES(1);"
sleep 5
echo "select valore da tutti e 3 i nodi"

for N in 1 2 3
do mysql -uroot -proot -h node$N \
  -e "SHOW VARIABLES WHERE Variable_name = 'hostname';" \
  -e "SELECT * FROM TEST.t1;"
done

