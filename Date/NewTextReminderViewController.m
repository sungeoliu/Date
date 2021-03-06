//
//  NewTextReminderViewController.m
//  date
//
//  Created by maoyu on 13-1-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "NewTextReminderViewController.h"
#import "AppDelegate.h"
#import "TextEditorViewController.h"
#import "MobClick.h"

@interface NewTextReminderViewController ()

@end

@implementation NewTextReminderViewController

#pragma 私有函数

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^ {
        //[[AppDelegate delegate] checkRemindersExpired];
    }];
}

- (void)saveReminder {
    [self createReminder];
}

- (void)initData {
    self.reminder = [[ReminderManager defaultManager] reminder];
    self.receiverId = [NSNumber numberWithLongLong:[[UserManager defaultManager].oneselfId longLongValue]];
    self.receiver = @"自己";
    self.reminderType = ReminderTypeReceive;
    self.dateType = DateTypeSpecific;
    [self initTriggerTime];
}

- (void)updateReceiverCell {
    [self updateTableFooterViewInCreateState];
    [super updateReceiverCell];
}

- (void)updateTriggerTimeCell {
    [super updateTriggerTimeCell];
    [self updateTableFooterViewInCreateState];
}

#pragma 事件函数
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
    self.title = @"新建提醒";
    
    UIBarButtonItem * leftItem;
    leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    [[GlobalFunction defaultInstance] customNavigationBarItem:leftItem];
    self.navigationItem.leftBarButtonItem = leftItem;

    [self initData];
    [self updateTableFooterViewInCreateState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    [super newReminderSuccess:reminderId];
    NSString * type;
    NSString * target;
    NSString * date;
    NSString * event = kUMengEventReminderCreate;
    
    if (nil == self.reminder.triggerTime) {
        target = kUMengEventReminderParamSelf;
        type = kUMengEventReminderParamNoAlarm;
        date = kUMengEventReminderParamCollectingBox;
        [AppDelegate delegate].ribViewController.dataType = DateTypeCollectingBox;
    }else {
        if (YES == [self.userManager isSentToMyself:self.reminder.userID]) {
            target = kUMengEventReminderParamSelf;
        }else {
            target = kUMengEventReminderParamOthers;
        }
        
        if (ReminderTypeReceiveAndNoAlarm == [self.reminder.type integerValue]) {
            type = kUMengEventReminderParamNoAlarm;
        }else {
            type = kUMengEventReminderParamAlarm;
        }
        NSDate * tommrow = [[GlobalFunction defaultInstance] tomorrow];
        if ([self.reminder.triggerTime compare:tommrow] == NSOrderedAscending) {
            date = kUMengEventReminderParamToady;
            [AppDelegate delegate].ribViewController.dataType = DateTypeToday;
        }else {
            date = kUMengEventReminderParamOtherDay;
            [AppDelegate delegate].ribViewController.dataType = DateTypeRecent;
        }
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date,kUMengEventReminderParamDate,type, kUMengEventReminderParamType, target, kUMengEventReminderParamTarget, nil];
    [MobClick event:event attributes:dict];
    
    [[AppDelegate delegate].ribViewController initDataWithAnimation:NO];
    
    [self dissmissSettingView];
}

@end
