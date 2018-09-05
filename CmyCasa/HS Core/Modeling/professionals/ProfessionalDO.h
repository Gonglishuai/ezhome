//
//  ProfessionalDO.h
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
@class ProfProjects;
@class ProfProjectAssetDO;

@interface ProfessionalDO : BaseResponse<NSCoding,RestkitObjectProtocol>


#pragma mark- Internal properties
@property(nonatomic) BOOL isExtraInfoLoaded;

@property(nonatomic) NSNumber * isFollowed;

#pragma mark- API properties
@property(nonatomic) NSString * _description;
@property(nonatomic) NSString * firstName;
@property(nonatomic) NSString * lastName;

@property(nonatomic,strong) NSString * fn;//TODO: TEMP FOR NEW SLIM API,REMOVE BEFORE PRODUCTION
@property(nonatomic,strong) NSString * ln;//TODO: TEMP FOR NEW SLIM API,REMOVE BEFORE PRODUCTION
@property(nonatomic,strong) NSString * ph;//TODO: TEMP FOR NEW SLIM API,REMOVE BEFORE PRODUCTION

@property(nonatomic,strong) NSArray * locations;
@property(nonatomic,strong) NSString * thumbnail;
@property(nonatomic,strong) NSArray * professions;
@property(nonatomic,strong) NSString * userPhoto;
@property(nonatomic,strong) NSString * _id;
@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) NSNumber * likesCount;


@property(nonatomic,strong) NSString * web;
@property(nonatomic) NSString * email;
@property(nonatomic,strong) NSString * phone1;
@property(nonatomic,strong) NSString * phone2;
@property(nonatomic) NSString * address;
@property(nonatomic) NSString * posterImage;
@property(nonatomic) NSMutableArray * projects;
@property(nonatomic) NSMutableArray * imageAssets;
-(ProfProjectAssetDO*)findDesignInProfProjectsByID:(NSString*)designId;
-(id)initWithDict:(NSDictionary*)dict;
-(void)updateAdditionalInfoAboutProf:(NSDictionary*)dict;
-(BOOL)isFollowedByUser;
-(NSString*)getFullName;
@end










