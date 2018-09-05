
#import <Foundation/Foundation.h>

@interface ESAppConstantInfo : NSObject

@property (nonatomic, retain) NSArray *tips;
@property (nonatomic, copy) NSString *validDays;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
