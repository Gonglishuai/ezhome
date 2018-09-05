
#import "ESBaseModel.h"

/**
 facetable (boolean, optional): 是否作为过滤项 ,
 identifier (string, optional): 属性标识 ,
 name (string, optional): 属性名称 ,
 sequence (number, optional): 次序 ,
 usage (string, optional): 属性用途 ,
 valueId (string, optional): 属性值编号 ,
 value (string, optional): 属性值
 */

@interface ESProductAttributeSelectedValueModel : ESBaseModel

@property (nonatomic, assign) BOOL facetable;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sequence;
@property (nonatomic, copy) NSString *usage;
@property (nonatomic, copy) NSString *valueId;
@property (nonatomic, copy) NSString *value;

// 我的新增
@property (nonatomic, assign) CGSize valueSize;
@property (nonatomic, assign) CGSize nameSize;

@end
