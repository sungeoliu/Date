//
//  ModifyAudioReminderViewController.m
//  date
//
//  Created by maoyu on 13-1-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "ModifyAudioReminderViewController.h"
#import "AppDelegate.h"
#import "TextEditorViewController.h"
#import "GlobalFunction.h"

typedef enum {
    TitleTypeShow = 0,
    TitleTypeModify
}TitleType;

@interface ModifyAudioReminderViewController ()

@end

@implementation ModifyAudioReminderViewController

#pragma 私有函数
- (void)initData {
    self.receiverId = self.reminder.userID;
    self.triggerTime = self.reminder.triggerTime;
    self.reminderType = [self.reminder.type integerValue];
    self.desc = self.reminder.desc;
}

- (void)saveReminder {
    [self modifyReminder];
}

- (void)updateTitle:(TitleType)type {
    if (TitleTypeShow == type) {
        self.title = @"提醒详情";
    }else {
        self.title = @"修改提醒";
    }
}

- (void)updateView {
    [self updateTitle:TitleTypeModify];
    [self updateTableFooterView];
}

- (void)updateTableFooterView {
    if (self.tableView.hidden == NO) {
        [self showTabeleFooterView];
    }
    
    if (YES == self.isInbox) {
        [self updateTableFooterViewInModifyInboxState];
    }else {
        [self updateTableFooterViewInModifyAlarmState];
    }
}

- (void)updateReceiverCell {
    [self updateView];
    [super updateReceiverCell];
}

- (void)updateTriggerTimeCell {
    [super updateTriggerTimeCell];
    [self updateView];
}

- (void)updateDescCell {
    [self updateView];
    [super updateDescCell];
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
    [self initData];
    [super viewDidLoad];
    [self updateTitle:TitleTypeShow];
    [self hiddenTableFooterView];
    [[GlobalFunction defaultInstance] initNavleftBarItemWithController:self withAction:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    [super newReminderSuccess:reminderId];
    [[AppDelegate delegate].ribViewController initDataWithAnimation:NO];
    
    [self dissmissSettingView];
}

@end
