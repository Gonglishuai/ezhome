//
//  ProfProjectDO.h
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
@class ProfProjectAssetDO;

@interface ProfProjects : NSObject <NSCoding,RestkitObjectProtocol>



@property(nonatomic)NSMutableArray * projectAssets;
@property(nonatomic)NSString * projectId;
@property(nonatomic)NSString * projectName;
-(void)updateProjectAuthorImageURL:(NSString*)url  andProfID:(NSString*)profid  andProfName:(NSString*)pname;
-(id)initWithDict:(NSDictionary*)dict  andProfID:(NSString*)profid;
@end
