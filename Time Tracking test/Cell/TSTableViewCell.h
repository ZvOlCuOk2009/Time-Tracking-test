//
//  TableViewCell.h
//  Time Tracking test
//
//  Created by Admin on 02.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *taskLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end
