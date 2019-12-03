#!/bin/bash
key_file='/root/.ssh/id_rsa.pub'
file_path='/opt/scripts/file'
####################### 判断秘钥文件是否存在 ######################
[ -f $key_file ] || ssh-keygen -t rsa -C '563980025@qq.com' > /dev/null 2>&1

if [ -n /usr/bin/expect ];then
	 yum install -y expect
	   if [ $? -ne 0 ];then
		echo "expect install bad"
		exit $?
	   fi
fi

####################### 批量分发秘钥 #########################
cat $file_path/serverlist.list |while read line
do
/usr/bin/expect  << EOF  > /dev/null 2>&1	
spawn  ssh-copy-id -i $key_file  root@${line}
expect {
        "yes/no"        {send "yes\r";exp_continue}
        "*password"     {send "111111\r"}
}
expect eof
EOF

####################### 显示分发状态 ##########################
if [ $? -eq 0 ]
        then
echo "${ip} 秘钥分发成功"
#echo 0
        else
echo "${ip} 秘钥分发失败"
#echo 1
fi
done

