
echo "last line" >> processed_recordings.txt

while read line; do
	echo "${line}"
done <processed_recordings.txt
