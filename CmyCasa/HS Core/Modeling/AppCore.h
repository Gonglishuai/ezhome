//
//  AppCore.h
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DesignsManager.h"
#import "CommentsManager.h"
#import "HomeManager.h"
#import "ProfessionalDO.h"
#import "ProfsManager.h"
#import "GalleryStreamManager.h"

#import "ProfsManager.h"
#import "ProfProjects.h"
#import "ProfessionalDO.h"
#import "DesignBaseClass.h"
#import "RKObjectManager.h"
#import "ImagesInfo.h"
@protocol HSSplashScreen <NSObject>

- (void)showApp;

@end

@interface AppCore : NSObject <NSCoding>
{
    ProfsManager * _profsMan;
    GalleryStreamManager * _galMan;
     CommentsManager * _comMan;
    HomeManager * _homeMan;
}

+(AppCore *)sharedInstance;
-(ProfsManager*)getProfsManager;
-(GalleryStreamManager*)getGalleryManager;
-(CommentsManager*)getCommentsManager;
-(HomeManager*)getHomeManager;
-(void)load;
-(void)save;
-(void)clearApplicationCache;
-(void)logoutUser;
+(void)setupRestkit:(NSDictionary*)config;
-(BOOL)needCacheRefreshForHomeScreenImage:(ImageInfo*)img;
-(void)InitializeContent:(UIViewController<HSSplashScreen>*) splash;
-(void)Initialize;
-(BOOL)backgroundImagesAvailable;

@property(nonatomic)GalleryStreamManager * _galMan;
@property(nonatomic)DesignsManager * _designsMan;
@property(nonatomic)ProfsManager * _profsMan;
@property(nonatomic)CommentsManager * _comMan;
@property(nonatomic)HomeManager * _homeMan;
@property(nonatomic)NSMutableArray * _allcomments;
@property(nonatomic, strong) NSArray* appBackgrounds;

@property(nonatomic,strong,class) RKObjectManager * httpRKManager;
@property(nonatomic,strong,class) RKObjectManager * httpsRKManager;
@property(nonatomic,strong,class) RKObjectManager * httpsCloudlessRKManager;
@property(nonatomic,strong,class) RKObjectManager * httpCloudlessRKManager;
@property(nonatomic,strong,class) RKObjectManager * httpRKManagerV2;
@property(nonatomic,strong,class) RKObjectManager * httpCloudlessRKManagerV2;
@property(nonatomic,strong,class) RKObjectManager * httpSSORKManager;

@end
