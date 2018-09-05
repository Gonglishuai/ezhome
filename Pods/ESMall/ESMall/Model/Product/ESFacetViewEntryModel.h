
#import "ESBaseModel.h"

/**
 label (string, optional): Facet 元素标签 ,
 value (string, optional): Facet 元素值 ,
 count (integer, optional): Facet 数量
 */

@interface ESFacetViewEntryModel : ESBaseModel

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *count;

@end
