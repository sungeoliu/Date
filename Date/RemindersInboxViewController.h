//
//  RemindersInboxViewController.h
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersBaseViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "InsetsTextField.h"
#import "JTTableViewGestureRecognizer.h"
#import "PPRevealSideViewController.h"

typedef enum {
    InfoModeAudio = 0,
    InfoModeText
}InfoMode;

@interface RemindersInboxViewController : RemindersBaseViewController<UITextFieldDelegate,EGORefreshTableHeaderDelegate, UIAlertViewDelegate,MYTableViewGestureSwipeRowDelegate, PPRevealSideViewControllerDelegate>

@property (nonatomic) DataType dataType;
@property (weak, nonatomic) IBOutlet UIButton * btnMode;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet InsetsTextField  * txtDesc;
@property (weak, nonatomic) IBOutlet UIToolbar * toolbar;
@property (weak, nonatomic) IBOutlet UIView * toolbarView;
@property (weak, nonatomic) IBOutlet UILabel * labelPrompt;
@property (weak, nonatomic) IBOutlet UIView * viewBottomMenu;

// PPRevealSideViewController会给自己的rootViewController加上各种手势识别器（recognizer），
// 当左侧菜单不显示时，这些recognizer会影响tableView对单击屏幕操作的识别，所以引入这个布尔值，
// 当左侧菜单不显示时，禁用这些recognizer。
@property (nonatomic) BOOL shouldDeactiveGesture;

- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;

- (IBAction)showBottomMenuView:(id)sender;

- (IBAction)finishReminder:(id)sender;
- (IBAction)deleteReminderIconClicked:(id)sender;
- (IBAction)recoverReminderIconClicked:(id)sender;

- (void)initDataWithAnimation:(BOOL)animation;

@end
