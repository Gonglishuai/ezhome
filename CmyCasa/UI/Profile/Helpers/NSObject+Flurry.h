//
//  NSObject+Flurry.h
//  Homestyler
//
//  Created by Yiftach Ringel on 23/06/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Flurry)

- (void)logFlurryEvent:(NSString*)event;
- (void)logFlurryEvent:(NSString*)event withParams:(NSDictionary*)params;

@end
