# This script combines all of the audio and video mjr file pairs in the current
# directory and converts them into mp4 files. If the script is run with the -a, -A, or -all flag
# a file with the current date and time is created inside the full-conversions  directory. Within this
# sub-directory, a directory is created for each for each audio/video pair that contains
# the final combined mp4 along with all of the intermediate versions of the audio and video
# files. Otherwise, only previously unprocessed recordings are converted and added to the 
# processed recordings directory

pathToPpRec=/Users/isaacbevers/janus-gateway/janus-pp-rec
 
main () {
	convert_names
	if [ "$1" = "-a" ] || [ "$1" = "-A" ] || [ "$1" = "-all" ]; then #Convert all 
		process_recordings "all" #process all files in conversion instance
	else
		process_recordings #Process all files that haven't been converted yet
	fi
}

convert_names () {
	for file in * ; do #for each file in the directory
		local fileExtension="${file##*.}" #gets the characters after the last . in the directory e.g. "mjr"
		local filePrefix="${file:0:4}"
		if [ "${fileExtension}" == "mjr" ] && [ "${filePrefix}" = "rec-" ]; then #if file is an mjr
			local suffix="${file##*-}" #format [audio OR video].[file extension] e.g. "video.mjr"
			local fileType="${suffix%.*}" #whether the file is audio or video e.g. "video"
			local fileID="${file%-*}" #File identifying information e.g. "rec-8486469763877175"
			local IDPrefix="${fileID#rec-*}" #The ID number of the file e.g. "8486469763877175"
			local nfo2ndLine=$(sed -n 2p "${IDPrefix}.nfo") #The second line of the .nfo file for a given prefix 
			local fileID="${nfo2ndLine##* }" #The file name input by the user e.g. "test1"
			local fileID=$(echo "${fileID}" | tr -d '[:cntrl:]')
			local newFileName="${fileID}-${fileType}.mjr"
			eval "mv ${file} ${newFileName}"
		fi
	done
}

process_recordings () {
	local processingApproach="$1"	
	local processedFiles=() #stores the names of the files that have been processed
	for file in * ; do #for each file in the directory
		local fileExtension="${file##*.}" #gets the characters after the last . in the directory e.g. "mjr"
		if [ "${fileExtension}" == "mjr" ]; then #if file is an mjr
			local fileID="${file%-*}" #The file name input by the user e.g. "test1"
			if [ "${processingApproach}" = "all" ] \
				&& [[ ! " ${processedFiles[@]} " =~ " ${fileID} " ]]; then 
				process_all_recordings "${fileID}" "${file}"
				processedFiles+=("${fileID}") #Add the current to the list of processed files
			else
				process_lazy "${fileID}" "${file}"
			fi

		fi
	done
}

process_all_recordings () {
	local fileID="$1"
	local file="$2"
	local date=$(echo "$(date)" | tr ' ' '-')
	local recordingDirectory="full-conversions/${date}/${fileID}"
	eval "mkdir -p ${recordingDirectory}"
	process_one_recording "${recordingDirectory}" "${file}" "${fileID}"
}

process_lazy () {
	local fileID="$1"
	local file="$2"
	while read line; do
		if [ "${line}" = "${fileID}" ]; then
			return
		fi
	done <processed_recordings.txt
	local recordingDirectory="processed-recordings/${fileID}"
	eval "mkdir -p ${recordingDirectory}"
	process_one_recording "${recordingDirectory}" "${file}" "${fileID}"
	echo "${fileID}" >> processed_recordings.txt
}

process_one_recording () {
	local recordingDirectory="$1"
	local file="$2"
	local fileID="$3"

        #Process audio files 
        fileAudioID="${fileID}-audio"
        eval "${pathToPpRec} ${file} ${recordingDirectory}/${fileAudioID}.opus"
        eval "ffmpeg -i ${recordingDirectory}/${fileAudioID}.opus \
        	${recordingDirectory}/${fileAudioID}.wav" #Convert audio to wav
        
        #process video files 
        fileVideoID="${fileID}-video"
        eval "${pathToPpRec} ${fileVideoID}.mjr ${recordingDirectory}/${fileVideoID}.webm"
        eval "ffmpeg -i ${recordingDirectory}/${fileVideoID}.webm \
        	${recordingDirectory}/${fileVideoID}.mp4" #convert video to mp4
        
        #combine audio and video into mp4
        eval "ffmpeg -i ${recordingDirectory}/${fileVideoID}.mp4 -i \
        	${recordingDirectory}/${fileAudioID}.wav -c:v copy -c:a aac ${recordingDirectory}/${fileID}-final.mp4"	
}
main "$@"
