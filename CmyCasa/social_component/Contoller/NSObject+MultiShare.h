//
//  NSObject+MultiShare.h
//  Homestyler
//
//  Created by Ma'ayan on 10/28/13.
//
//

#import <Foundation/Foundation.h>
#import "HSShareObject.h"
@interface NSObject (MultiShare)


- (void)startSharingProccessWithMessage:(HSShareObject*)shareObj;

- (NSString *)stringFromItemType:(ItemType)type;

@end
