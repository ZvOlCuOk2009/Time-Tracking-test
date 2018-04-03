//
//  CALayer+IBConfiguration.m
//  Time Tracking test
//
//  Created by Admin on 03.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "CALayer+IBConfiguration.h"

@implementation CALayer (IBConfiguration)

- (void)setBorderColorIB:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

- (UIColor *)borderColorIB
{
    return [UIColor colorWithCGColor:self.borderColor];
}

- (void)setShadowColorIB:(UIColor *)color
{
    self.shadowColor = color.CGColor;
}

- (UIColor *)shadowColorIB
{
    return [UIColor colorWithCGColor:self.shadowColor];
}

@end
