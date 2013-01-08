//
//  SoundManager.m
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "SoundManager.h"
#import "DocumentManager.h"

static SoundManager * sSoundManager;

@interface SoundManager () {
    AVAudioRecorder * _recorder;
    AVAudioPlayer * _player;
    AVAudioPlayer * _alarmPlayer;
    NSDate * _startRecordDate;
    float _recordLength;
    NSTimer * _timer;
    NSThread * _thread;
    NSCondition * _lock;
    NSArray  * _images;
}

@end

@implementation SoundManager
@synthesize recordFileURL = _recordFileURL;
@synthesize view = _view;
@synthesize imageView = _imageView;
@synthesize viewWarning = _viewWarning;
@synthesize currentRecordTime = _currentRecordTime;
@synthesize parentView = _parentView;
@synthesize indicatorView = _indicatorView;

+ (SoundManager *)defaultSoundManager {
    if (nil == sSoundManager) {
        sSoundManager = [[SoundManager alloc] init];
    }
    
    return sSoundManager;
}

- (id)init {
    if (self = [super init]) {
        [[NSBundle mainBundle] loadNibNamed:@"RecordView" owner:self options:nil];
        if (nil != _view) {
            _view.frame = CGRectMake(50.0, 100.0, _view.frame.size.width,_view.frame.size.height);
            _viewWarning.frame = CGRectMake(50.0, 150.0, _viewWarning.frame.size.width,_viewWarning.frame.size.height);
            [self initImageView];
            _lock = [[NSCondition alloc] init];
        }
    }
    
    return self;
}

#pragma 私有函数
- (NSDictionary *)setting {
    NSMutableDictionary * recordSettings = [[NSMutableDictionary alloc] initWithCapacity:0];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];//格式
    [recordSettings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey]; //采样8000次
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];//声道
    [recordSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//位深度
    [recordSettings setValue :[NSNumber numberWithInt: AVAudioQualityMax]     forKey:AVEncoderAudioQualityKey];
    
    return recordSettings;
}

- (void)initImageView {
    if (nil != _imageView) {
        /*self.imageView.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"recordingSignal001"],
                                          [UIImage imageNamed:@"recordingSignal002"],
                                          [UIImage imageNamed:@"recordingSignal003"],
                                          [UIImage imageNamed:@"recordingSignal004"],
                                          [UIImage imageNamed:@"recordingSignal005"],
                                          [UIImage imageNamed:@"recordingSignal006"],
                                          [UIImage imageNamed:@"recordingSignal007"],
                                          [UIImage imageNamed:@"recordingSignal008"],
                                          nil];
        self.imageView.animationDuration = 1;*/
        _images =  [NSArray arrayWithObjects:
                    [UIImage imageNamed:@"recordingSignal001"],
                    [UIImage imageNamed:@"recordingSignal002"],
                    [UIImage imageNamed:@"recordingSignal003"],
                    [UIImage imageNamed:@"recordingSignal004"],
                    [UIImage imageNamed:@"recordingSignal005"],
                    [UIImage imageNamed:@"recordingSignal006"],
                    [UIImage imageNamed:@"recordingSignal007"],
                    [UIImage imageNamed:@"recordingSignal008"],
                    nil];
    }
}

- (void)setImageWithAudioLevel:(NSInteger)level {
    if (level >= 35) {
        [_imageView setImage:[_images objectAtIndex:7]];
    }else if (level >= 30 && level < 35){
        [_imageView setImage:[_images objectAtIndex:6]];
    }if (level >= 25 && level < 30){
        [_imageView setImage:[_images objectAtIndex:5]];
    }if (level >= 20 && level < 25){
        [_imageView setImage:[_images objectAtIndex:4]];
    }if (level >= 15 && level < 20){
        [_imageView setImage:[_images objectAtIndex:3]];
    }if (level >= 10 && level < 15){
        [_imageView setImage:[_images objectAtIndex:2]];
    }if (level >= 5 && level < 10){
        [_imageView setImage:[_images objectAtIndex:1]];
    }if (level < 5){
        [_imageView setImage:[_images objectAtIndex:0]];
    }
}

- (void)showWaringView {
    if (nil != _parentView) {
        [_parentView addSubview:_viewWarning];
        [self performSelector:@selector(closeWaringView) withObject:self afterDelay:0.5];
    }
}

- (void)closeWaringView {
    [_viewWarning removeFromSuperview];
}

- (void)showRecordingView {
    if (nil != _parentView) {
        [_parentView addSubview:_view];
        [_indicatorView startAnimating];
    }
}

- (void)closeRecordingView {
    //[_imageView stopAnimating];
    [_view removeFromSuperview];
}

- (NSString *)fileNameWithPath:(NSString *)path {
    NSString * fileName;
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    fileName = [path substringFromIndex:range.location + 1];
    return fileName;
}

- (void)checkRecordLength {
    if (NO == _thread.isExecuting) {
        if (_recordLength > 30) {
            [self stopTimer];
            [self stopRecord];
        }
        [_recorder updateMeters];
        double avgPowerForChannel = pow(10, (0.05 * [_recorder averagePowerForChannel:0]));
        [self setImageWithAudioLevel:avgPowerForChannel * 100];
        _recordLength = _recordLength + 0.03;
    }
    
}

