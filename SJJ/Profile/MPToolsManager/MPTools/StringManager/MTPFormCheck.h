/**
 * @file    MTPFormCheck.h
 * @brief   表单检验类.
 * @author  Shaco(Jiao)
 * @version 1.0
 * @date    2016-06-02
 *
 */

#import "SHModel.h"

@interface MTPFormCheck : SHModel

/**
 *  @brief 校验输入是否为2-10个汉字.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkHanziNumber:(NSString *)string;

/**
 *  @brief 校验输入是否为手机号.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)chectMobile:(NSString *)string;

/**
 *  @brief 校验输入是否为邮箱.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkEmail:(NSString *)string;

/**
 *  @brief 校验输入是否为2-32个字符.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)chectCharacterLength:(NSString *)string;

/**
 *  @brief 校验输入是否为居然账号（9位数字）.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkJuranID:(NSString *)string;

/**
 *  @brief 校验输入是否为合法数量（1-9999 + 2个汉字）.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkCommodityNumber:(NSString *)string;

/**
 *  @brief 校验输入是否为合法规格（小于等于32个字符）.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkCommodityDimension:(NSString *)string;

/**
 *  @brief 校验输入是否为合法备注（小于等于200个字符）.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkCommodityRemarks:(NSString *)string;

/**
 *  @brief 校验输入是否为2-10个汉字或英文字母.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkNameNumber:(NSString *)string;

/**
 *  @brief 校验输入是否为合法规格（2-32个字符）.
 *
 *  @param string string in UITextField.
 *
 *  @return BOOL.
 */
+ (BOOL)checkCommunityName:(NSString *)string;

@end
