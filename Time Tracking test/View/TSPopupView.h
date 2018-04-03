//
//  TSPopupView.h
//  Time Tracking test
//
//  Created by Admin on 02.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSPopupView;

@protocol TSPopupViewDelegate <NSObject>

- (void)startTimerPopupViewDelegate:(UITextView *)textView;
- (void)dismissPopupViewDelegate:(NSDictionary *)parameters;

@end

@interface TSPopupView : UIView

@property (weak, nonatomic) id <TSPopupViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (strong, nonatomic) IBOutlet UIButton *timerButton;

+ (instancetype)initViewByRect:(CGRect)rect;
- (void)startTimerLeavingBbackground:(NSInteger)time;

@end
