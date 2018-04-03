//
//  AppDelegate.h
//  Time Tracking test
//
//  Created by Admin on 02.04.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

@end

