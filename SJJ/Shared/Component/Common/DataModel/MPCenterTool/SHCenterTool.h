
#import <Foundation/Foundation.h>

@class SHMemberModel;
@interface SHCenterTool : NSObject

/**
 *  @brief the method for save person base information, include is_ioho.
 *
 *  @param model the model for member.
 *
 *  @return void nil.
 */
+ (void)savePersonCenterInfo:(SHMemberModel *)model;

/**
 *  @brief the method for get person base information, include is_ioho.
 *
 *  @param nil.
 *
 *  @return MPMemberModel the model of member.
 */
+ (SHMemberModel *)getPersonCenterInfo;

/**
 *  @brief the method for save person real information.
 *
 *  @param audit_status the string for real or not.
 *
 *  @return void nil.
 */
+ (void)saveAuditStatus:(NSString *)audit_status;

/**
 *  @brief the method for get person real information.
 *
 *  @param nil.
 *
 *  @return NSString the string of real information.
 */
+ (NSString *)getAuditStatus;

/**
 *  @brief the method for save nick name when login.
 *
 *  @param nick_name the string for nick name.
 *
 *  @return void nil.
 */
+ (void)saveNickName:(NSString *)nick_name;

/**
 *  @brief the method for get nick name.
 *
 *  @param nil.
 *
 *  @return NSString the string of nick name.
 */
+ (NSString *)getNickName;

/**
 *  @brief the method for get moble number.
 *
 *  @param nil.
 *
 *  @return NSString the string of moble number.
 */
+ (NSString *)getPhoneNum;
/**
 *  @brief the method for save designer loho when login.
 *
 *  @param nick_name the string for loho.
 *
 *  @return void nil.
 */
+ (void)saveIsLoho:(NSString *)is_loho;

/**
 *  @brief the method for get loho.
 *
 *  @param nil.
 *
 *  @return NSString the string of loho.
 */
+ (NSString *)getIsLoho;

/**
 *  @brief the method for set button image.
 *
 *  @param btn the button need to setting image.
 *
 *  @param netAvator the string of avator.
 *
 *  @return void nil.
 */
+ (void)setHeadIcon:(UIButton *)btn
             avator:(NSString *)netAvator;

@end
