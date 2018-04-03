//
//  TableViewCell.m
//  Time Tracking test
//
//  Created by Admin on 02.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "TSTableViewCell.h"

@implementation TSTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // set font size
    
    if (self.frame.size.width > 320) {
        self.taskLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f];
        self.descriptLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f];
    } else {
        self.taskLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
        self.descriptLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
