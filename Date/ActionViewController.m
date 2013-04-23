//
//  ActionViewController.m
//  Date
//
//  Created by Liu Wanwei on 13-4-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "ActionViewController.h"
#import "ReminderManager.h"
#import "GlobalFunction.h"


@implementation ActionViewController

@synthesize triggerTime = _triggerTime;

- (void)postDelayMessage{
    NSLog(@"发送延迟消息");
    [[NSNotificationCenter defaultCenter] postNotificationName:kReminderSettingOk object:nil userInfo:[NSDictionary dictionaryWithObject:self.triggerTime forKey:kTriggerTime]];
}

- (void)postSettingOkMessage{
    // 这个必须pop到上一级界面，由上级界面处理修改。TODO: 权宜之计，一定修改。
    [self.navigationController popViewControllerAnimated:NO];
    [self performSelector:@selector(postDelayMessage) withObject:nil afterDelay:0.2];
}

- (IBAction)fifteenMinutesLaterBtnClicked:(id)sender{
    self.triggerTime = [[NSDate date] dateByAddingTimeInterval:15*60];
    [self postSettingOkMessage];
}

- (IBAction)thirtyMinutesLaterBtnClicked:(id)sender{
    self.triggerTime = [[NSDate date] dateByAddingTimeInterval:30*60];
    [self postSettingOkMessage];
}

- (IBAction)oneHourLaterBtnClicked:(id)sender{
    self.triggerTime = [[NSDate date] dateByAddingTimeInterval:60 * 60];
    [self postSettingOkMessage];
}

- (IBAction)tomorrowBtnClicked:(id)sender{
    self.triggerTime = [[NSDate date] dateByAddingTimeInterval:24 * 60 * 60];
    [self postSettingOkMessage];
}

// 根据不同的弹出方式进行不同的退出界面。
- (void)dismissViewController{
    if (self.presentingViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)postFinishMessageForReminder:(Reminder *)reminder{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReminderDone object:nil userInfo:[NSDictionary dictionaryWithObject:reminder forKey:kReminderObject]];
}

- (IBAction)finishBtnClicked:(id)sender{
    // 退回到提醒列表界面，由它的消息处理函数来处理。
    [self dismissViewController];
    [self performSelector:@selector(postFinishMessageForReminder:) withObject:self.reminder afterDelay:0.5];
}

- (void)postDeletingMessage{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReminderDeleting object:nil userInfo:[NSDictionary dictionaryWithObject:self.reminder forKey:kReminderObject]];
}

- (IBAction)deleteBtnClicked:(id)sender{
    // 退回到提醒列表界面，由它的消息处理函数来处理
    [self dismissViewController];
    [self performSelector:@selector(postDeletingMessage) withObject:nil afterDelay:0.2];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"快捷操作";
    [[GlobalFunction defaultInstance] customizeNavigationBar:self.navigationController.navigationBar];
    [[GlobalFunction defaultInstance] initNavleftBarItemWithController:self withAction:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
