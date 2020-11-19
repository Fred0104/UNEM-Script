#!/bin/sh
#--------------------------------------------
cd `dirname $0`
./UNEM_update.sh
case $? in
0)
	echo "更新成功"
1)
	echo "更新失败"
	;;
2)
	echo "正在更新中，请勿重复运行"
	;;
3)
	echo "已经是最新版本"
	/opt/storage/UnblockNeteaseMusic/unblockmusic.sh restart
	;;
*)
	echo "出问题了"
	#exit 0
	;;
esac