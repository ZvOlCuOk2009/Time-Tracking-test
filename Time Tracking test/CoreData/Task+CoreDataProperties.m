//
//  Task+CoreDataProperties.m
//  Time Tracking test
//
//  Created by Admin on 02.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//
//

#import "Task+CoreDataProperties.h"

@implementation Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Task"];
}

@dynamic name;
@dynamic descript;
@dynamic time;

@end
