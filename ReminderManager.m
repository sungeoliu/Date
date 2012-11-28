//
//  ReminderManager.m
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//
#import "ReminderManager.h"
#import "HttpRequestManager.h"
#import "BilateralFriendManager.h"

static ReminderManager * sReminderManager;

@implementation ReminderManager
@synthesize delegate = _delegate;

#pragma 私有函数
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request {
    // query.
    NSError * error = nil;
    NSMutableArray * mutableFetchResult = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == mutableFetchResult) {
        NSLog(@"executeFetchRequest error");
        return nil;
    }
    
    return mutableFetchResult;
}

- (NSArray *)remindersWithIdPredicate:(NSString *) remindersId {
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:remindersId];
    request.predicate = predicate;
    results = [self executeFetchRequest:request];

    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
}


- (NSString *)timeline {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * timeline =  [formatter stringFromDate:[NSDate date]];
    return timeline;
}

/*
 获取上次更新提醒的时间
 TODO 应该获取UTC时间
 */
- (NSString *)getTimeline {
    return @"1999-10-10 10:10:10";
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * timeline = [defaults objectForKey:kRemoteRemindersUpdateTimeline];
    if (nil == timeline) {
        timeline = [self timeline];
    }
    return timeline;
}

/*
 保存上次更新提醒的时间
 */
- (void)saveTimeline {
    [[NSUserDefaults standardUserDefaults] setObject:[self timeline] forKey:kRemoteRemindersUpdateTimeline];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 保存从服务器获取到的数据。
 新加reminder表数据的同时，修改BilateralFriend表
 */
- (void)saveRemotesReminders:(NSArray *)data {
    Reminder * reminder;
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        for (id object in data) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSString * reminderId = [object objectForKey:@"id"];
            if (nil == [self reminderWithId:reminderId]) {
                reminder = (Reminder *)[NSEntityDescription insertNewObjectForEntityForName:kReminderEntity inManagedObjectContext:self.managedObjectContext];
                reminder.id = [object objectForKey:@"id"];
                reminder.audioUrl = [object objectForKey:@"audio"];
                reminder.adress = [object objectForKey:@"description"];
                reminder.userID = [numberFormatter numberFromString:[object objectForKey:@"senderId"]];
                reminder.triggerTime = [dateFormatter dateFromString:[object objectForKey:@"triggerTime"]];
                reminder.sendTime = [dateFormatter dateFromString:[object objectForKey:@"createTime"]];
                reminder.latitude = [object objectForKey:@"latitude"];
                reminder.longitude = [object objectForKey:@"longitude"];
                [self synchroniseToStore];
                [[BilateralFriendManager defaultManager] modifyLastReminder:reminder.id withUserId:reminder.userID];
            }
        }
    }
}

- (Reminder *)reminderWithId:(NSString *) reminderId {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id = %@", reminderId];
    request.predicate = predicate;
    
    NSArray * results = [self executeFetchRequest:request];
    if (nil == results || 1 != results.count) {
        return nil;
    }else {
        return [results objectAtIndex:0];
    }
}

/*
 下载完音频数据后，修改数据库音频字段
 */
- (void)modifyReminderAudioUrl:(NSString *)path withReminder:(Reminder *)reminder{
    reminder.audioUrl = path;
    [self synchroniseToStore];
}

/*
 通过关键值获取已经添加的本地通知对象
 */
- (UILocalNotification *)localNotification:(NSString *)reminderId {
    UILocalNotification * localNotification = nil;
    UIApplication * app = [UIApplication sharedApplication];
    NSArray * localArray = [app scheduledLocalNotifications];
    if (nil != localArray) {
        NSDictionary * dict;
        NSString * value;
        for (localNotification in localArray) {
            dict = localNotification.userInfo;
            value = [dict objectForKey:@"key"];
            if ([value isEqualToString:reminderId]) {
                break;
            }
            localNotification = nil;
        }
    }
    
    return localNotification;
}

#pragma 静态函数
+ (ReminderManager *)defaultManager {
    if (nil == sReminderManager) {
        sReminderManager = [[ReminderManager alloc] init];
    }
    
    return sReminderManager;
}

#pragma 类成员函数

- (void)saveReminder:(Reminder *)reminder {
    if (! [self synchroniseToStore]) {
        return;
    }
}

