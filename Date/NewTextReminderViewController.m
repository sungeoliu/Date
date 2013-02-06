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
- (void)initNavBar {
    UIBarButtonItem * leftItem;
    leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    UIFont *font = [UIFont systemFontOfSize:12.0];
    NSValue * offset = [NSValue valueWithUIOffset:UIOffsetMake(0, 2)];
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:font, UITextAttributeFont,RGBColor(0, 0, 0), UITextAttributeTextColor,[UIColor whiteColor],UITextAttributeTextShadowColor,offset,UITextAttributeTextShadowOffset,nil];
    [leftItem setTitleTextAttributes:attr forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = leftItem;
}

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
    self.reminderType = ReminderTypeReceiveAndNoAlarm;
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
    [self initNavBar];
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
        [AppDelegate delegate].homeViewController.dataType = DataTypeCollectingBox;
    }else {
        if (YES == [self.userManager isOneself:[self.reminder.userID stringValue]]) {
            target = kUMengEventReminderParamSelf;
        }else {
            target = kUMengEventReminderParamOthers;
        }
        
        if (ReminderTypeReceiveAndNoAlarm == [self.reminder.type integerValue]) {
            type = kUMengEventReminderParamNoAlarm;
        }else {
            type = kUMengEventReminderParamAlarm;
        }
        NSDate * tommrow = [[GlobalFunction defaultGlobalFunction] tomorrow];
        if ([self.reminder.triggerTime compare:tommrow] == NSOrderedAscending) {
            date = kUMengEventReminderParamToady;
            [AppDelegate delegate].homeViewController.dataType = DataTypeToday;
        }else {
            date = kUMengEventReminderParamOtherDay;
            [AppDelegate delegate].homeViewController.dataType = DataTypeRecent;
        }
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date,kUMengEventReminderParamDate,type, kUMengEventReminderParamType, target, kUMengEventReminderParamTarget, nil];
    [MobClick event:event attributes:dict];
    
    [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
       
    }];
}

@end
