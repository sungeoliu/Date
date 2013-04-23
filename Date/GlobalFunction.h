//
//  GlobalFunction.h
//  date
//
//  Created by maoyu on 13-1-7.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LocalString(key)  NSLocalizedString(key, nil)

#define DatePickerMinutesInterval       5

@interface GlobalFunction : NSObject

+ (GlobalFunction *)defaultInstance;

// 个性化导航条。
- (void)customizeNavigationBar:(UINavigationBar *)navigationBar;

// 个性化导航按钮。
- (void)customNavigationBarItem:(UIBarButtonItem *)item;

// 个性化导航条左侧按钮的消息处理函数。
- (void)initNavleftBarItemWithController:(UIViewController *)controller withAction:(SEL)action;

- (IBAction)sharedBackItemClicked:(id)sender;

- (NSString *)custumDateString:(NSString *)date withShowDate:(BOOL)show;
- (NSString *)custumDateTimeString:(NSDate *)date;
- (NSString *)custumDayString:(NSDate *)date;
- (NSString *)custumDateString2:(NSDate *)date;

+ (NSDate *)rightAlignedDate;


- (NSInteger)diffDay:(NSDate *)date;

- (NSDate *)tomorrow;

- (UIColor *)viewBackground;

@end
