//
//  UserExtendedDetails.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import "UserExtendedDetails.h"
#import "UserComboDO.h"

@interface UserExtendedDetails ()

-(NSMutableArray * )generateComboListForArray:(NSMutableArray *)list;
@end


@implementation UserExtendedDetails
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.viewCount = [coder decodeIntForKey:@"self.viewCount"];
        self.locationVisible = [coder decodeBoolForKey:@"self.locationVisible"];
        self.gender = [coder decodeObjectForKey:@"self.gender"];
        self.userType = [coder decodeObjectForKey:@"self.userType"];
        self.website = [coder decodeObjectForKey:@"self.website"];
        self.location = [coder decodeObjectForKey:@"self.location"];
        self.proffessions = [coder decodeObjectForKey:@"self.proffessions"];
        self.interests = [coder decodeObjectForKey:@"self.interests"];
        self.designingTools = [coder decodeObjectForKey:@"self.designingTools"];

    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.viewCount forKey:@"self.viewCount"];
    [coder encodeBool:self.locationVisible forKey:@"self.locationVisible"];
    [coder encodeObject:self.gender forKey:@"self.gender"];
    [coder encodeObject:self.userType forKey:@"self.userType"];
    [coder encodeObject:self.website forKey:@"self.website"];
    [coder encodeObject:self.location forKey:@"self.location"];
    [coder encodeObject:self.proffessions forKey:@"self.proffessions"];
    [coder encodeObject:self.interests forKey:@"self.interests"];
    [coder encodeObject:self.designingTools forKey:@"self.designingTools"];

}



+ (RKObjectMapping*)jsonMapping
{
    
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     //  @"gender" : @"gender",
       @"location" : @"location",
       @"site" : @"website",
      // @"utype" : @"userType",
       @"interest": @"interests",
       @"vCount": @"viewCount",
       @"showLoc" : @"locationVisible"
       
       }];
    
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"prof"
                                                 toKeyPath:@"proffessions"
                                               withMapping:[UserComboDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"styles"
                                                 toKeyPath:@"favoriteStyles"
                                               withMapping:[UserComboDO jsonMapping]]];
   
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"tools"
                                                 toKeyPath:@"designingTools"
                                               withMapping:[UserComboDO jsonMapping]]];
    
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"gender"
                                                 toKeyPath:@"gender"
                                               withMapping:[UserComboDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"utype"
                                                 toKeyPath:@"userType"
                                               withMapping:[UserComboDO jsonMapping]]];
    
    
    
    return entityMapping;
}

-(void)applyPostServerActions{
    
    NSLog(@"");
    
}

- (id)copyWithZone:(NSZone *)zone {
    UserExtendedDetails *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.gender = self.gender;
        copy.userType = self.userType;
        copy.website = self.website;
        copy.location = self.location;
        copy.locationVisible = self.locationVisible;
        copy.viewCount = self.viewCount;
        copy.proffessions = self.proffessions;
        copy.favoriteStyles = self.favoriteStyles;
        copy.interests = self.interests;
        copy.designingTools = self.designingTools;
        copy.gpsLocation = self.gpsLocation;
        copy.gpsAddress = self.gpsAddress;
    }

    return copy;
}

-(NSMutableDictionary*)generateUpdateJsonDictionary{
    
    NSMutableDictionary * response=[NSMutableDictionary dictionary];
  /*
   NSMutableDictionary * response=[NSMutableDictionary dictionary];
   NSMutableDictionary * response=[NSMutableDictionary dictionary];
   
   */
    
    if (self.gender) {
         NSDictionary * dict=@{@"id":self.gender.comboId,@"desc":self.gender.comboName};
      [response setObject:dict forKey:@"gender"];
    }else{
        [response setObject:[NSNull null] forKey:@"gender"];
    }

   
    [response setObject:(self.location!=nil)?self.location:[NSNull null] forKey:@"loc"];
    
    if (self.userType) {
        NSDictionary * dict=@{@"id":self.userType.comboId,@"desc":self.userType.comboName};
        [response setObject:dict forKey:@"utype"];

    }else{
        [response setObject:[NSNull null] forKey:@"utype"];
    }
   
    
    [response setObject:(self.website!=nil)?self.website:[NSNull null] forKey:@"site"];
   

    NSMutableArray * profs=[self generateComboListForArray:self.proffessions];
    [response setObject:(profs!=nil)?profs:[NSNull null] forKey:@"prof"];


    NSMutableArray * favoriteStyles=[self generateComboListForArray:self.favoriteStyles];
    [response setObject:(favoriteStyles!=nil)?favoriteStyles:[NSNull null] forKey:@"styles"];

    NSMutableArray * designTools=[self generateComboListForArray:self.designingTools];
    [response setObject:(designTools!=nil)?designTools:[NSNull null] forKey:@"tools"];


    [response setObject:(self.interests!=nil)?self.interests:[NSNull null] forKey:@"interest"];


    
    [response setObject:(self.location!=nil)?self.location:[NSNull null] forKey:@"location"];
    [response setObject:(self.gpsLocation)?[NSString stringWithFormat:@"%f/%f",self.gpsLocation.coordinate.latitude,self.gpsLocation.coordinate.longitude]:[NSNull null] forKey:@"coord"];
   
    [response setObject:[NSNumber numberWithBool:self.locationVisible] forKey:@"showLoc" ];
     
 
    
    [response setObject:(self.gpsAddress.country)?self.gpsAddress.country:[NSNull null] forKey:@"country"];
    [response setObject:(self.gpsAddress.locality)?self.gpsAddress.locality:[NSNull null] forKey:@"city"];
    [response setObject:(self.gpsAddress.administrativeArea)?self.gpsAddress.administrativeArea:[NSNull null] forKey:@"state"];
    
    

    return response;
}

