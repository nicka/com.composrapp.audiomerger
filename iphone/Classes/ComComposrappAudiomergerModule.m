/**
 * audio_merger
 *
 * Created by Nick den Engelsman
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "ComComposrappAudiomergerModule.h"

@implementation ComComposrappAudiomergerModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"ff6c04b3-1913-4d3d-b59a-6202ea4be4a6";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.composrapp.audiomerger";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(void)mergeAudio:(id)args
{
    // Retreive params
    ENSURE_UI_THREAD_1_ARG(args);
    NSDictionary *params = [args objectAtIndex:0];
    
    // Set in and output paths
    NSString *mergeType = [TiUtils stringValue:[params objectForKey:@"audioMergeType"]];
    NSString *audioOutput = [TiUtils stringValue:[params objectForKey:@"audioFileOutput"]];
    NSURL *audioFileOutput = [NSURL fileURLWithPath:audioOutput];
    // NSLog(@"[INFO] audioFileOutput %@", audioFileOutput);
    
    // Check if merge type is set
    if (!mergeType) {
        NSLog(@"[ERROR] No audioMergeType specified");
        [self fireEvent:@"error"];
        return NO;
    }
    
    // Check if output audio is set
    if (!audioFileOutput) {
        NSLog(@"[ERROR] No audioFilesInput or audioFileOutput specified");
        [self fireEvent:@"error"];
        return NO;
    }

    // Remove old audioFileOutput file
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    
    // --------------------------------------------
    // Create AVMutableComposition Object:
    // This object will hold our multiple
    // AVMutableCompositionTrack.
    // --------------------------------------------
    AVMutableComposition *composition = [AVMutableComposition composition];

    // --------------------------------------------
    // Concatenate or Generate audio
    // --------------------------------------------
    // Concatenate audio
    if ([mergeType isEqualToString:@"concatenate"]) {
        if (![self concatenateAudio:composition params:params]) {
            NSLog(@"[ERROR] NSFileManager: Could not concatenate audio");
            [self fireEvent:@"error"];
            return NO;
        }
    // Generate audio
    } else if ([mergeType isEqualToString:@"generate"]) {
        if (![self generateAudio:composition params:params]) {
            NSLog(@"[ERROR] NSFileManager: Could not generate audio");
            [self fireEvent:@"error"];
            return NO;
        }
    }

    // --------------------------------------------
    // Create AVAssetExportSession and return audio
    // --------------------------------------------
    // Setup new export session
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    
    // Check if exportSession is ready
    if (exportSession == nil) {
        NSLog(@"[ERROR] Could not setup export session");
        [self fireEvent:@"error"];
        return NO;
    }
    
    // Set output file type for new audio
    exportSession.outputFileType = AVFileTypeAppleM4A;
    
    // Format export path
    NSString *fileNameWithExtension = audioFileOutput.lastPathComponent;
    NSString *fileName = [fileNameWithExtension stringByDeletingPathExtension];
    NSString *extension = fileNameWithExtension.pathExtension;
    
    // Generate final export url
    NSString *exportUrlStr = audioOutput;
    NSURL *exportUrl = [NSURL fileURLWithPath:exportUrlStr];

    // Remove old generated audio file
    [[NSFileManager defaultManager] removeItemAtURL:exportUrl error:NULL];
    
    // Set final export audio url
    exportSession.outputURL = exportUrl;
   
    // Save audio
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status) {
             NSLog(@"[INFO] Successfully %@d audio", mergeType);
             [self fireEvent:mergeType];
         } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
             NSLog(@"[ERROR] AVAssetExportSessionStatusFailed: Could not %@ audio %@", mergeType, exportSession.error);
             [self fireEvent:@"error"];
         } else {
             NSLog(@"[ERROR] Could not %@ audio %d", mergeType, exportSession.status);
         }
     }];
    
    return YES;
}

- (BOOL)concatenateAudio:(AVMutableComposition*)composition params:(NSDictionary*)params
{
    // Create AVMutableCompositionTrack
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    // Check if audio input is set
    NSString *audioInput = [TiUtils stringValue:[params objectForKey:@"audioFilesInput"]];
    if (!audioInput) {
        NSLog(@"[ERROR] No audioFilesInput specified");
        [self fireEvent:@"error"];
        return NO;
    }
    
    // Format audios string to array
    NSArray *audioFilesInput = [audioInput componentsSeparatedByString:@","];
    
    // Setup defaults
    NSError *error = nil;
    BOOL ok = NO;
    CMTime nextClipStartTime = kCMTimeZero;
    
    // Loop through audioFilesInput array
    for (int i = 0; i< [audioFilesInput count]; i++) {
        // Build the filename with path
        NSString *key = [audioFilesInput objectAtIndex:i];
        NSURL *url = [NSURL URLWithString:key];
        // Setup AV Asset
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([tracks count] == 0)
            return NO;
        // Get audio duration
        CMTimeRange timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [avAsset duration]);
        AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        // Combine audio
        ok = [compositionAudioTrack insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:&error];
        if (!ok) {
            NSLog(@"[ERROR] Current audio track error: %@", error);
            [self fireEvent:@"error"];
            return NO;
        }
        // Update next audio playback time
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
    }
    
    return YES;
}

- (BOOL)generateAudio:(AVMutableComposition*)composition params:(NSDictionary*)params
{
    // Check if audio input is set
    NSDictionary *audioInput = [params objectForKey:@"audioFilesInput"];
    if (!audioInput) {
        NSLog(@"[ERROR] No audioFilesInput specified");
        [self fireEvent:@"error"];
        return NO;
    }
    
    // Check for bpm support
    float intBpm;
    NSString *bpm = [params objectForKey:@"bpm"];
    if (!bpm) {
        intBpm = 0.0;
    } else {
        intBpm = [bpm floatValue];
        intBpm = intBpm * 2;
    }

    // Calculate milliseconds per beat
    float msPerBeat;
    if (intBpm == 0) {
        msPerBeat = 0.0;
    } else {
        msPerBeat = (60 * 1000) / intBpm;
    }
    
    // Setup defaults
    NSError *error = nil;
    BOOL ok = NO;
    
    // Loop through audioFilesInput array
    for (int i = 0; i< [audioInput count]; i++) {
        // Retreive params
        NSDictionary *params = [audioInput objectAtIndex:i];
        // Retreive audio and timings from params
        NSString *audio = [params objectForKey:@"audio"];
        NSURL *url = [NSURL URLWithString:audio];
        NSArray *timings = [params objectForKey:@"timings"];
        // Loop through timings and combine audio
        if (![self addAudio:url at:timings composition:composition bpm:intBpm msPerBeat:msPerBeat]) {
            NSLog(@"[ERROR] AVMutableCompositionTrack: Could not add %@", url);
            [self fireEvent:@"error"];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)addAudio:(NSURL*)url at:(NSArray*)timings composition:(AVMutableComposition*)composition bpm:(int) bpm msPerBeat:(float)msPerBeat
{
    // Setup defaults
    NSError *error = nil;
    BOOL ok = NO;
    
    // Fetch audio asset and track
    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    CMTimeRange trackRange = CMTimeRangeMake(kCMTimeZero, avAsset.duration);
    AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];

    // Loop through timings and combine audio
    for (int i = 0; i< [timings count]; i++) {
        // Setup composition track
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // [compositionAudioTrack setPreferredVolume:0.8];
        
        // Calculate startTime
        int intTime;
        NSString *timeStr = [timings objectAtIndex:i];
        intTime = [timeStr intValue];
        
        // Add track to composition
        ok = [compositionAudioTrack insertTimeRange:trackRange ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
        if (!ok) {
            NSLog(@"[ERROR] Could not mix audio track %@ at time %d error %@", url, intTime, error);
            [self fireEvent:@"error"];
            return NO;
        } 
        // NSLog(@"[INFO] Mixed audio track %@ at time %d", url, intTime);
        
        // Add empty audio to position track based on timing
        if (bpm == 0 && intTime > 0) {
            // Add empty audio by ms
            CMTime start = kCMTimeZero;
            CMTime end = CMTimeMake(intTime, 1000);
            CMTimeRange silence = CMTimeRangeMake(start, end);
            [compositionAudioTrack insertEmptyTimeRange:silence];
        } else {
            // Add empty audio by beat
            float beatToMs = intTime * msPerBeat;
            CMTime start = kCMTimeZero;
            CMTime end = CMTimeMake(beatToMs, 1000);
            CMTimeRange silence = CMTimeRangeMake(start, end);
            [compositionAudioTrack insertEmptyTimeRange:silence];
        }
    }
    
    return YES;
}

@end
