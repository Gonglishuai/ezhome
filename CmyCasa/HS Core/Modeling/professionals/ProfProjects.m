//
//  ProfProjectDO.m
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//
//

#import "ProfProjects.h"
#import "ProfProjectAssetDO.h"
@interface ProfProjects ()


@end

@implementation ProfProjects
@synthesize projectAssets;
@synthesize  projectId;
@synthesize  projectName;

+ (RKObjectMapping*)jsonMapping
{
    
    RKObjectMapping* entityMapping =  [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"projectId",
     @"name" : @"projectName"
     }];
    

    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"assets"
                                                 toKeyPath:@"projectAssets"
                                               withMapping:[ProfProjectAssetDO jsonMapping]]];
    
    
    
    
    return entityMapping;
}

- (void)applyPostServerActions
{
    
    
    for (int i=0; i<[self.projectAssets count]; i++) {
        [[self.projectAssets objectAtIndex:i] applyPostServerActions];
    }
    
}
-(id)initWithDict:(NSDictionary*)dict andProfID:(NSString*)profid{
    self=[super init];
    self.projectAssets=[NSMutableArray arrayWithCapacity:0];
   
    
    self.projectId=[dict objectForKey:@"id"];
    self.projectName=[dict objectForKey:@"name"];
    
    NSArray * ar=[dict objectForKey:@"assets"];
    
    for (int i=0; i<[ar count]; i++) {
        ProfProjectAssetDO * ass=[[ProfProjectAssetDO alloc] initWithDict:[ar objectAtIndex:i] andProfID :profid];
        ass.uthumb=[dict objectForKey:@"prof_image_url"];
        [self.projectAssets addObject:ass];
      
    }
    
    
    return self;
}
-(void)updateProjectAuthorImageURL:(NSString*)url andProfID:(NSString*)prid andProfName:(NSString*)pname{
    
    for (int i=0; i<[self.projectAssets count]; i++) {
        ProfProjectAssetDO * ass=[self.projectAssets objectAtIndex:i];
        [ass updateProfessionalID:prid andThumbnail:url andProfName:pname];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

@end
