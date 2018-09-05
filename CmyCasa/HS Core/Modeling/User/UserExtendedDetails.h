//
//  UserExtendedDetails.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"

@class UserComboDO;


@interface UserExtendedDetails : NSObject<RestkitObjectProtocol, NSCopying,NSCoding, NSCoding, NSCoding, NSCoding>

@property(nonatomic,strong) UserComboDO * gender;
@property(nonatomic,strong) UserComboDO * userType;

@property(nonatomic,strong) NSString * website;
@property(nonatomic,strong) NSString * location;//free text of user location
@property(nonatomic) BOOL locationVisible;
@property(nonatomic)        NSInteger viewCount;

@property(nonatomic,strong) NSMutableArray * proffessions;
@property(nonatomic,strong) NSMutableArray * favoriteStyles;
@property(nonatomic,strong) NSString * interests;
@property(nonatomic,strong) NSMutableArray * designingTools;

@property(nonatomic) BOOL locationStatusChanged;
#pragma mark -Temp data Fields for Profile update
@property(nonatomic,strong) CLLocation * gpsLocation;
@property(nonatomic,strong) CLPlacemark * gpsAddress;

-(NSMutableDictionary*)generateUpdateJsonDictionary;
-(void)updateLocalUserDataAfterMetaUpdate:(UserExtendedDetails*)deltaExtended;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToDetails:(UserExtendedDetails *)details;

- (NSUInteger)hash;



@end
