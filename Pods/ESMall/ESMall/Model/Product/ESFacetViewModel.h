
#import "ESBaseModel.h"
#import "ESFacetViewEntryModel.h"

/**
 name (string, optional): Facet 名称 ,
 entry (Array[FacetViewEntryResponseBean], optional): Facet 过滤值 ,
 value (string, optional): Facet 值
 */

@interface ESFacetViewModel : ESBaseModel

@property (nonatomic, copy) NSString *name;

@property (nonatomic, retain) NSArray <ESFacetViewEntryModel *> *entry;

@property (nonatomic, copy) NSString *value;

@end
