//
//  ReminderSettingViewController.m
//  Date
//
//  Created by maoyu on 12-11-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderSettingViewController.h"
#import "SoundManager.h"
#import "Reminder.h"
#import "ReminderMapViewController.h"
#import "ReminderSendingViewController.h"
#import "SinaWeiboManager.h"
#import "AppDelegate.h"
#import "ReminderTimeSettingViewController.h"
#import "ShowTextReminderViewController.h"
#import "ShowAudioReminderViewController.h"
#import "ModifyAudioReminderViewController.h"
#import "ModifyTextReminderViewController.h"
#import "LMLibrary.h"
#import "GlobalFunction.h"
#import "ActionViewController.h"

@interface ReminderSettingViewController () {
    UIDatePicker * _datePicker;
    UILabel * _labelPrompt;
    NSDate * _oriTriggerTime;
}

@end

@implementation ReminderSettingViewController
@synthesize tableView = _tableView;
@synthesize pickerView = _pickerView;
@synthesize btnSave = _btnSave;
@synthesize reminder = _reminder;
@synthesize receiver = _receiver;
@synthesize desc = _desc;
@synthesize triggerTime = _triggerTime;
@synthesize isLogin = _isLogin;
@synthesize isAuthValid = _isAuthValid;
@synthesize receiverId = _receiverId;
@synthesize userManager = _userManager;
@synthesize isInbox = _isInbox;
@synthesize labelSize = _labelSize;
@synthesize dateType = _dateType;
@synthesize reminderType = _reminderType;
@synthesize showSendFriendCell = _showSendFriendCell;
@synthesize textCell = _textCell;
@synthesize isShowingExpiredReminder = _isShowingExpiredReminder;

+ (ReminderSettingViewController *)createController:(Reminder *)reminder withDateType:(NSInteger)type{
    ReminderSettingViewController * controller;
    NSString * audioPath = reminder.audioUrl;
    UserManager * userManager = [UserManager defaultManager];
    if (DateTypeHistory == type ||
        (NO == [userManager isSentToMyself:reminder.userID] && nil != reminder.triggerTime)) {
        // 展示提醒。
        if (nil == audioPath || [audioPath isEqualToString:@""]) {
            controller = [[ShowTextReminderViewController alloc] initWithNibName:@"TextReminderSettingViewController" bundle:nil];
        }else {
            controller = [[ShowAudioReminderViewController alloc] initWithNibName:@"AudioReminderSettingViewController" bundle:nil];
        }
        
        controller.btnSave.hidden = YES;
    }else {
        // 修改提醒。
        if (nil == audioPath || [audioPath isEqualToString:@""]) {
            controller = [[ModifyTextReminderViewController alloc] initWithNibName:@"TextReminderSettingViewController" bundle:nil];
        }else {
            controller = [[ModifyAudioReminderViewController alloc] initWithNibName:@"AudioReminderSettingViewController" bundle:nil];
        }
        
        if (DateTypeCollectingBox == type) {
            controller.isInbox = YES;
        }else {
            controller.isInbox = NO;
        }
    }
    
    controller.reminder = reminder;
    
    return controller;
}

#pragma 私有函数
- (void)removeHUD {
    [[MBProgressManager defaultManager] removeHUD];
}

- (void)initDatePicker {
    if (nil == _datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
    }
}

- (void)initTableFooterViewOfReminderFinished {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 150)];
    self.tableView.tableFooterView = view;

}

