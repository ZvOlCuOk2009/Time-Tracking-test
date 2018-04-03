//
//  NSString+TSString.m
//  Time Tracking test
//
//  Created by Admin on 03.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "NSString+TSString.h"

@implementation NSString (TSString)

+ (NSString *)currentTime:(NSInteger)counter
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"hh:mm:ss";
    NSTimeInterval theTimeInterval = counter;
    NSDate *eventDate = [NSDate dateWithTimeIntervalSinceNow:theTimeInterval];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger units = NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:units fromDate:[NSDate date] toDate: eventDate options:0];
    
    NSString *seconds = [NSString stringWithFormat:@"%ld", [components second]];
    NSString *minutes = [NSString stringWithFormat:@"%ld", [components minute]];
    NSString *hours =[NSString stringWithFormat:@"%ld", [components hour]];
    
    if (seconds.length == 1) {
        seconds = [NSString stringWithFormat:@"0%@", seconds];
    }
    
    if (minutes.length == 1) {
        minutes = [NSString stringWithFormat:@"0%@", minutes];
    }
    
    if (hours.length == 1) {
        hours = [NSString stringWithFormat:@"0%@", hours];
    }
    return [NSString stringWithFormat:@"%@:%@:%@", hours, minutes, seconds];
}

@end
