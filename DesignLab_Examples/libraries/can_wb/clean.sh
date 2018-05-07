nice_files=".sch\|.sym\|.xise\|.bit\|.bat\|.vhd\|.pdf\|.ino\|.cmd_log\|.cmd\|.xst\|.prj\|.vhf\|.ut\|.h\|.cpp\|.xtcl\|keywords.txt\|.sh\|.py\|.git"

find . -type f  -print | grep  -v  "$nice_files" | while read i
do
		rm -rf $i
done
find . -type d -name iseconfig -exec rm  -rf \{\} \;

