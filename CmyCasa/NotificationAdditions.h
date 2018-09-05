//
//  NotificationAdditions.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//f

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (BHNotificationCenterAdditions)

- (void)postNotificationOnMainThread:(NSNotification *)notification;

@end
