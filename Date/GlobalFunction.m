//
//  GlobalFunction.m
//  date
//
//  Created by maoyu on 13-1-7.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "GlobalFunction.h"
#import "LMLibrary.h"
#import "AppDelegate.h"
#import <objc/runtime.h>
#import "ReminderSettingViewController.h"
#import "ExpiredReminderManager.h"

static GlobalFunction * sGlobalFunction;

@implementation GlobalFunction

+ (GlobalFunction *)defaultInstance{
    if (nil == sGlobalFunction) {
        sGlobalFunction = [[GlobalFunction alloc] init];
    }
    
    return sGlobalFunction;
}

- (void)customizeNavigationBar:(UINavigationBar *)navigationBar{
    UIImage * image = [UIImage imageNamed:@"navigationBarBg"];
    [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    navigationBar.tintColor = RGBColor(242, 242, 242);
    UIFont * font = [UIFont systemFontOfSize:20.0];
    NSValue * offset = [NSValue valueWithUIOffset:UIOffsetMake(0, 2)];
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:font, UITextAttributeFont,RGBColor(0, 0, 0), UITextAttributeTextColor,[UIColor whiteColor],UITextAttributeTextShadowColor,offset,UITextAttributeTextShadowOffset,nil];
    [navigationBar setTitleTextAttributes:attr];
   
}

static char UITopViewControllerKey;

// 共享的左侧导航按钮处理函数。
- (void)sharedBackItemClicked:(id)sender{
    UIViewController * topVC = (UIViewController *)objc_getAssociatedObject(sender, &UITopViewControllerKey);
    
    if ([self isPresentedInModelMode:topVC] &&
        [self isInNavigationStackBottom:topVC]) {
//        UIViewController * vc = [[[AppDelegate delegate] window] rootViewController];
//        CGRect frame = vc.view.frame;
//        NSLog(@"SettingVC %@: x=%f, y=%f", @"back", frame.origin.x, frame.origin.y);
        [topVC dismissViewControllerAnimated:YES completion:nil];
        
        if ([topVC isKindOfClass:[ReminderSettingViewController class]]) {
            ReminderSettingViewController * rsVc = (ReminderSettingViewController *)topVC;
            if (rsVc.isShowingExpiredReminder) {
                NSLog(@"检查是否还有到期提醒");
                [[ExpiredReminderManager defaultInstance] presentReminder];
            }
        }
    }else{
        [topVC.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)isInNavigationStackBottom:(UIViewController *)controller{
    if (controller.navigationController) {
        if (controller.navigationController.viewControllers.count == 1) {
            return YES;
        }
    }
    
    return NO;
}

// 判断一个View是否以模态方式显示。
- (BOOL)isPresentedInModelMode:(UIViewController *)controller{
    if (controller && controller.presentingViewController != nil) {
        return YES;
    }else{
        return NO;
    }
}

- (void)initNavleftBarItemWithController:(UIViewController *)controller withAction:(SEL)action{
    controller.navigationItem.hidesBackButton = YES;
    UIButton *leftButton;
    UIBarButtonItem * item;
    SEL customAction = action;
    id actionTarget = controller;
    BOOL needAssociation = NO;

    // 指定默认的消息处理。
    if (nil == customAction) {
        customAction = @selector(sharedBackItemClicked:);
        actionTarget = self;
        needAssociation = YES;
    }
    
    // 根据模态或导航的显示模式，实现不同的返回按钮外观。
    if ([self isPresentedInModelMode:controller] &&
        [self isInNavigationStackBottom:controller]) {
        
        // 当界面模态展示，并处于导航栈底时，左侧导航按钮处理成“取消”样式。
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:actionTarget action:customAction];
        if (needAssociation) {
            objc_setAssociatedObject(item, &UITopViewControllerKey, controller, OBJC_ASSOCIATION_ASSIGN);
        }
        [self customNavigationBarItem:item];
    }else{
        leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [leftButton setImage:[UIImage imageNamed:@"backNavigationBar"] forState:UIControlStateNormal];
        [leftButton addTarget:actionTarget action:customAction forControlEvents:UIControlEventTouchUpInside];
        
        if (needAssociation) {
            objc_setAssociatedObject(leftButton, &UITopViewControllerKey, controller, OBJC_ASSOCIATION_ASSIGN);
        }
        
        item = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    }
    
    controller.navigationItem.leftBarButtonItem = item;
}

- (UIColor *)viewBackground {
    return RGBColor(255,255,255);
}

- (NSString *)custumDateString:(NSString *)date withShowDate:(BOOL)show{
    NSString * dateString;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    
    NSDate * nowDate = [NSDate date];
    nowDate = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    NSDate * startDate = [formatter dateFromString:date];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSDayCalendarUnit;
    
    //取相距时间额
    NSDateComponents * cps = [calendar components:unitFlags fromDate:nowDate  toDate:startDate  options:0];
    NSInteger diffDay  = [cps day];
    if (diffDay == 0) {
        dateString = @"今天";
    }else if (diffDay == 1) {
        dateString = @"明天";
    }else if (diffDay == -1) {
        dateString = @"昨天";
    }else {
        if (YES == show) {
            [formatter setDateFormat:@"MM-dd"];
            date = [formatter stringFromDate:startDate];
            dateString = date;
        }else {
            dateString = @"日期";
        }
    }
    return dateString;
}

- (NSString *)custumDayString:(NSDate *)date {
    NSString * dateString;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    
    NSDate * nowDate = [NSDate date];
    nowDate = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    date = [formatter dateFromString:[formatter stringFromDate:date]];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit;
    
    //取相距时间额
    NSDateComponents * cps = [calendar components:unitFlags fromDate:nowDate  toDate:date  options:0];
    NSInteger diffDay  = [cps day];
    if (diffDay == 0) {
        dateString = @"今天";
    }else if (diffDay == 1) {
        dateString = @"明天";
    }else if (diffDay == 2) {
        dateString = @"后天";
    }else if (diffDay == -1) {
        dateString = @"昨天";
    }else {
        [formatter setDateFormat:@"MM-dd"];
        dateString = [formatter stringFromDate:date];
    }
    return dateString;
}

- (void)customNavigationBarItem:(UIBarButtonItem *)item{
    UIFont *font = [UIFont systemFontOfSize:12.0];
    NSValue * offset = [NSValue valueWithUIOffset:UIOffsetMake(0, 2)];
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:font, UITextAttributeFont,RGBColor(0, 0, 0), UITextAttributeTextColor,[UIColor whiteColor],UITextAttributeTextShadowColor,offset,UITextAttributeTextShadowOffset,nil];
    [item setTitleTextAttributes:attr forState:UIControlStateNormal];
}

