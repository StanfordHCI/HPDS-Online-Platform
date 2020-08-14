# This script combines all of the audio and video mjr file pairs in the current
# directory and converts them into mp4 files. Every time the script is run, a file with
# the current date and time is created inside the processed-files directory. Within this
# sub-directory, a directory is created for each for each audio/video pair that contains
# the final combined mp4 along with all of the intermediate versions of the audio and video
# files. 

pathToPpRec=/Users/isaacbevers/janus-gateway/janus-pp-rec 
processedFiles=() #stores the names of the files that have been processed
snapshotDirectory="${$(date)// /$'-'}"
conversionInstance="processed-recordings/${snapshotDirectory}" #the destination of the final mp4 
eval "mkdir ${conversionInstance}" 
for file in * ; do #for each file in the directory
	fileExtension="${file##*.}" #gets the characters after the last . in the directory
	if [ "${fileExtension}" == mjr ]; then #if file is an mjr
		suffix="${file##*-}" #format [audio OR video].[file extension] 
		fileType="${suffix%.*}" #whether the file is audio or video
		fileID="${file%-*}" #File identifying information
		if [[ ! " ${processedFiles[@]} " =~ " ${fileID} " ]]; then #if file hasn't been processed yet
			recordingDirectory="${conversionInstance}/${fileID}"
			eval "mkdir ${recordingDirectory}"

		        #Process audio files 
			audioFileWithoutExtension="${fileID}-audio"
			eval "${pathToPpRec} ${file} ${recordingDirectory}/${audioFileWithoutExtension}.opus"
			eval "ffmpeg -i ${recordingDirectory}/${audioFileWithoutExtension}.opus \
				${recordingDirectory}/${audioFileWithoutExtension}.wav" #Convert audio to wav
	       	
	       		#process video files 
	       		videoFileWithoutExtension="${fileID}-video"
	       		eval "${pathToPpRec} ${videoFileWithoutExtension}.mjr ${recordingDirectory}/${videoFileWithoutExtension}.webm"
			eval "ffmpeg -i ${recordingDirectory}/${videoFileWithoutExtension}.webm \
				${recordingDirectory}/${videoFileWithoutExtension}.mp4" #convert video to mp4

			#combine audio and video into mp4
			eval "ffmpeg -i ${recordingDirectory}/${videoFileWithoutExtension}.mp4 -i \
				${recordingDirectory}/${audioFileWithoutExtension}.wav -c:v copy -c:a aac ${recordingDirectory}/${fileID}-final.mp4"	
			processedFiles+=("${fileID}") #Add the current to the list of processed files
		fi
	fi
done
