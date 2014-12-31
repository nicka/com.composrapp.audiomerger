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
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '1.mp3').nativePath,
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '2.mp3').nativePath,
  Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '3.mp3').nativePath
].join();
```

Generate example:

```
var generateAudios = [
  { audio: Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '140-drum.mp3').nativePath, timings: [0, 14000, 28000] },
  { audio: Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '140-guitar.mp3').nativePath, timings: [0, 14000, 28000, 42000] }
];
```

If  the `bpm` argument is provided to `mergeAudio({ bpm: 140 })`, `timings` will be handled as **notes**. When `bpm` is not specified they will be handled as **milliseconds**.

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
var generateAudios = [
  { 
    audio: Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, '140-drum.mp3').nativePath,
    timings: [0, 14000, 28000]
  },
  { 
    audio: Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, '140-guitar.mp3').nativePath,
    timings: [0, 14000, 28000, 42000]
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

Generate example by BPM:

```
var generateAudios = [
  { 
    audio: Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, '140-drum.mp3').nativePath,
    timings: [64, 128, 192]
  },
  { 
    audio: Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, '140-guitar.mp3').nativePath,
    timings: [0, 64, 192]
  }
];
var generatedAudio = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'example.m4a');

AudioMerger.mergeAudio({
  audioMergeType: 'generate',
  audioFilesInput: generateAudios,
  audioFileOutput: generatedAudio,
  bpm: 140
});

AudioMerger.addEventListener('generate', function() {
  Ti.API.info('Concatenated audio');
});
```

### Development

1. Install packages with `npm install`
2. Update examples in `example/app.js`
3. Use `gulp ios` to build and test the module

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
