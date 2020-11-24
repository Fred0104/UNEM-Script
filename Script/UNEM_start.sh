#!/bin/sh
#--------------------------------------------
cd `dirname $0`
sleep 1s
./UNEM_update.sh
s1=$?
echo "return code:$s1"
case $s1 in
0)
	echo "更新成功"
	;;
1)
	echo "更新失败"
	;;
2)
	echo "正在更新中，请勿重复运行"
	;;
3)
	echo "已经是最新版本"
	;;
*)
	echo "出问题了"
	#exit 0
	;;
esac