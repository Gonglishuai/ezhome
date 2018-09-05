//
//  FollowUserInfo.m
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import "FollowUserInfo.h"

@implementation FollowResponse

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];

    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"count" : @"total"
       }];

    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"miniUserList"
                                                 toKeyPath:@"followList"
                                               withMapping:[FollowUserInfo jsonMapping]]];
    
    return entityMapping;
}

@end

@implementation FollowUserInfo

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
         @"userid" : @"userId",
         @"firstname" : @"firstName",
         @"lastname" : @"lastName",
         @"description" : @"userDescription",
         @"typename" : @"userTypeName",
         @"avatar" : @"photoUrl",
         @"isfollowed" : @"isFollowed"
     }];

    return entityMapping;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class])
    {
        return ([((FollowUserInfo*)object).userId isEqualToString:self.userId]);
    }
    return NO;
}

- (void)createSeparateNamesFromFullName:(NSString *)name {

    if(!name)return;

    NSArray * components=[name componentsSeparatedByString:@" "];
    if (components && [components count]>0){
        NSString * first=[components  objectAtIndex:0];
        self.firstName = (first)?first:@"";

        if ([components count] > 1)
        {
            NSRange firstRange=[name rangeOfString:first];
            if(firstRange.location!=NSNotFound){
                NSString * last=[name substringFromIndex:firstRange.location+firstRange.length+1];
                self.lastName = (last)?last:@"";
            }
        }
    }
}

-(NSString*)getUserFullName{

    NSString * fname=self.firstName;
    NSString * lname=self.lastName;
    NSString* fullname=@"";
    if ([fname length]==0 && [lname length]==0) {


    }else if ([fname length]!=0 && [lname length]==0)
        fullname=[NSString stringWithFormat:@"%@",fname];
    else if([fname length]==0 && [lname length]!=0)
        fullname=[NSString stringWithFormat:@"%@",lname];
    else
        fullname=[NSString stringWithFormat:@"%@ %@",fname, lname];

    return fullname;
}

@end
