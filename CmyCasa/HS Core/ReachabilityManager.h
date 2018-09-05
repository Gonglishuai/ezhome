//  Copyright (c) 2008 by Autodesk, Inc.
//  All rights reserved.
//
//  The information contained herein is confidential and proprietary to
//  Autodesk, Inc., and considered a trade secret as defined under civil
//  and criminal statutes.  Autodesk shall pursue its civil and criminal
//  remedies in the event of unauthorized use or misappropriation of its
//  trade secrets.  Use of this information by anyone other than authorized
//  employees of Autodesk, Inc. is granted only under a written non-
//  disclosure agreement, expressly prescribing the scope and manner of
//  such use.
//
//  Written by Avihay Assouline 09/01/2014
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ReachabilityManager : NSObject

#pragma mark - Singleton implementation

+ (id)sharedInstance;

///////////////////////////////////////////////////////
//                  PROPERTIES                       //
///////////////////////////////////////////////////////

@property (atomic) BOOL isConnentionAvailable;
@property (nonatomic) NetworkStatus connectionType;
-(NSString *)currentNetworkState;
@end
