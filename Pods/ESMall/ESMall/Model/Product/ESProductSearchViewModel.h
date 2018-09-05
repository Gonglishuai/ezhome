
#import "ESBaseModel.h"
#import "ESProductModel.h"
#import "ESFacetViewModel.h"

/**
 recordSetComplete (string, optional): 是否已完成 ,
 recordSetCount (integer, optional): 本页返回结果的数量 ,
 recordSetStartNumber (integer, optional): 本页起始数字 ,
 recordSetTotal (integer, optional): 结果总数量 ,
 recordSetTotalMatches (integer, optional): 结果命中总数量 ,
 resourceName (string, optional): 资源名称 ,
 resourceId (string, optional): 资源编号 ,
 products (Array[ProductResponseBean], optional): 产品列表 ,
 facetView (Array[FacetViewResponseBean], optional): Facet列表
 */

@interface ESProductSearchViewModel : ESBaseModel

@property (nonatomic, copy) NSString *recordSetComplete;
@property (nonatomic, copy) NSString *recordSetCount;
@property (nonatomic, copy) NSString *recordSetStartNumber;
@property (nonatomic, copy) NSString *recordSetTotal;
@property (nonatomic, copy) NSString *recordSetTotalMatches;
@property (nonatomic, copy) NSString *resourceName;
@property (nonatomic, copy) NSString *resourceId;

@property (nonatomic, retain) NSArray <ESProductModel *> *products;

@property (nonatomic, retain) NSArray <ESFacetViewModel *> *facetView;

@end
