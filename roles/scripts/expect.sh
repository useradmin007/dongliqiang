USER=root
PASSWD=1233
# yum install -y expect
for HOST in 192.168.1.{1..10}
do
        echo "------------------>" $HOST "-----------------------------"
/usr/bin/expect -c "
spawn ssh-copy-id $USER@$HOST;
expect {
            \"Are you sure you want to continue connecting (yes/no)?\" {
            send \"yes\r\"
            expect \"*password:\"
            send \"$PASSWD\r\"
            }
            \"*password:\" {
            send \"$PASSWD\r\"
            }
            \"Now try logging into the machine\" {
            }
        }
expect eof
"
done