# iOS - Concatenate or generate audio

Build in support for `.mp3`, `.m4a` and `.wav` input audio files.

### Usage

Add module:

```
var AudioMerger = require('com.composrapp.audiomerger');
```

Specify audioMergeType, audioFilesInput and audioFileOutput argumnets:

**audioMergeType**

Maybe `concatenate` or `generate`.

**audioFilesInput**

Concatenate example:

```
var concatenateAudios = [
  getResourceFile('1.mp3'),
  getResourceFile('2.mp3'),
  getResourceFile('3.mp3')
].join();
```

Generate example:

```
var generateAudios = [
  { audio: getResourceFile('140-drum.mp3'), timings: [0, 14, 28] },
  { audio: getResourceFile('140-guitar.mp3'), timings: [0, 14, 28, 42] }
];
```

```
function getResourceFile(filename) {
  return Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, filename).nativePath
}
```

`timings` are currenlty in seconds.

**audioFileOutput**

Should always end with `.m4a`.

Example: 

```
var concatenatedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'example.m4a');
```

**mergeAudio**

Concatenate audio:

```
AudioMerger.mergeAudio({
  audioMergeType: 'concatenate',
  audioFilesInput: concatenateAudios,
  audioFileOutput: concatenatedAudio
});
```

Generate audio:

```
AudioMerger.mergeAudio({
  audioMergeType: 'generate',
  audioFilesInput: generateAudios,
  audioFileOutput: generatedAudio
});
```

**eventListeners**

```
AudioMerger.addEventListener('concatenate', function() {
  Ti.API.info('Concatenated audio');
});

AudioMerger.addEventListener('generate', function() {
  Ti.API.info('Generated audio');
});

AudioMerger.addEventListener('error', function() {
  Ti.API.error('Failed to merge audio');
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