- (void)restoreReminder {
    [self.reminderManager modifyReminder:_reminder withState:ReminderStateUnFinish];
    [[AppDelegate delegate].ribViewController initDataWithAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma 类成员函数
- (void)updateReceiverCell {
}

- (void)updateTriggerTimeCell {
}

- (void)updateDescCell {
}

- (void)clickTrigeerTimeRow:(NSIndexPath *)indexPath {
    ReminderTimeSettingViewController * timeSettingController;
    timeSettingController = [[ReminderTimeSettingViewController alloc] initWithNibName:@"ReminderTimeSettingViewController" bundle:nil];
    timeSettingController.title = @"设置提醒方式";
    timeSettingController.parentContoller = self;
    timeSettingController.datePick = _datePicker;
    [self.navigationController pushViewController:timeSettingController animated:YES];
}

- (void)clickSendRow {
    ReminderSendingViewController * controller = [[ReminderSendingViewController alloc] initWithNibName:@"ReminderSendingViewController" bundle:nil];
    _reminder.triggerTime =  _triggerTime;
    controller.reminder = _reminder;
    controller.parentController = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSString *)stringTriggerTime {
    NSString * result;
    if (nil != _triggerTime) {
        if (ReminderTypeReceive == _reminderType) {
            result = [[GlobalFunction defaultInstance] custumDateTimeString:_triggerTime];
        }else {
            result =  [[GlobalFunction defaultInstance] custumDayString:_triggerTime];
        }
    }else {
        result = kInboxTimeDesc;
    }

    return result;
}

- (void)initTableFooterView {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 150)];
    
    _btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnSave.layer.frame = CGRectMake(10, 30, 300, 44);
    _btnSave.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"buttonBg"] forState:UIControlStateNormal];
    [_btnSave setTitle:kSave forState:UIControlStateNormal];
    [_btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnSave addTarget:self action:@selector(saveReminder) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_btnSave];
    
    self.tableView.tableFooterView = view;
}

- (void)updateTableFooterViewInCreateState{
    if (nil != _triggerTime) {
        if (YES == [[UserManager defaultManager] isSentToMyself:_receiverId] ) {
            [_btnSave setTitle:kSave forState:UIControlStateNormal];
        }else {
            [_btnSave setTitle:LocalString(@"SettingPromptOfSendWithButton") forState:UIControlStateNormal];
        }
    }else {
        [_btnSave setTitle:kSave forState:UIControlStateNormal];
    }
}

- (void)updateTableFooterViewInModifyInboxState {
    if (nil != _triggerTime) {
        if (YES == [[UserManager defaultManager] isSentToMyself:_receiverId] ) {
            [_btnSave setTitle:kSave forState:UIControlStateNormal];
        }else {
            [_btnSave setTitle:LocalString(@"SettingPromptOfSendWithButton") forState:UIControlStateNormal];
        }
    }else {
        [_btnSave setTitle:kSave forState:UIControlStateNormal];
    }
}

- (void)updateTableFooterViewInModifyAlarmState {
    if (nil != _triggerTime) {
        if (YES == [[UserManager defaultManager] isSentToMyself:_receiverId] ) {
            [_btnSave setTitle:kSave forState:UIControlStateNormal];
        }else {
            [_btnSave setTitle:LocalString(@"SettingPromptOfSendWithButton") forState:UIControlStateNormal];
        }
    }else {
        [_btnSave setTitle:kSave forState:UIControlStateNormal];
    }
}

- (void)hiddenTableFooterView {
    [self.tableView.tableFooterView setHidden:YES];
}

- (void)showTabeleFooterView {
    [self.tableView.tableFooterView setHidden:NO];
}

- (void)createReminder {
    _reminder.userID = _receiverId;
    _reminder.triggerTime = _triggerTime;
    _reminder.type = [NSNumber numberWithInteger:_reminderType];
    _reminder.desc = _desc;
    
    if (![_userManager isSentToMyself:_reminder.userID]) {
        [[MBProgressManager defaultManager] showHUD:@"发送中"];
    }
    
    [[ReminderManager defaultManager] sendReminder:_reminder];
}

- (void)modifyReminder {
    _reminder.userID = _receiverId;
    if ([_userManager isSentToMyself:_receiverId]) {
        [[ReminderManager defaultManager] modifyReminder:_reminder withTriggerTime:_triggerTime withDesc:_desc withType:_reminderType];
        
        [self dissmissSettingView];
    }else {
        _oriTriggerTime = _reminder.triggerTime;
        _reminder.triggerTime = _triggerTime;
        _reminder.desc = _desc;
        _reminder.type = [NSNumber numberWithInteger:ReminderTypeSend];
        [[ReminderManager defaultManager] sendReminder:_reminder];
        
        [[MBProgressManager defaultManager] showHUD:@"发送中"];
    }
}

