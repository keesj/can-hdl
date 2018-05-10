#hack?
#list entities , "parse vhdl to find dependencies"
(
find hdl -name "*.vhd" | while read i
do
	ent=`grep "^entity" $i | sed "s,entity \(.*\) is,\1,g"`
	if [ -z "$ent" ]
	then
		echo "did not find entiry in file $i $ent"
		exit 2
	fi 
	deps=`grep "entity" $i | grep port | sed  "s,.*entity work.\(.*\) port.*,\1,g" | uniq`
	line="$ent.o: $i"
	for f in $deps
	do
		line="$line $f.o"
	done
	echo $line
done
) | tee deps.mk