-(NSMutableArray * )generateComboListForArray:(NSMutableArray *)list{

    NSMutableArray * profItems;
    profItems = [NSMutableArray array];

    for (int j = 0; j < [list count]; j++) {

        UserComboDO * cbo=[list objectAtIndex:j];
        NSDictionary * dict;
        if ([cbo.comboId isEqualToString:cbo.comboName]) {
            dict=@{@"id":@"",@"desc":cbo.comboName};
        }else{
            dict=@{@"id":cbo.comboId,@"desc":cbo.comboName};
        }
        [profItems addObject:dict];
    }
    return (profItems.count>0)?profItems:nil;

}
-(void)updateLocalUserDataAfterMetaUpdate:(UserExtendedDetails*)deltaExtended{
    
    if (deltaExtended.userType) {
        self.userType=[deltaExtended.userType copy];
    }
    if (deltaExtended.gender) {
        self.gender=[deltaExtended.gender copy];
    }
    
    if (deltaExtended.website) {
        self.website=[deltaExtended.website copy];
    }
    if (deltaExtended.locationStatusChanged) {
        self.location=[deltaExtended.location copy];
        self.locationVisible=deltaExtended.locationVisible;
    }
    if (deltaExtended.proffessions) {
        self.proffessions=[deltaExtended.proffessions copy];
    }
    if (deltaExtended.favoriteStyles) {
        self.favoriteStyles=[deltaExtended.favoriteStyles copy];
    }
    if (deltaExtended.interests) {
        self.interests=[deltaExtended.interests copy];
    }
    if (deltaExtended.designingTools) {
        self.designingTools=[deltaExtended.designingTools copy];
    }
    if (deltaExtended.gpsLocation) {
        self.gpsLocation=[deltaExtended.gpsLocation copy];
    }
    
    if (deltaExtended.gpsAddress) {
        self.gpsAddress=[deltaExtended.gpsAddress copy];
    }
    
    if (deltaExtended.location) {
        self.location = [deltaExtended.location copy];
        self.locationVisible = YES;
    }
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToDetails:other];
}

- (BOOL)isEqualToDetails:(UserExtendedDetails *)details {
    if (self == details)
        return YES;
    if (details == nil)
        return NO;
    if (self.gender != details.gender && ![self.gender isEqualToADo:details.gender])
        return NO;
    if (self.userType != details.userType && ![self.userType isEqualToADo:details.userType])
        return NO;
    if (self.website != details.website && ![self.website isEqualToString:details.website])
        return NO;
    if (self.location != details.location && ![self.location isEqualToString:details.location])
        return NO;
    if (self.locationVisible != details.locationVisible)
        return NO;
    if (self.viewCount != details.viewCount)
        return NO;
    if (self.proffessions != details.proffessions && ![self.proffessions isEqualToArray:details.proffessions])
        return NO;
    if (self.favoriteStyles != details.favoriteStyles && ![self.favoriteStyles isEqualToArray:details.favoriteStyles])
        return NO;
    if (self.interests != details.interests && ![self.interests isEqualToString:details.interests])
        return NO;
    if (self.designingTools != details.designingTools && ![self.designingTools isEqualToArray:details.designingTools])
        return NO;
    if (self.gpsLocation != details.gpsLocation && ![self.gpsLocation isEqual:details.gpsLocation])
        return NO;
    if (self.gpsAddress != details.gpsAddress && ![self.gpsAddress isEqual:details.gpsAddress])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.gender hash];
    hash = hash * 31u + [self.userType hash];
    hash = hash * 31u + [self.website hash];
    hash = hash * 31u + [self.location hash];
    hash = hash * 31u + self.locationVisible;
    hash = hash * 31u + self.viewCount;

    for (int j = 0; j < self.proffessions.count; j++) {
        hash = hash * 31u + [self.proffessions[j] hash];

    }
  //  hash = hash * 31u + [self.favoriteStyles hash];
    for (int j = 0; j < self.favoriteStyles.count; j++) {
        hash = hash * 31u + [self.favoriteStyles[j] hash];

    }
    hash = hash * 31u + [self.interests hash];
   // hash = hash * 31u + [self.designingTools hash];
    for (int j = 0; j < self.designingTools.count; j++) {
        hash = hash * 31u + [self.designingTools[j] hash];

    }
    hash = hash * 31u + [self.gpsLocation hash];
    hash = hash * 31u + [self.gpsAddress hash];
    return hash;
}


@end