- (void)computeFontSize {
//    [UIFont fontWithName:@"Helvetica" size:17.0]
    _labelSize = [self.desc sizeWithFont:[UIFont boldSystemFontOfSize:17.0] constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode: UILineBreakModeTailTruncation];
}

- (void)initTriggerTime {
    if (DateTypeToday == self.dateType || DateTypeRecent == self.dateType) {
        // 日期提醒。
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        NSString * strTriggerTime;
        [formatter setDateFormat:@"yyyy-MM-dd 23:59:59"];
        strTriggerTime = [formatter stringFromDate:[NSDate date]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.triggerTime = [formatter dateFromString:strTriggerTime];
    }else if (DateTypeSpecific == self.dateType){
        // 闹铃提醒。
        self.triggerTime = [GlobalFunction rightAlignedDate];
    }
}

// 处理修改提醒时间界面的“完成”快捷方式按钮。
- (void)handleSaveReminderMessage:(NSNotification *)notification{
    
    // saveReminder在派生类中被定义。当前类其实相当于C++中的纯虚类。
    
    if (notification && notification.userInfo != nil) {
        self.triggerTime = [notification.userInfo objectForKey:kTriggerTime];
        self.reminderType = ReminderTypeReceive;
    }
    
    NSLog(@"收到提醒修改消息");
    SEL sel = @selector(saveReminder);
    if (sel) {
        SuppressPerformSelectorLeakWarning([self performSelector:sel]);
    }
}

// 修改提醒完成后，关闭当前界面。
- (void)dissmissSettingView{
    if (self.presentingViewController != nil) {
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

// 弹出对到期提醒做处理的快捷菜单。
- (void)presentActionView{
    ActionViewController * av = [[ActionViewController alloc] initWithNibName:@"ActionViewController" bundle:nil];
    av.reminder = self.reminder;
    [self.navigationController pushViewController:av animated:YES];
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
    self.view.backgroundColor = RGBColor(244, 244, 244);
    [self computeFontSize];
    [self initTableFooterView];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _userManager = [UserManager defaultManager];
    _isLogin = [[SinaWeiboManager defaultManager].sinaWeibo isLoggedIn];
    _isAuthValid = [[SinaWeiboManager defaultManager].sinaWeibo isAuthValid];
    
    NSLog(@"注册 kReminderSettingOk 消息");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSaveReminderMessage:) name:kReminderSettingOk object:nil];
}

// 添加操作快捷方式入口。
- (void)addActionEntrance{
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"..." style:UIBarButtonItemStyleBordered target:self action:@selector(presentActionView)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initDatePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 90;
    }else if (indexPath.section == 1 && indexPath.row == 0) {
        return 12.0f;
    }
    return 44.0f;
}

#pragma mark - ReminderManager delegate

// TODO: 新建提醒成功后，这是干什么呢？
- (void)newReminderSuccess:(NSString *)reminderId {
    self.reminderManager.delegate = nil;
    [[MBProgressManager defaultManager] removeHUD];
    if (NO == [_userManager isSentToMyself:_reminder.userID] && nil != _reminder.triggerTime && ReminderTypeReceiveAndNoAlarm != [_reminder.type integerValue]) {
        if (nil == _reminder.id || [_reminder.id isEqualToString:@""]) {
            _reminder.id = reminderId;
        }
        
        _reminder.triggerTime = _oriTriggerTime;
        [self.reminderManager modifyReminder:_reminder withTriggerTime:_triggerTime withDesc:_desc withType:ReminderTypeSend];
    }
}

- (void)newReminderFailed {
    NSLog(@"newReminderFailed");
    [[MBProgressManager defaultManager] showHUD:@"发送失败"];
    [self performSelector:@selector(removeHUD) withObject:self afterDelay:0.5];
}
@end