- (void)startTimer {
    [self stopTimer];
    _recordLength = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(checkRecordLength) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (nil != _timer) {
        NSLog(@"stopTimer");
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)recorder {
    [_lock lock];
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
        
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        [_lock unlock];
        return ;
    }else {
        [session setActive:YES error:nil];
    }
    if (nil != _recorder) {
        [_recorder deleteRecording];
    }
    _recorder = [[AVAudioRecorder alloc] initWithURL:_recordFileURL settings:[self setting] error:&error];
    if(_recorder) {
        [_recorder setMeteringEnabled:YES];
        [_recorder record];
        _startRecordDate = [NSDate date];
    }else {
        NSLog(@"recorder: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
    }
        
    [_indicatorView stopAnimating];
    //[_imageView startAnimating];
    [_lock unlock];
}

#pragma 类成员函数
- (BOOL)startRecord {
    BOOL result = YES;
    DocumentManager * manager = [DocumentManager defaultManager];
    _recordFileURL =  [manager pathForRandomSoundWithSuffix:@"m4a"];
    [self showRecordingView];
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(recorder) object:nil];
    [_thread start];
    [self startTimer];
    return result;
}

- (BOOL)stopRecord {
    BOOL result = NO;
    [_lock lock];
        
    [self stopTimer];
    if (nil != _recorder) {
        NSDate * endRecordDate = [NSDate date];
        [self closeRecordingView];
        NSTimeInterval diffTime = [endRecordDate timeIntervalSinceDate:_startRecordDate];
        if (diffTime < 0.5) {
            [_recorder stop];
            [_recorder deleteRecording];
            _recorder = nil;
            [self showWaringView];
        }else {
            result = YES;
            _currentRecordTime = _recorder.currentTime + 1;
            [self performSelector:@selector(realStopReocrd) withObject:self afterDelay:1.0];
        }
    }else {
        result = YES;
    }

    [_lock unlock];
    
    return result;
}

- (void)realStopReocrd {
    [_recorder stop];
    _recorder = nil;
}

- (BOOL)playRecording {
    BOOL result = NO;
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return NO;
    }else {
        [session setActive:YES error:nil];
    }
            
    _player  = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordFileURL error:&error];
    _player.numberOfLoops  = 0;
    _player.volume = 1.0;
    _player.delegate = self;
    if (nil == _player) {
        NSLog(@"播放失败");
    }else {
        result = YES;
        [_player prepareToPlay];
        [_player  play];
    }
    
    return result;
}

- (BOOL)playAudio:(NSString *)path {
    BOOL result = NO;
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return NO;
    }else {
        [session setActive:YES error:nil];
    }
    
    DocumentManager * manager = [DocumentManager defaultManager];
    
    path = [[manager soundPath] stringByAppendingPathComponent:[self fileNameWithPath:path]];
    NSURL * url = [NSURL fileURLWithPath:path isDirectory:NO];
    _player  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _player.numberOfLoops  = 0;
    _player.volume = 1.0;
    _player.delegate = self;
    if (nil == _player) {
        NSLog(@"播放失败 %@",[error localizedFailureReason]);
    }else {
        result = YES;
        [_player prepareToPlay];
        [_player  play];
    }
    
    return result;
}

- (void)playAlarmVoice {
    NSURL *url = [[NSBundle mainBundle] URLForResource: @"cat"
                                         withExtension: @"wav"];
    NSError  *error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return ;
    }else {
        [session setActive:YES error:nil];
    }
    _alarmPlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _alarmPlayer.numberOfLoops  = 0;
    _alarmPlayer.volume = 1.0;
    _alarmPlayer.delegate = self;
    if  (_alarmPlayer == nil)
        NSLog(@"播放失败");
    else
        [_alarmPlayer prepareToPlay];
        [_alarmPlayer play];
}

- (void)stopAudio {
    if (nil != _player) {
        [_player stop];
        _player = nil;
    }
}

- (NSInteger)audioTime:(NSString *)path {
    NSInteger time = 0;
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return NO;
    }else {
        [session setActive:YES error:nil];
    }
    
    NSURL * url = [NSURL fileURLWithPath:path isDirectory:NO];
    _player  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (nil != _player) {
        time = _player.duration;
    }
    
    return time;
}

- (BOOL)fileExistsAtPath:(NSString *)path {
    DocumentManager * manager = [DocumentManager defaultManager];
    path = [[manager soundPath] stringByAppendingPathComponent:[self fileNameWithPath:path]];
    if (YES == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    return NO;
}

#pragma AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (_alarmPlayer == player) {
        _alarmPlayer = nil;
        if (self.delegate != nil) {
            
            //if ([self.delegate respondsToSelector:@selector(alarmPlayerDidFinishPlaying)]) {
            //    [self.delegate performSelector:@selector(alarmPlayerDidFinishPlaying) withObject:nil];
            //}
            
            NSNotification * notification = nil;
            notification = [NSNotification notificationWithName:kAlarmPlayFinishedMessage object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }else {
        _player = nil;
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying)]) {
                [self.delegate performSelector:@selector(audioPlayerDidFinishPlaying) withObject:nil];
            }
        }
  
    }
}

@end
