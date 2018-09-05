//
//  UserDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RestkitObjectProtocol.h"

#define USER_DETAIL_ROW_TYPE_KEY @"row_type"
#define USER_DETAIL_ROW_TYPE_VALUE @"value"
#define USER_DETAIL_ROW_TITLE @"row_title"
#define USER_DETAIL_ROW_ICON  @"row_icon"
#define USER_DETAIL_TEMP_IMAGE @"temp_image"
#define USER_DETAIL_COMBO_TYPE @"combo_type"
#define USER_DETAIL_DATA_MODEL_FIELD @"field_type"
#define USER_TYPE_VALUE @"user_details_user_type"

@class UserExtendedDetails;

typedef  enum UserTypes{
    kUserTypeEmail = 0,
    kUserTypeFacebook,
    kUserTypeWebLogin,
    kUserTypePhone
} UserType;


typedef enum UserViewFields{

    kComboUnknown           = -1,
    kFieldFirstName         = 0,
    kFieldLastName          = 1,
    kFieldLocation          = 2,
    kFieldWebsite           = 3,
    kFieldInterests         = 4,
    kFieldGender            = 5,
    kFieldFullName          = 6,
    kFieldDescription       = 7,
    kFieldUserTypes         = 8,
    kFieldProfessions       = 9,
    kFieldDesignTools       = 10,
    kFieldFavoriteStyles    = 11,
    KFieldControls          = 12,
    kFieldProfileImage      = 13,    
}UserViewField;

typedef enum UserDetailFieldTypes{
    
    KUDfieldTextfield               = 0, //one text field
    KUDfieldLongText                = 1,  //one text view
    KUDfieldComposite2Texts         = 2, //two text fields
    KUDfieldGenderSelection         = 3, //gender field
    KUDfieldUserProfile             = 5, //user profile field
    KUDfieldTextfieldWithAction     = 6, //user text field with action drop dow,
    KUDfieldWebLink                 = 7,
    KUDfieldReadLabelText           = 8,
    KUDfieldReadDynamicLabelText    = 9,
    KUDControls                     = 10,
    KUDLocation                     = 11,
    KUDfieldUserProfileIphone       = 12,
    KUDfieldReadOnlyIcon            = 13,
    KUDfieldFullNameAndProfession   = 14,
    
}UserDetailFieldType;


@interface UserDO : BaseResponse <NSCoding, NSCopying>
@property(nonatomic,strong) NSString * firstName;
@property(nonatomic,strong) NSString * lastName;
@property(nonatomic,strong) NSString * userID;
@property(nonatomic,strong) NSString * userEmail;
@property(nonatomic,strong) NSString * userProfession;// Currently Not Used
@property(nonatomic,strong) NSString * sessionId;
@property(nonatomic,strong) NSString * umsToken;
@property(nonatomic,strong) NSString * userPassword;
@property(nonatomic,strong) NSString * userPhone;
@property(nonatomic,strong) NSString * userProfileImage;
@property(nonatomic,strong) NSString * userDescription;
@property(nonatomic,strong) NSString * serverUserType;
@property(nonatomic,strong) NSString * webLoginExternalSessionId;
@property(nonatomic,strong) UserExtendedDetails * extendedDetails;
@property(nonatomic) UserType usertype;
@property(nonatomic) BOOL allowEmails;
@property(nonatomic) BOOL isProfessional;
@property(nonatomic) BOOL termsAccepted;

#pragma mark- Edit Profile temp fields
@property(nonatomic,strong) UIImage * tempEditProfileImage;


-(void)updateLocalUserDataAfterMetaUpdate:(UserDO*)deltaUser;
-(NSString*)getUserFullName;

-(NSMutableDictionary*)generateUpdateJsonDictionary;
-(NSMutableArray*)getUserProfileDetails:(BOOL)editMode;

-(void)updateLocationWithLocation:(CLLocation*)location
                       andAddress:(CLPlacemark*)addressMark;

-(id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToADo:(UserDO *)aDo;

- (NSUInteger)hash;

@end

@interface SSODO : BaseResponse <RestkitObjectProtocol>
@property(nonatomic,strong) NSString * accessToken;
@property(nonatomic,strong) NSString * uid;
@property(nonatomic,strong) NSString * memberId;
@property(nonatomic,strong) NSString * memberType;
@property(nonatomic,strong) NSString * userName;
@property(nonatomic,strong) NSString * avatar;
@property(nonatomic,strong) NSString * nickName;
@property(nonatomic,strong) NSString * nimToken;
@end

@interface PasswordDO : BaseResponse <RestkitObjectProtocol>
@end
