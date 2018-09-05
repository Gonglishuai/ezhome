//
//  CatalogGroupDO.h
//  Homestyler
//
//  Created by Dan Baharir on 3/26/15.
//
//

#import <Foundation/Foundation.h>

@interface CatalogGroupDO : NSObject  <RestkitObjectProtocol>

@property(nonatomic,strong) NSString * groupName;
@property(nonatomic,strong) NSString * groupId;
@property(nonatomic,strong) NSString * groupLogo;
@property(nonatomic,strong) NSString * groupParentId;

+ (RKObjectMapping*)jsonMapping;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