- (NSMutableDictionary *)remindersWithId:(NSArray *) remindersId {
    NSMutableDictionary * results = nil;
    if (nil == remindersId) {
        return nil;
    }else {
        NSInteger size = remindersId.count;
        NSString * predicate = nil;
        for (NSInteger index = 0; index < size; index++) {
            if (index == 0) {
                predicate = [NSString stringWithFormat:@"id = %@", [remindersId objectAtIndex:index]] ;
            }else {
                predicate = [predicate stringByAppendingString:@" OR "];
                predicate = [predicate stringByAppendingString: predicate = [NSString stringWithFormat:@"id = %@", [remindersId objectAtIndex:index]]] ;
            }
        }
    
        NSArray * reminders = [self remindersWithIdPredicate:predicate];
        if (nil != reminders && reminders.count != 0) {
            results = [NSMutableDictionary dictionaryWithCapacity:0];
            for (Reminder * reminder in reminders) {
                [results setObject:reminder forKey:reminder.id];
            }
        }
    }

    return results;
}

- (NSArray *)remindersWithUserId:(NSNumber *)userId {
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID = %@",userId];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"triggerTime" ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
    
}

- (Reminder *)reminder {
    Reminder * reminder = [[Reminder alloc] initWithEntity:[NSEntityDescription entityForName: kReminderEntity inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext] ;
    return reminder;
}

- (void)sendReminder:(Reminder *)reminder {
    [[HttpRequestManager defaultManager] sendReminderRequest:reminder];
}

- (void)handleNewReminderResponse:(id)json {
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                if (self.delegate != nil) {
                    if ([self.delegate respondsToSelector:@selector(newReminderSuccess)]) {
                        [self.delegate performSelector:@selector(newReminderSuccess) withObject:nil];
                    }
                }
            }else {
                if (self.delegate != nil) {
                    if ([self.delegate respondsToSelector:@selector(newReminderFailed)]) {
                        [self.delegate performSelector:@selector(newReminderFailed) withObject:nil];
                    }
                }
            }
        }
    }else {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(newReminderFailed)]) {
                [self.delegate performSelector:@selector(newReminderFailed) withObject:nil];
            }
        }
    }
}

/*
 请求新的约定信息
 */
- (void)getRemoteRemindersRequest {
    [[HttpRequestManager defaultManager] getRemoteRemindersRequest:[self getTimeline]];
}

- (void)handleRemoteRemindersResponse:(id)json {
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                id data = [json objectForKey:@"data"];
                if ([data isKindOfClass:[NSArray class]]) {
                    [self saveRemotesReminders:data];
                }
            }
        }
    }
}

- (void)downloadAudioFileWithReminder:(Reminder *)reminder {
    [[HttpRequestManager defaultManager] downloadAudioFileRequest:reminder];
}

- (void)handleDowanloadAuioFileResponse:(NSDictionary *)userInfo {
    NSString * audioPath = [userInfo objectForKey:@"destinationPath"];
    Reminder * reminder = [userInfo objectForKey:@"reminder"];
    [self modifyReminderAudioUrl:audioPath withReminder:reminder];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(downloadAudioFileSuccess:)]) {
            [self.delegate performSelector:@selector(downloadAudioFileSuccess:) withObject:reminder];
        }
    }
}

- (void)addLocalNotificationWithReminder:(Reminder *)reminder {
    if (nil == [self localNotification:reminder.id]) {
        UILocalNotification * newNotification = [[UILocalNotification alloc] init];
        newNotification.fireDate = [reminder.triggerTime dateByAddingTimeInterval:-30*60];
        newNotification.alertBody = @"“约定”提醒";
        newNotification.soundName = UILocalNotificationDefaultSoundName;
        newNotification.alertAction = @"查看应用";
        newNotification.timeZone=[NSTimeZone defaultTimeZone];
        newNotification.userInfo = [NSDictionary dictionaryWithObject:reminder.id forKey:@"key"];
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
    }
}

- (void)cancelLocalNotificationWithReminder:(Reminder *)reminder {
    UILocalNotification * localNotification = [self localNotification:reminder.id];
    if (nil != localNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    }
}

- (void)modifyReminder:(Reminder *)reminder withReadState:(BOOL)isRead {
    reminder.isRead = [NSNumber numberWithBool:isRead];
    [self synchroniseToStore];
    if (YES == isRead) {
        [[BilateralFriendManager defaultManager] modifyUnReadRemindersSizeWithUserId:reminder.userID withOperateType:OperateTypeSub];
    }
}

- (void)modifyReminder:(Reminder *)reminder withBellState:(BOOL)isBell {
    reminder.isBell = [NSNumber numberWithBool:isBell];
    [self synchroniseToStore];
}

@end
