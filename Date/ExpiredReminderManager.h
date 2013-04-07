//
//  ExpiredReminderManager.h
//  Date
//
//  Created by Liu Wanwei on 13-4-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reminder;

@interface ExpiredReminderManager : NSObject

@property (strong) NSMutableArray * queue;

+ (ExpiredReminderManager *)defaultInstance;

- (void)addNodes:(NSArray *)nodes;
- (void)removeNode:(Reminder *)reminder;
- (BOOL)presentReminder;


@end
