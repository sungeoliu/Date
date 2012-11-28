//
//  ReminderManager.h
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseManager.h"
#import "Reminder.h"

@protocol ReminderManagerDelegate <NSObject>

@optional
- (void)newReminderSuccess;
- (void)newReminderFailed;
- (void)downloadAudioFileSuccess:(Reminder *)reminder;
@end

@interface ReminderManager : BaseManager

@property (weak, nonatomic) id<ReminderManagerDelegate> delegate;

+ (ReminderManager *)defaultManager;

- (Reminder *)reminder;

- (void)saveReminder:(Reminder *)reminder;
- (NSMutableDictionary *)remindersWithId:(NSArray *) remindersId;
- (NSArray *)remindersWithUserId:(NSNumber *)userId;

- (void)sendReminder:(Reminder *)reminder;
- (void)handleNewReminderResponse:(id)json;

- (void)getRemoteRemindersRequest;
- (void)handleRemoteRemindersResponse:(id)json;

- (void)downloadAudioFileWithReminder:(Reminder *)reminder;
- (void)handleDowanloadAuioFileResponse:(NSDictionary *)userInfo;

- (void)addLocalNotificationWithReminder:(Reminder *)reminder;
- (void)cancelLocalNotificationWithReminder:(Reminder *)reminder;

- (void)modifyReminder:(Reminder *)reminder withReadState:(BOOL)isRead;
- (void)modifyReminder:(Reminder *)reminder withBellState:(BOOL)isBell;
@end
