
#import "SHModel.h"

@protocol MPDecoWkSubNodeIds <NSObject>

@end

@interface MPDecoWkSubNodeIds : SHModel

@property (nonatomic, retain) NSNumber *sub_node_id;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
