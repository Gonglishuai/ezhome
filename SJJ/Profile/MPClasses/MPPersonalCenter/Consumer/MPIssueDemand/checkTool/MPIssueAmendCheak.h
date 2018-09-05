
#import <Foundation/Foundation.h>

@interface MPIssueAmendCheak : NSObject

/**
 *  @brief the method for check contacts name.
 *
 *  @param name the string for contacts name.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkContactsName:(NSString *)name;

/**
 *  @brief the method for check phone number.
 *
 *  @param name the string for phone number.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkContactsMobile:(NSString *)phoneNumber;

/**
 *  @brief the method for check design budget.
 *
 *  @param name the string for design budget.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkDesignBudget:(NSString *)designBudget;

/**
 *  @brief the method for check renovation budget.
 *
 *  @param name the string for renovation budget.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkRenovationBudget:(NSString *)renovationBudget;

/**
 *  @brief the method for check house area.
 *
 *  @param name the string for house area.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkHouseArea:(NSString *)houseArea;

/**
 *  @brief the method for check neighbourhoods.
 *
 *  @param name the string for neighbourhoods.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkNeighbourhoods:(NSString *)neighbourhoods;

/**
 *  @brief the method for check house type.
 *
 *  @param name the string for house type.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkHouseType:(NSString *)houseType;

/**
 *  @brief the method for check house size.
 *
 *  @param name the string for house size.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkHouseSize:(NSString *)houseSize;

/**
 *  @brief the method for check renovation style.
 *
 *  @param name the string for renovation style.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkRenovationStyle:(NSString *)renovationStyle;

/**
 *  @brief the method for check address.
 *
 *  @param name the string for address.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkAddress:(NSString *)address;

/**
 *  @brief the method for check measure date.
 *
 *  @param name the string for measure date.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkMeasureTime:(NSString *)measure;


+ (BOOL)checkOptionHouseArea:(NSString *)houseArea;
+ (BOOL)checkOptionNeighbourhoods:(NSString *)neighbourhoods;

/**
 *  @brief the method for check detailAddress.
 *
 *  @param name the string for detailAddress.
 *
 *  @return BOOL meets validation rules or not.
 */
+ (BOOL)checkDetailedAddress:(NSString *)detailAddress;

@end
