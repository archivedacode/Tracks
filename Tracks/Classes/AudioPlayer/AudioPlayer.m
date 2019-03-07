//
//  AudioPlayer.m
//  Tracks
//
//  Created by David Ross on 05/07/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

#import "AudioPlayer.h"

static void *KVOStatusContext = &KVOStatusContext;

@interface AudioPlayer ()

@end

@implementation AudioPlayer

@synthesize alive = _alive;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.alive = NO;
        self.gain = 1.0;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeNotificationObservers];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark - Properties

- (void)setMediaItem:(MPMediaItem *)item
{
    if (_player)
    {
        [_player pause];
    }
    
    _mediaItem = item;
    
    NSURL *url = [_mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:options];
    AVAssetTrack *audioTrack = [[asset tracks] objectAtIndex:0];
    AVMutableAudioMixInputParameters *inputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    
    MTAudioProcessingTapCallbacks callbacks;
    callbacks.version = kMTAudioProcessingTapCallbacksVersion_0;
    callbacks.clientInfo = (__bridge void * _Nullable)(self);
    callbacks.init = init;
    callbacks.prepare = prepare;
    callbacks.process = process;
    callbacks.unprepare = unprepare;
    callbacks.finalize = finalize;
    
    MTAudioProcessingTapRef tap;
    OSStatus err = MTAudioProcessingTapCreate(kCFAllocatorDefault,
                                              &callbacks,
                                              kMTAudioProcessingTapCreationFlag_PostEffects,
                                              &tap);
    if (err || !tap)
    {
        NSLog(@"Unable to create the Audio Processing Tap. Error: %d", (int)err);
        return;
    }
    
    inputParams.audioTapProcessor = tap;
    
    [self removeNotificationObservers];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self addNotificationObservers];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[inputParams];
    _playerItem.audioMix = audioMix;
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    
    __weak __typeof(self) weakSelf = self;
    
    [_player addPeriodicTimeObserverForInterval:[self computeSeekTime:0.5]
                                          queue:dispatch_get_main_queue()
                                     usingBlock:^(CMTime time) {
                                         if (self->_delegate && [self->_delegate respondsToSelector:@selector(playerItemTimeChanged:)])
                                         {
                                             [weakSelf.delegate playerItemTimeChanged:time];
                                         }
    }];
}

#pragma mark - Methods

- (void)play
{
    if (_player)
    {
        [_player play];
        
        self.alive = YES;
    }
}

- (void)pause
{
    if (_player)
    {
        [_player pause];
        
        if (_delegate && [_delegate respondsToSelector:@selector(playerItemStopped)])
        {
            [_delegate playerItemStopped];
        }
    }
}

- (void)stop
{
    if (_player)
    {
        [_player pause];
        [_player seekToTime:[self computeSeekTime:0.0]];
        
        if (_delegate && [_delegate respondsToSelector:@selector(playerItemStopped)])
        {
            [_delegate playerItemStopped];
        }
    }
}

- (void)seekToTime:(CGFloat)time
{
    if (_player)
    {
        [_player pause];
        [_player seekToTime:[self computeSeekTime:time]];
        [_player play];
    }
}

- (BOOL)isPlaying
{
    return self.player.rate > 0.0;
}

- (CMTime)computeSeekTime:(CGFloat)seconds
{
    return CMTimeMakeWithSeconds(seconds, 600);
}

- (void)addNotificationObservers
{
    [_playerItem addObserver:self forKeyPath:@"status" options:0 context:&KVOStatusContext];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(itemDidReachEnd:)
               name:AVPlayerItemDidPlayToEndTimeNotification
             object:_playerItem];
    
    [nc addObserver:self
           selector:@selector(itemFailedToReachEnd:)
               name:AVPlayerItemFailedToPlayToEndTimeNotification
             object:_playerItem];
    
    [nc addObserver:self
           selector:@selector(itemPlaybackStalled:)
               name:AVPlayerItemPlaybackStalledNotification
             object:_playerItem];
}

- (void)removeNotificationObservers
{
    if (_playerItem)
    {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [nc removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
        [nc removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
    }
}

#pragma mark - AVPlayerItem notifications

- (void)itemDidReachEnd:(NSNotification *)notification
{    
    if (_delegate && [_delegate respondsToSelector:@selector(playerItemReachedEnd)])
    {
        [_delegate playerItemReachedEnd];
    }
}

- (void)itemFailedToReachEnd:(NSNotification*)notification
{
    [self stop];
}

- (void)itemPlaybackStalled:(NSNotification*)notification
{
    [self stop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &KVOStatusContext)
    {
        if (object == _playerItem && [keyPath isEqualToString:@"status"])
        {
            if (_playerItem.status == AVPlayerStatusReadyToPlay)
            {
                //NSLog(@"AVPlayerStatusReadyToPlay");
            }
            else if (_playerItem.status == AVPlayerStatusFailed || _playerItem.status == AVPlayerStatusUnknown)
            {
                //NSLog(@"AVPlayerStatusFailed || AVPlayerStatusUnknown");
                if (_delegate && [_delegate respondsToSelector:@selector(playerItemStopped)])
                {
                    [_delegate playerItemStopped];
                }
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - MTAudioProcessingTap callback methods

void init(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut)
{
    *tapStorageOut = clientInfo;
}

void finalize(MTAudioProcessingTapRef tap)
{
    
}

void prepare(MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat)
{
    
}

void unprepare(MTAudioProcessingTapRef tap)
{
    
}

void process(MTAudioProcessingTapRef tap,
             CMItemCount numberFrames,
             MTAudioProcessingTapFlags flags,
             AudioBufferList *bufferListInOut,
             CMItemCount *numberFramesOut,
             MTAudioProcessingTapFlags *flagsOut)
{
    OSStatus err = MTAudioProcessingTapGetSourceAudio(tap,
                                                      numberFrames,
                                                      bufferListInOut,
                                                      flagsOut,
                                                      NULL,
                                                      numberFramesOut);
    
    if (err == noErr)
    {
        AudioPlayer *PLAYER = (__bridge AudioPlayer*) MTAudioProcessingTapGetStorage(tap);
        
        float *bufferL = (float*)bufferListInOut->mBuffers[0].mData;
        float *bufferR = (float*)bufferListInOut->mBuffers[1].mData;
        
        for (int j=0; j<*numberFramesOut; j++)
        {
            bufferL[j] = bufferL[j] * PLAYER.gain;
            bufferR[j] = bufferR[j] * PLAYER.gain;
        }
    }
    else
    {
        NSLog(@"Error from MTAudioProcessingTapGetSourceAudio: %d", (int)err);
    }
}

@end
