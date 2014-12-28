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
var outputSound = Ti.Media.createSound();

outputSound.addEventListener('complete', function() {
  playbackBtn.title = 'Play';
});

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
// Concatenate audio
// --------------------------------------------------------
// Setup in and output files
var concatenateAudios = [
  getResourceFile('1.mp3'),
  getResourceFile('2.mp3'),
  getResourceFile('3.mp3'),
  getResourceFile('4.mp3'),
  getResourceFile('5.mp3'),
  getResourceFile('6.mp3'),
  getResourceFile('7.mp3')
].join();
var concatenatedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'concatenated-example.m4a');

// Remove old audio
if (concatenatedAudio.exists()) concatenatedAudio.deleteFile();

// --------------------------------------------------------
// Generate audio
// --------------------------------------------------------
// Setup in and output files
var generateAudios = [
  { audio: getResourceFile('140-drum.mp3'), timing: ['0, 30'] },
  { audio: getResourceFile('140-guitar.mp3'), timing: ['0, 60'] }
];
var generatedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'generated-example.m4a');

// Remove old audio
if (generatedAudio.exists()) generatedAudio.deleteFile();

function getResourceFile(filename) {
  return Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, filename).nativePath
}

// --------------------------------------------------------
// AudioMerger event listeners
// --------------------------------------------------------
AudioMerger.addEventListener('concatenate', function() {
  // Calculate generation time
  var newDate = new Date();
  var endTime =  newDate.getTime() - startTime;
  endTime = Math.abs(endTime / 1000);
  // Update label and audio
  statusLabel.text = 'Concatenated audio in ' + endTime + 's';
  statusLabel.opactity = 1;
  outputSound.setUrl(concatenatedAudio);
});

AudioMerger.addEventListener('generate', function() {
  // Calculate generation time
  var newDate = new Date();
  var endTime =  newDate.getTime() - startTime;
  endTime = Math.abs(endTime / 1000);
  // Update label and audio
  statusLabel.text = 'Generate audio in ' + endTime + 's';
  statusLabel.opactity = 1;
  outputSound.setUrl(generatedAudio);
});

AudioMerger.addEventListener('error', function() {
  statusLabel.text = 'Failed to generate audio';
  statusLabel.opactity = 1;
});

// --------------------------------------------------------
// Open window and concatenate audio
// --------------------------------------------------------
win.addEventListener('open', function() {
  // Get start time
  date = new Date();
  startTime = date.getTime();
  
 //  // Concatenate audio
	// AudioMerger.mergeAudio({
 //    audioMergeType: 'concatenate',
	//   audioFilesInput: concatenateAudios,
	//   audioFileOutput: concatenatedAudio
	// });

  // Generate audio
  AudioMerger.mergeAudio({
    audioMergeType: 'generate',
    audioFilesInput: generateAudios,
    audioFileOutput: generatedAudio
  });
});

win.open();
