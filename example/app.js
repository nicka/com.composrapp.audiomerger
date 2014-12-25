// This is a test harness for your module
// You should do something interesting in this harness
// to test out the module and to provide instructions
// to users on how to use it by example.

// --------------------------------------------------------
// Initialize
// --------------------------------------------------------
var AudioMerger = require('com.composrapp.audiomerger');
Ti.API.info("module is => " + AudioMerger);

var date;
var startTime;

// Setup in and output files
var originalAudios = [
	Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '1.mp3').nativePath,
	Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '2.mp3').nativePath,
	Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '3.mp3').nativePath,
	Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '4.mp3').nativePath,
	Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '5.mp3').nativePath,
	Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '6.mp3').nativePath,
	Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '7.mp3').nativePath
].join();
var mergedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'merged-example1.mp3');

// Create sound
var outputSound = Ti.Media.createSound();

// Remove old merged audio
if (mergedAudio.exists()) mergedAudio.deleteFile();

// --------------------------------------------------------
// Create window
// --------------------------------------------------------

var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var statusLabel = Ti.UI.createLabel({
  top: '30dp',
  text: '',
  color: '#2ecc71',
  opactity: 0
});

var playbackBtn = Ti.UI.createButton({
  top: '240dp',
  width: Ti.UI.FILL,
  title: 'Play'
});

win.add(statusLabel);
win.add(playbackBtn);

// --------------------------------------------------------
// Add button event listeners
// --------------------------------------------------------
playbackBtn.addEventListener('click', function() {
  if (outputSound.playing) {
    outputSound.pause();
    playbackBtn.title = 'Play';
  } else {
    outputSound.play();
    playbackBtn.title = 'Pause';
  }
});

// --------------------------------------------------------
// Merge audio event listeners
// --------------------------------------------------------
AudioMerger.addEventListener('success', function() {
  // Calculate generation time
  var newDate = new Date();
  var endTime =  newDate.getTime() - startTime;
  endTime = Math.abs(endTime / 1000);
  // Update label and audio
  statusLabel.text = 'Successfully merged audio in ' + endTime + 's';
  statusLabel.opactity = 1;
  outputSound.setUrl(mergedAudio);
});

AudioMerger.addEventListener('error', function() {
  statusLabel.text = 'Failed to merge audio';
  statusLabel.opactity = 1;
});

// --------------------------------------------------------
// Open window and merge audio
// --------------------------------------------------------
win.addEventListener('open', function() {
  // Get start time
  date = new Date();
  startTime = date.getTime();
  // Merge audio
	AudioMerger.mergeAudio({
	  audioFilesInput: originalAudios,
	  audioFileOutput: mergedAudio
	});
});

win.open();
