
#import "ESBaseModel.h"
#import "ESProductAttributeSelectedValueModel.h"
#import "ESProductPriceModel.h"
#import "ESProductImagesModel.h"
#import "ESProductModelModel.h"
#import "ESProductBrandModel.h"

/**
 catalogEntryTypeCode (string, optional): 产品类型编码 ,
 name (string, optional): 产品名称 ,
 partNumber (string, optional): 产品编号 ,
 shortDescription (string, optional): 产品短描述 ,
 longDescription (string, optional): 产品长描述 ,
 thumbnail (string, optional): 缩略图 ,
 fullImage (string, optional): 大图 ,
 manufacturer (string, optional): 厂商 ,
 uniqueId (string, optional): 商品系统编号 ,
 definingAttributes (Array[ProductAttributeSelectedValueResponseBean], optional): 产品定义性属性 ,
 descriptionAttributes (Array[ProductAttributeSelectedValueResponseBean], optional): 产品描述性属性 ,
 prices (Array[ProductPriceResponseBean], optional): 产品价格 ,
 model (ProductModelResponseBean, optional): 产品模型 ,
 images (Array[ProductImagesResponseBean], optional): 产品图片 ,
 isCustomizable (boolean, optional): 是否可定制 ,
 ownerId (string, optional): 厂商ID ,
 isLocked (boolean, optional): 是否已锁定 ,
 dealerId (string, optional): 经销商ID ,
 region (string, optional): 所属区域 ,
 onShelf (boolean, optional): 商品是否上架
 
 "parentCatentryId":"324225",
 "locked":null,
 "customizable":false
 */

@interface ESProductSKUModel : ESBaseModel

@property (nonatomic, copy) NSString *catalogEntryTypeCode;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *partNumber;
@property (nonatomic, copy) NSString *shortDescription;
@property (nonatomic, copy) NSString *longDescription;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *fullImage;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *uniqueId;

@property (nonatomic, retain) NSArray <ESProductAttributeSelectedValueModel *> *definingAttributes;
@property (nonatomic, retain) NSArray <ESProductAttributeSelectedValueModel *> *descriptionAttributes;

@property (nonatomic, retain) NSArray <ESProductPriceModel *> *prices;

@property (nonatomic, retain) ESProductBrandModel *brandResponseBean;

@property (nonatomic, retain) ESProductModelModel *model;

@property (nonatomic, retain) NSArray <ESProductImagesModel *> *images;

@property (nonatomic, copy) NSString *uniqisCustomizableueId;

@property (nonatomic, assign) BOOL isCustomizable;

@property (nonatomic, copy) NSString *ownerId;

@property (nonatomic, assign) BOOL isLocked;

@property (nonatomic, copy) NSString *dealerId;
@property (nonatomic, copy) NSString *region;

@property (nonatomic, assign) BOOL onShelf;

@property (nonatomic, copy) NSString *parentCatentryId;

@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) BOOL customizable;

@end
