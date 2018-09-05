//
//  UserBaseFriendDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "UserBaseFriendDO.h"
#import "NSString+EmailValidation.h"
@implementation UserBaseFriendDO



+ (RKObjectMapping*)jsonMapping{
 
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"_id",
     @"firstname" : @"firstName",
     @"lastname" : @"lastName",
     @"photo" : @"picture",
     @"e" :@"email",
     }];
    
    
    
    return entityMapping;
}



- (void)applyPostServerActions{
    
    if (self.firstName) {
        self.fullName=self.firstName;
    }
    if (self.lastName) {
        if (self.fullName) {
            self.fullName=[NSString stringWithFormat:@"%@ %@",self.fullName,self.lastName];
        }else{
            self.fullName=self.lastName;
        }
    }
    
}

-(BOOL)compareFriendToFollowingUser:(FollowUserInfo*)following{
    
    return [self._id isEqualToString:following.userId];
}

-(id)initWithFacebookDictionary:(NSDictionary*)dict{
    
    self=[super init];
    self.currentStatus=kFriendUnknown;
    
    if ([dict objectForKey:@"first_name"]) {
        self.firstName=[dict objectForKey:@"first_name"];
    }
    if ([dict objectForKey:@"last_name"]) {
        self.lastName=[dict objectForKey:@"last_name"];
    }
    if ([dict objectForKey:@"id"]) {
        self._id=[dict objectForKey:@"id"];
        
        self.picture=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",self._id];
    }
    if ([dict objectForKey:@"installed"]) {
        self.isHSUser=[[dict objectForKey:@"installed"] boolValue];
    }
   
    self.isFacebookFriend=YES;
    
    return self;
}

-(UIImage*)getLocalImage{
    return nil;
}


-(NSString*)getFullName{

    
    if ([self.firstName length]>0 && [self.lastName length]>0) {
        return [NSString stringWithFormat:@"%@ %@ ",self.firstName,self.lastName];
    }
    if ([self.firstName length]>0 && [self.lastName length]==0) {
        return self.firstName;
    }
    if ([self.firstName length]==0 && [self.lastName length]>0) {
        return self.lastName;
    }

    return @"";
}

@end












