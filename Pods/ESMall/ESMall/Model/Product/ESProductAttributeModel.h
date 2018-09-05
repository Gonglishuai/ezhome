
#import "ESBaseModel.h"
#import "ESProductAttributeValueModel.h"

/**
 facetable (boolean, optional): 是否作为过滤项 ,
 identifier (string, optional): 属性标识 ,
 name (string, optional): 属性名称 ,
 sequence (number, optional): 次序 ,
 usage (string, optional): 属性用途 ,
 values (Array[ProductAttributeValueResponseBean], optional): 属性可选值
 */

@interface ESProductAttributeModel : ESBaseModel

@property (nonatomic, assign) BOOL facetable;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sequence;
@property (nonatomic, copy) NSString *usage;
@property (nonatomic, retain) NSArray <ESProductAttributeValueModel *> *values;

// 我的新增
@property (nonatomic, retain) ESProductAttributeValueModel *selectedValue;
@property (nonatomic, assign) BOOL onSelected;

+ (ESProductAttributeModel *)copyAttributeModel:(ESProductAttributeModel *)attributeModel;

@end
