//
//  CloudFrontCacheMap.h
//  Homestyler
//
//  Created by Berenson Sergei on 3/28/13.
//
//

#import <Foundation/Foundation.h>

@interface CloudFrontCacheMap : NSObject



-(id)initWithDict:(NSMutableDictionary*)dict;
- (void)saveCustomObject;
+ (CloudFrontCacheMap *)loadCustomObject;
@property(nonatomic)NSString * getCommentsCacheTimeoutMins;
@property(nonatomic)NSMutableDictionary * commentsCacheMap;
@property(nonatomic)NSMutableDictionary * saveDesignsMap;

-(NSString*)generateRequestTimestampForDesignID:(NSString*)designID;
-(NSString*)getRequestTimestampForDesignID:(NSString*)designID;

@end
