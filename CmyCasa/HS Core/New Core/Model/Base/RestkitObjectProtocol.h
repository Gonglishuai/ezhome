//
//  RestkitObjectProtocol.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <Foundation/Foundation.h>
#import "RestKit.h"

@protocol RestkitObjectProtocol <NSObject>

+ (RKObjectMapping*)jsonMapping;

@optional

- (void)applyPostServerActions;

@end
