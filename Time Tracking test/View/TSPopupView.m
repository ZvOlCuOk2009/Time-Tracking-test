//
//  TSPopupView.m
//  Time Tracking test
//
//  Created by Admin on 02.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "TSPopupView.h"
#import "NSString+TSString.h"
#import "TSPrefixHeader.pch"

@interface TSPopupView ()

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger counter;
@property (assign, nonatomic) BOOL stateButton;

@end

@implementation TSPopupView

+ (instancetype)initViewByRect:(CGRect)rect
{
    TSPopupView *view = nil;
    view = [self initViewNibBySizeDevice:view
                                 nameNib:@"TSPopupView"
                                frameNib:CGRectMake((rect.size.width - kFramePopupView.size.width) / 2, kFramePopupView.origin.y, kFramePopupView.size.width, kFramePopupView.size.height)];
    return view;
}

+ (TSPopupView *)initViewNibBySizeDevice:(TSPopupView *)view nameNib:(NSString *)name frameNib:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    view = [nib instantiateWithOwner:self options:nil][0];
    view.frame = frame;
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.counter = 1;
}

#pragma mark - Action

- (IBAction)actionButton:(id)sender
{
    if (self.stateButton == NO) {
        if ([self.textField.text isEqualToString:@""] || [self.textView.text isEqualToString:@""]) {
            [self showAlert];
        } else {
            self.timerLabel.hidden = NO;
            self.textField.hidden = YES;
            self.textView.hidden = YES;
            [self.timerButton setTitle:@"Finish Task" forState:UIControlStateNormal];
            [self startTimer];
            [self.delegate startTimerPopupViewDelegate:self.textView];
            self.stateButton = YES;
        }
    } else if (self.stateButton == YES) {
        [self.delegate dismissPopupViewDelegate:@{@"name":self.textField.text, @"descript":self.textView.text, @"time":self.timerLabel.text}];
        self.stateButton = NO;
        [self.timer invalidate];
    }
}

#pragma mark - Timer

- (void)startTimer {
    
    if (!self.timer) {
        [self activateTimer];
    }
}

//receive the counter at the moment of an exit from a background mode

- (void)startTimerLeavingBbackground:(NSInteger)time
{
    self.counter = time;
    [self activateTimer];
}

- (void)activateTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [self.timer isValid];
}

- (void)timerAction
{
    self.timerLabel.text = [self currentTime];
    
    //save value counter
    [[NSUserDefaults standardUserDefaults] setInteger:self.counter - 1 forKey:@"counter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)currentTime
{
    ++self.counter;
    return [NSString currentTime:self.counter];
}

- (void)showAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please, enter a title and description of the task!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok"
                                                     style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [[self currentTopViewController] presentViewController:alert
                                                  animated:YES
                                                completion:nil];
}

//display alert from the view

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end
