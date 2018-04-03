//
//  ViewController.m
//  Time Tracking test
//
//  Created by Admin on 02.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "ViewController.h"
#import "TSTableViewCell.h"
#import "Task+CoreDataClass.h"
#import "TSDataManager.h"
#import "TSPopupView.h"
#import "TSPrefixHeader.pch"
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>

static NSString * const cellIdentifier = @"cell";

@interface ViewController () <NSFetchedResultsControllerDelegate, TSPopupViewDelegate, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) TSPopupView *popupView;
@property (assign, nonatomic) BOOL visiblePopupView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //location document data base
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    [self.shareButton setEnabled:NO];
    self.visiblePopupView = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Action

- (IBAction)addNewTask:(id)sender
{
    if (self.visiblePopupView == NO) {
        self.popupView = [TSPopupView initViewByRect:self.view.frame];
        self.popupView.delegate = self;
        self.popupView.textField.delegate = self;
        self.popupView.textView.delegate = self;
        [self.tableView addSubview:self.popupView];
        
        [UIView animateWithDuration:0.2
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.8
                            options:0
                         animations:^{
                             self.popupView.frame = CGRectMake(30, self.popupView.frame.size.height / 2, self.view.frame.size.width - 70, self.popupView.frame.size.height);
                         } completion:nil];
        
        self.visiblePopupView = YES;
    }
}

- (IBAction)shareTask:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        mailCompose.mailComposeDelegate = self;
        
        NSString *fileName = [[NSString alloc]initWithFormat:@"Time-Tracking-test.sqlite"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *pdfFileName = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        
        NSMutableData *mySQLData = [NSMutableData dataWithContentsOfFile:pdfFileName];
        [mailCompose addAttachmentData:mySQLData mimeType:@"application/octet-stream" fileName:fileName];
        [mailCompose setSubject:@"My task table"];
        [mailCompose setToRecipients:[NSArray arrayWithObject:@"timeTracking@gmail.com"]];
        [mailCompose setMessageBody:@"Email sent from the application the Time Tracking" isHTML:NO];
        
        [self presentViewController:mailCompose animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSManagedObjectContext

- (NSManagedObjectContext *) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[TSDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

#pragma mark - TSPopupViewDelegate

- (void)dismissPopupViewDelegate:(NSDictionary *)parameters
{
    [self saveTask:parameters];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.popupView.frame = CGRectMake((self.view.frame.size.width - self.popupView.frame.size.width) / 2, kDismissPopupView, self.popupView.frame.size.width, self.popupView.frame.size.height);
                     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.popupView removeFromSuperview];
        self.popupView = nil;
        self.visiblePopupView = NO;
    });
}

//hide keyboard at start-up timer and scroll top table view

- (void)startTimerPopupViewDelegate:(UITextView *)textView
{
    [textView resignFirstResponder];
    CGPoint point = CGPointMake(0.0, -kHeightNavBar);
    [self.tableView setContentOffset:point animated:YES];
}

#pragma mark - save task

- (void)saveTask:(NSDictionary *)taskParam
{
    Task *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task"
                                               inManagedObjectContext:self.managedObjectContext];
    task.name = [taskParam objectForKey:@"name"];
    task.descript = [taskParam objectForKey:@"descript"];
    task.time = [taskParam objectForKey:@"time"];
    task.date = [NSDate date];
    [self.managedObjectContext save:nil];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    if (sectionInfo.numberOfObjects > 0) {
        [self.shareButton setTintColor:BLUE_COLOR];
        [self.shareButton setEnabled:YES];
    }
    return [sectionInfo numberOfObjects] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[TSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    if (indexPath.row == 0) {
        [self configureHeaderCell:cell atIndexPath:index];
    } else {
        [self configureTaskCell:cell atIndexPath:index];
    }
    return cell;
}

- (void)configureHeaderCell:(TSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.taskLabel.text = @"Task";
    cell.descriptLabel.text = @"Description";
    cell.timeLabel.text = @"Time";
    cell.contentView.backgroundColor = BLUE_COLOR;
}

- (void)configureTaskCell:(TSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.taskLabel.text = task.name;
    cell.descriptLabel.text = task.descript;
    cell.timeLabel.text = task.time;
    cell.contentView.backgroundColor = YELLOW_COLOR;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptorData = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptorData]];
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureTaskCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            return;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height - 170, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, kbSize.height);
    self.tableView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.tableView.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.view.frame.origin.y - kbSize.height);
        [self.tableView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//hide placeholder textView

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.popupView.placeholderLabel.hidden = NO;
    } else {
        self.popupView.placeholderLabel.hidden = YES;
    }
}

@end
