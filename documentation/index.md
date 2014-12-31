# iOS - Concatenate or generate audio

Build in support for `.mp3`, `.m4a` and `.wav` input audio files.

### Usage

Add module:

```
var AudioMerger = require('com.composrapp.audiomerger');
```

Specify audioMergeType, audioFilesInput and audioFileOutput argumnets:

**audioMergeType**

Use `concatenate` or `generate`.

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
  { audio: getResourceFile('140-drum.mp3'), timings: [0, 14000, 28000] },
  { audio: getResourceFile('140-guitar.mp3'), timings: [0, 14000, 28000, 42000] }
];
```

```
function getResourceFile(filename) {
  return Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, filename).nativePath
}
```

`timings` are in milliseconds.

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

## Examples

Concatenate example:

```
var AudioMerger = require('com.composrapp.audiomerger');

var concatenateAudios = [
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '1.mp3').nativePath,
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '2.mp3').nativePath,
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '3.mp3').nativePath
].join();
var concatenatedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'example.m4a');

AudioMerger.mergeAudio({
  audioMergeType: 'concatenate',
  audioFilesInput: concatenateAudios,
  audioFileOutput: concatenatedAudio
});

AudioMerger.addEventListener('concatenate', function() {
  Ti.API.info('Concatenated audio');
});
```

Generate example:

```
var AudioMerger = require('com.composrapp.audiomerger');

var generateAudios = [
  { 
    audio: Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, '140-drum.mp3').nativePath,
    timings: [0, 14, 28]
  },
  { 
    audio: Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, '140-guitar.mp3').nativePath,
    timings: [0, 14, 28, 42]
  }
];
var generatedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'example.m4a');

AudioMerger.mergeAudio({
  audioMergeType: 'generate',
  audioFilesInput: generateAudios,
  audioFileOutput: generatedAudio
});

AudioMerger.addEventListener('generate', function() {
  Ti.API.info('Concatenated audio');
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

## License

<pre>
Copyright 2013-2014 Nick den Engelsman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</pre>
