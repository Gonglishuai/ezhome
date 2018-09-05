//
//  ProfessionalDO.m
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import "ProfessionalDO.h"
#import "ProfProjects.h"
@implementation ProfessionalDO
@synthesize  _description;
@synthesize firstName;
@synthesize lastName;
@synthesize locations;
@synthesize thumbnail;
@synthesize professions;
@synthesize userPhoto;
@synthesize _id;
@synthesize likesCount;
@synthesize name;

@synthesize web;
@synthesize email;
@synthesize phone1;
@synthesize phone2;
@synthesize address;
@synthesize posterImage;
@synthesize projects;


@synthesize isFollowed;
@synthesize isExtraInfoLoaded;



+ (RKObjectMapping*)jsonMapping
{
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"_id",
     @"d" : @"_description",
     @"fn" : @"fn",
     @"ln" : @"ln",
     @"ph" : @"ph",
    @"firstname" : @"firstName",
     @"lastname" : @"lastName",
     @"loc" : @"locations",
     @"thumb" : @"thumbnail",
     @"prof" : @"professions",
     @"userphoto" : @"userPhoto",
     @"n" : @"name",
     @"likes" : @"likesCount",
      @"web" : @"web",
      @"email" : @"email",
      @"p1" : @"phone1",
      @"p2" : @"phone2",
      @"add" : @"address",
      @"img" : @"posterImage",
     @"pcnt" : @"productsCount",
     @"assets" :@"imageAssets"
     }];
    
    
  
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"projs"
                                                 toKeyPath:@"projects"
                                               withMapping:[ProfProjects jsonMapping]]];
    

    
    
    
    return entityMapping;
}

- (void)applyPostServerActions
{
    //TODO: SERGEY - check if it sufficient to detect full/basic prof info
    if (self.projects==nil) {
        self.isExtraInfoLoaded=NO;
    }else{
        self.isExtraInfoLoaded=YES;
    }
    //TODO: REMOVE ONCE PRODUCTION UPDATED
    if (self.fn) {
        self.firstName=self.fn;
    }
    if (self.ln) {
        self.lastName=self.ln;
    }
    if (self.ph) {
        self.userPhoto=self.ph;
    }
    
    BOOL res = [[[AppCore sharedInstance]getProfsManager]isProfessionalFollowed:self._id];
    self.isFollowed=[NSNumber numberWithBool:res];
 
    if (self.projects) {
        for (int i=0; i<[self.projects count]; i++) {
            ProfProjects * prj=[self.projects objectAtIndex:i];
            [prj updateProjectAuthorImageURL:self.userPhoto//self.thumbnail
                                   andProfID:self._id
                                 andProfName:[self getFullName]];
            
            [prj applyPostServerActions];
        }
    }
}

-(id)initWithDict:(NSDictionary*)dict{
    self=[super init];

  
    self.isExtraInfoLoaded=NO;
    
    self._description=[dict objectForKey:@"d"];
    self.firstName=[dict objectForKey:@"firstname"];
    self.lastName=[dict objectForKey:@"lastname"];
    self.locations=[dict objectForKey:@"loc"];
    self.thumbnail=[dict objectForKey:@"thumb"];
    self.professions=[dict objectForKey:@"prof"];
    self.userPhoto=[dict objectForKey:@"userphoto"];
    self._id=[dict objectForKey:@"id"];
    self.name=[dict objectForKey:@"n"];
    self.likesCount=[dict objectForKey:@"likes"];
    
    
    BOOL res = [[[AppCore sharedInstance]getProfsManager]isProfessionalFollowed:self._id];
    self.isFollowed=[NSNumber numberWithBool:res];
    
    //additions for full professional data
    return self;
}

-(void)updateAdditionalInfoAboutProf:(NSDictionary*)dict{
    
    self.isExtraInfoLoaded=YES;
    self.web=[dict objectForKey:@"web"];
    self.email=[dict objectForKey:@"email"];
    self.phone1=[dict objectForKey:@"p1"];
    self.phone2=[dict objectForKey:@"p2"];
    self.address=[dict objectForKey:@"add"];
    self.posterImage=[dict objectForKey:@"img"];
    

    self.projects=[NSMutableArray arrayWithCapacity:0];
    
    NSArray * ar=[dict objectForKey:@"projs"];
    
    for (int i=0; i<[ar count]; i++) {
        
        NSMutableDictionary * dd=[[ar objectAtIndex:i] mutableCopy];
        
        [dd setObject:self.thumbnail forKey:@"prof_image_url"];
        ProfProjects * prj=[[ProfProjects alloc] initWithDict:dd  andProfID:self._id];
        [self.projects addObject:prj];
        [prj updateProjectAuthorImageURL:self.thumbnail  andProfID:self._id  andProfName:[self getFullName]];
  
    }
    

}


-(NSString*)getFullName{
    
  
    
    if ([self.firstName length]>0 && [self.lastName length]>0) {
        return [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
    }
    if ([self.firstName length]==0 && [self.lastName length]>0) {
        return [NSString stringWithFormat:@"%@",self.lastName];
    }
    if ([self.firstName length]>0 && [self.lastName length]==0) {
        return [NSString stringWithFormat:@"%@",self.firstName];
    }
    
    return @"";
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

-(ProfProjectAssetDO*)findDesignInProfProjectsByID:(NSString*)designId{
    
    for (int i=0; i<[self.projects count]; i++) {
        ProfProjects * proj=[self.projects objectAtIndex:i];
        for (int j=0;j<[proj.projectAssets count];j++){
            if ([[[proj.projectAssets objectAtIndex:j] _id]isEqualToString:designId]) {
                return [proj.projectAssets objectAtIndex:j];
            }
            
        }
    }
    
    return nil;
}

-(BOOL)isFollowedByUser{
    
    BOOL res = [[[AppCore sharedInstance]getProfsManager]isProfessionalFollowed:self._id];
    self.isFollowed = [NSNumber numberWithBool:res];
    
    if (isFollowed) {
        return [isFollowed boolValue];
    }
    
    return NO;
}
@end
