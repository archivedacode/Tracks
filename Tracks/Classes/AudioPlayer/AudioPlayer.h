//
//  AudioPlayer.h
//  Tracks
//
//  Created by David Ross on 05/07/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioPlayerDelegate;

@interface AudioPlayer : NSObject

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, assign) CGFloat gain;
@property (nonatomic, strong) MPMediaItem *mediaItem;
@property (nonatomic, assign) id <AudioPlayerDelegate> delegate;

@property (nonatomic, assign) BOOL alive;

- (void)play;
- (void)pause;
- (void)seekToTime:(CGFloat)time;
- (BOOL)isPlaying;

@end

@protocol AudioPlayerDelegate <NSObject>
@optional
- (void)playerItemStopped;
- (void)playerItemReachedEnd;
- (void)playerItemTimeChanged:(CMTime)time;
@end