- (NSString *)custumDateString2:(NSDate *)date {
    NSString * dateString;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];
    dateString = [formatter stringFromDate:date];
    return dateString;
}

- (NSString *)custumDateTimeString:(NSDate *)date {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * datetimeString = [self custumDayString:date];
    [formatter setDateFormat:@"HH:mm"];
    datetimeString = [datetimeString stringByAppendingString:@" "];
    datetimeString = [datetimeString stringByAppendingString:[formatter stringFromDate:date]];
    
    return datetimeString;
}

// 根据5分钟时间间隔，获取向右取证的当前时间，比如当前时间11：28分，返回11：30分的时间。
+ (NSDate *)rightAlignedDate{
    NSDate * date = [NSDate date];
    NSTimeInterval timeInterval = (int)[date timeIntervalSince1970];
    NSTimeInterval left = (int)timeInterval % (DatePickerMinutesInterval * 60);
    if (left != 0) {
        timeInterval -= left;
        timeInterval += DatePickerMinutesInterval * 60;
        
        return [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }else{
        return date;
    }
}

- (NSDate *)tomorrow {
    NSDate * today = [NSDate date];
    NSDate * tomorrow;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    today = [formatter dateFromString:[formatter stringFromDate:today]];
    tomorrow = [today dateByAddingTimeInterval:24*60*60];
    return tomorrow;
}

- (NSInteger)diffDay:(NSDate *)date {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    
    NSDate * nowDate = [NSDate date];
    nowDate = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    date = [formatter dateFromString:[formatter stringFromDate:date]];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit;
    
    NSDateComponents * cps = [calendar components:unitFlags fromDate:nowDate  toDate:date  options:0];
    NSInteger diffDay  = [cps day];
    return diffDay;
}

@end
