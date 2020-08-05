//BG Controls Dynamic
var x = 0;
function newBG() {
    var urlArray = ["https://www.youtube.com/embed/zofBinqC2F4?autoplay=1&mute=1", 
                    "https://www.youtube.com/embed/IvJQTWGP5Fg?autoplay=1&mute=1",
                    "https://www.youtube.com/embed/gcSE2jvc1Yo?autoplay=1&mute=1"]
    x++;
    document.getElementById('bg').src = urlArray[x%3];
}

//Dragging 
$( function() {
    $( "#surveyWindow" ).draggable();
});

//VIDEO
var video = document.querySelector('video');

function captureCamera(callback) {
    navigator.mediaDevices.getUserMedia({ audio: true, video: true }).then(function(camera) {
        callback(camera);
    }).catch(function(error) {
        alert('Unable to capture your camera. Please check console logs.');
        console.error(error);
    });
}

function stopRecordingCallback() {
    video.src = video.srcObject = null;
    video.muted = false;
    video.volume = 1;
    video.src = URL.createObjectURL(recorder.getBlob());
    
    recorder.camera.stop();
    recorder.destroy();
    recorder = null;
}

var recorder; // globally accessible

document.getElementById('btn-start-recording').onclick = function() {
    //change
    this.disabled = true;
    captureCamera(function(camera) {
        video.muted = true;
        video.volume = 0;
        video.srcObject = camera;

        recorder = RecordRTC(camera, {
            type: 'video'
        });

        recorder.startRecording();

        // release camera on stopRecording
        recorder.camera = camera;

        document.getElementById('btn-stop-recording').disabled = false;
    });
};

    document.getElementById('btn-stop-recording').onclick = function() {
    this.disabled = true;
    recorder.stopRecording(stopRecordingCallback);
};

