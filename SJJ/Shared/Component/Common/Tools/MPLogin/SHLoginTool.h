
#import <Foundation/Foundation.h>

@interface SHLoginTool : NSObject

/**
 *  @brief the method for save user nick_name.
 *
 *  @param nick_name the string for login user nick_name.
 *
 *  @return void nil.
 */
+ (void)saveNickName:(NSString *)nick_name;

/**
 * 检测用户类型, 若发生改变则执行回调
 */
+ (void)checkMemberTypeWithUpdate:(void(^)(NSString *newMemberType))update;

/**
  * 保存登录信息, 账号和头像
  */
+ (void)saveLoginAvatar:(NSString *)avatar
                account:(NSString *)account;

/**
 * 更新登录信息 - 手机号
 */
+ (void)updateMobileAccount:(NSString *)account;

/**
 * 获取登录信息
 */
+ (NSDictionary *)getLoginRecordInformation;

@end
