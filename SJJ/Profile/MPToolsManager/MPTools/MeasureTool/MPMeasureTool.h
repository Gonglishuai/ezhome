
#import <Foundation/Foundation.h>

@interface MPMeasureTool : NSObject

/**
 *  @brief the method for judge measure time.
 *
 *  @param year choose year.
 *
 *  @param month choose month.
 *
 *  @param day choose day.
 *
 *  @param hour choose hour.
 *
 *  @param fen choose fen.
 *
 *  @return void nil.
 */
+ (BOOL)isCurrentDataOverMeasure:(NSInteger)year
                           month:(NSInteger)month
                             day:(NSInteger)day
                            hour:(NSInteger)hour
                          minute:(NSInteger)fen;


/**
 *  @brief the method for get current date.
 *
 *  @param nil.
 *
 *  @return NSDictionary the date dictionary.
 */
+ (NSDictionary *)getCurrentDate;

@end
