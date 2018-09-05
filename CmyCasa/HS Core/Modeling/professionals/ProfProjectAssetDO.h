//
//  ProfProjectAssetDO.h
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DesignBaseClass.h"
#import "RestkitObjectProtocol.h"
@interface ProfProjectAssetDO : DesignBaseClass<NSCoding,RestkitObjectProtocol>



@property(nonatomic)NSNumber * rank;

-(void)updateProfessionalID:(NSString*)prid andThumbnail:(NSString*)thumbnail  andProfName:(NSString*)pname;
-(id)initWithDict:(NSDictionary*)dict andProfID:(NSString*)profid;
@end
