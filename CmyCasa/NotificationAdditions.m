//
//  NotificationAdditions.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "NotificationAdditions.h"
#import <pthread.h>

//guarenties that the notification is posted on the main thread

@implementation NSNotificationCenter (BHNotificationCenterAdditions)
- (void)postNotificationOnMainThread:(NSNotification *)notification
{
	if (pthread_main_np())
		return [self postNotification:notification];
	[[self class] performSelectorOnMainThread:@selector(_postNotification:) withObject:notification waitUntilDone:NO];
}

+ (void)_postNotification:(NSNotification *) notification
{
	[[self defaultCenter] postNotification:notification];
}


@end
