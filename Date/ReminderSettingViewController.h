//
//  ReminderSettingViewController.h
//  Date
//
//  Created by maoyu on 12-11-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomChoiceViewController.h"
#import "RemindersBaseViewController.h"
#import "ReminderSettingTimeCell.h"
#import "MBProgressManager.h"
#import "RemindersInboxViewController.h"
#import "ReminderManager.h"

@interface ReminderSettingViewController : RemindersBaseViewController <UITableViewDelegate, UITableViewDataSource,ReminderManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;
@property (strong, nonatomic) UIButton * btnSave;

@property (strong, nonatomic) Reminder * reminder;
@property (strong, nonatomic) NSString * desc;
@property (weak, nonatomic) NSString * receiver;
@property (strong, nonatomic) NSNumber * receiverId;
@property (strong, nonatomic) NSDate * triggerTime;
@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isAuthValid;
@property (weak, nonatomic) UserManager * userManager;
@property (nonatomic) BOOL isInbox;
@property (nonatomic) CGSize labelSize;
@property (nonatomic) DataType dateType;
@property (nonatomic) ReminderType reminderType;
@property (nonatomic) BOOL showSendFriendCell;
@property (nonatomic, weak) IBOutlet UITableViewCell * textCell;
@property (nonatomic) BOOL needSaveReminder;
@property (nonatomic) BOOL isShowingExpiredReminder;

+ (ReminderSettingViewController *)createController:(Reminder *)reminder withDateType:(NSInteger)type;

- (void)updateReceiverCell;
- (void)updateTriggerTimeCell;
- (void)updateDescCell;
- (NSString *)stringTriggerTime;
- (void)clickTrigeerTimeRow:(NSIndexPath *)indexPath;
- (void)clickSendRow;
- (void)initTableFooterView;
- (void)initTableFooterViewOfReminderFinished;
- (void)updateTableFooterViewInCreateState;
- (void)updateTableFooterViewInModifyInboxState;
- (void)updateTableFooterViewInModifyAlarmState;
- (void)hiddenTableFooterView;
- (void)showTabeleFooterView;
- (void)createReminder;
- (void)modifyReminder;
- (void)computeFontSize;
- (void)initTriggerTime;
- (void)dissmissSettingView;

- (void)addActionEntrance;
@end
