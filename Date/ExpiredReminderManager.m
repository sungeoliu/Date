//
//  ExpiredReminderManager.m
//  Date
//
//  Created by Liu Wanwei on 13-4-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "ExpiredReminderManager.h"
#import "Reminder.h"
#import "AppDelegate.h"
#import "SoundManager.h"
#import "ReminderSettingViewController.h"
#import "ReminderManager.h"

#define kReminderExpiredMessage     @"kReminderExpiredMessgae"

static ExpiredReminderManager * sDefaultInstance = nil;

@implementation ExpiredReminderManager

+ (ExpiredReminderManager *)defaultInstance{
    if (nil == sDefaultInstance) {
        sDefaultInstance = [[ExpiredReminderManager alloc] init];
    }
    
    return sDefaultInstance;
}

- (id)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentReminder) name:kReminderExpiredMessage object:nil];
    }
    
    return self;
}

- (void)presentSettingViewForReminder:(Reminder *)reminder{
    NSLog(@"打开提醒详情界面");
    AppDelegate * delegate = [AppDelegate delegate];
    
    // 显示一个提醒。DateTypeToday是狡猾做法，认为到期的一定是今天的。
    ReminderSettingViewController * controller = [ReminderSettingViewController createController:reminder withDateType:DateTypeToday];
    // 打上标记，关闭时再次检查，形成连续检查。
    controller.isShowingExpiredReminder = YES;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [[GlobalFunction defaultInstance] customizeNavigationBar:nav.navigationBar];
    [delegate.navController presentViewController:nav animated:YES completion:nil];
}

// 显示一个到期提醒的详情。
- (BOOL)presentReminder{
    AppDelegate * delegate = [AppDelegate delegate];
    if (self.queue != nil && self.queue.count > 0) {
        NSLog(@"准备展示到期的提醒");
        Reminder * reminder = [self.queue objectAtIndex:0];
        
        // 播放提示音。
        [[SoundManager defaultSoundManager] playAlarmSound];
        
        // 设置已提醒标记。
        ReminderManager * manager = [ReminderManager defaultManager];
        [manager modifyReminder:reminder withBellState:YES];
        
        // 展示提醒详情。
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self presentSettingViewForReminder:reminder];
        });
        
        return YES;
    }else{
        NSLog(@"到期提醒展示完毕");
        // 在所有提示界面都弹完之后，刷新主界面。
        [delegate.ribViewController initDataWithAnimation:NO];

        return NO;
    }
}

- (void)addNodes:(NSArray *)nodes{
    // TODO: 要做去重处理。
    if (nodes != nil) {
        if (self.queue == nil) {
            self.queue = [NSMutableArray arrayWithArray:nodes];
        }else{
            [self.queue addObjectsFromArray:nodes];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kReminderExpiredMessage object:nil];
    }
}

- (void)removeNode:(Reminder *)reminder{
    [self.queue removeObject:reminder];
}

@end
