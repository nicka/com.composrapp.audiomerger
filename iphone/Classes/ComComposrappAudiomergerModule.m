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
    NSDictionary * params = [args objectAtIndex:0];

    // Set in and output paths
    NSString *audioInput = [TiUtils stringValue:[params objectForKey:@"audioFilesInput"]];
    NSString *audioOutput = [TiUtils stringValue:[params objectForKey:@"audioFileOutput"]];
    NSURL *audioFileOutput = [NSURL fileURLWithPath:audioOutput];
    
    // Check if in and output audios are set
    if (!audioInput || !audioFileOutput) {
        NSLog(@"[ERROR] No audioFilesInput or audioFileOutput");
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
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];

    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // --------------------------------------------
    // Concatenate, Generate or Merge audio
    // --------------------------------------------
    // Concatenate audio
    if (![self concatenateAudio:compositionAudioTrack audioInput:audioInput]) {
        NSLog(@"[ERROR] NSFileManager: Could not concatenate audio");
        [self fireEvent:@"error"];
        return NO;
    }
    
    // --------------------------------------------
    // Create AVAssetExportSession and return audio
    // --------------------------------------------
    // Setup new export session
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetPassthrough];
    
    // Check if exportSession is ready
    if (exportSession == nil) {
        NSLog(@"[ERROR] Could not setup export session");
        [self fireEvent:@"error"];
        return NO;
    }
    
    // Set output file type for new audio
    if ([audioInput containsString:@".mp3"]) {
        exportSession.outputFileType = @"com.apple.quicktime-movie";
    } else if ([audioInput containsString:@".wav"]) {
        exportSession.outputFileType = @"com.microsoft.waveform-audio";
    } else if ([audioInput containsString:@".m4a"]) {
        exportSession.outputFileType = AVFileTypeAppleM4A;
    }
    
    // Format export path with .mov
    NSString *fileNameWithExtension = audioFileOutput.lastPathComponent;
    NSString *fileName = [fileNameWithExtension stringByDeletingPathExtension];
    NSString *extension = fileNameWithExtension.pathExtension;
    
    // HACK: Add .mov for .mp3 files
    NSString *exportUrlStr = audioOutput;
    // HACK: Add .mov for .mp3 files
    if ([audioInput containsString:@".mp3"]) {
        exportUrlStr = [audioOutput stringByReplacingOccurrencesOfString: extension withString:@"mov"];
    }
    
    // Generate final export url
    NSURL *exportUrl = [NSURL fileURLWithPath:exportUrlStr];
    
    // Remove old cropped audio file
    [[NSFileManager defaultManager] removeItemAtURL:exportUrl error:NULL];
    
    // Set final export audio url
    exportSession.outputURL = exportUrl;
   
    // Start cropping audio
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status) {
             // Rename file to desired audio file
             if ([self renameFileFrom:exportUrl to:audioFileOutput]) {
                 NSLog(@"[INFO] Merged audio");
                 [self fireEvent:@"success"];
             } else {
                 NSLog(@"[ERROR] NSFileManager: Could not rename merged audio %@", exportSession.error);
                 [self fireEvent:@"error"];
             }
         } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
             NSLog(@"[ERROR] AVAssetExportSessionStatusFailed: Could not merge audio %@", exportSession.error);
             [self fireEvent:@"error"];
         } else {
             NSLog(@"[ERROR] Could not merge audio %d", exportSession.status);
         }
     }];
    
    return YES;
}

- (BOOL)concatenateAudio:(AVMutableCompositionTrack*)compositionAudioTrack audioInput:(NSString*)audioInput
{
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
        // NSLog(@"[INFO] url %@", url);
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

- (BOOL)renameFileFrom:(NSURL*)oldPath to:(NSURL*)newPath
{
    NSString *oldFile = [oldPath path];
    NSString *newFile = [newPath path];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] moveItemAtPath:oldFile toPath:newFile error:&error]) {
        NSLog(@"[ERROR] Failed to move '%@' to '%@': %@", oldPath, newPath, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

@end
