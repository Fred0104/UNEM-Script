#!/bin/sh
#--------------------------------------------
cd `dirname $0`
./UNEM_update.sh
case $? in
0)
	echo "���³ɹ�"
1)
	echo "����ʧ��"
	;;
2)
	echo "���ڸ����У������ظ�����"
	;;
3)
	echo "�Ѿ������°汾"
	/opt/storage/UnblockNeteaseMusic/unblockmusic.sh restart
	;;
*)
	echo "��������"
	#exit 0
	;;
esac