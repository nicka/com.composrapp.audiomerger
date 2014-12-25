# iOS Merge audio 

Build in support for .mp3, .m4a and .wav files.

**Usage:**

Add module:

```
var AudioMerger = require('com.composrapp.audiomerger');
```

Specify in and output files:

```
var originalAudios = [
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '1.mp3').nativePath,
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '2.mp3').nativePath,
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '3.mp3').nativePath
].join();
var mergedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'merged-example1.mp3');
```

Pass arguments to module:

```
AudioMerger.mergeAudio({
  audioFilesInput: originalAudios,
  audioFileOutput: mergedAudio
});
```

Listen to events:

```
AudioMerger.addEventListener('error', function() {
  Ti.API.error('Failed to merge audio');
});

AudioMerger.addEventListener('success', function() {
  Ti.API.info('Successfully merged audio');
});
```

### Development

1. Install packages with `npm install`
2. Update examples in `example/app.js`
3. Use `gulp ios` to build and test the module

### TODO

1. Cleanup eventListeners.
2. Add song tempo support
3. Add note/beat support for audio files
