//
//  VariationDO.h
//  Homestyler
//
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"

@interface VariationDO : NSObject <RestkitObjectProtocol>

@property (nonatomic,strong) NSString *variationId;
@property (nonatomic,strong) NSString *variationName;
@property (nonatomic,strong) NSString *variationSku;
@property (nonatomic,strong) NSDictionary *files;
@property (nonatomic,strong) NSString *modelId;

-(id)initWithDictionary:(NSDictionary *)dict;

@end
