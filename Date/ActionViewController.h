//
//  ActionViewController.h
//  Date
//
//  Created by Liu Wanwei on 13-4-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ReminderOperation15MinutesLater = 0,
    RemidnerOperation30MinutesLater,
    ReminderOperation60MinutesLater,
    ReminderOperationTomorrow,
    ReminderOperationDone,
    ReminderOperationDelete
}ReminderOperation;

@class Reminder;

@interface ActionViewController : UIViewController

@property (nonatomic, strong) NSDate * triggerTime;
@property (nonatomic, weak) Reminder * reminder;

- (IBAction)fifteenMinutesLaterBtnClicked:(id)sender;
- (IBAction)thirtyMinutesLaterBtnClicked:(id)sender;
- (IBAction)oneHourLaterBtnClicked:(id)sender;
- (IBAction)tomorrowBtnClicked:(id)sender;
- (IBAction)finishBtnClicked:(id)sender;
- (IBAction)deleteBtnClicked:(id)sender;

@end
