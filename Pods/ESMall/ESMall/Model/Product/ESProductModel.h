
#import "ESBaseModel.h"
#import "ESProductAttributeModel.h"
#import "ESProductAttributeSelectedValueModel.h"
#import "ESProductPriceModel.h"
#import "ESProductSKUModel.h"
#import "ESProductImagesModel.h"
#import "ESProductModelModel.h"
#import "ESProductBrandModel.h"
#import "ESCartCommodityPromotion.h"

#define MAX_CART_NUMBER 999

/**
 catalogEntryTypeCode (string, optional): 产品类型编码 ,
 catalogEntryId (string, optional): 产品唯一编码 ,
 name (string, optional): 产品名称 ,
 partNumber (string, optional): 产品编号 ,
 shortDescription (string, optional): 产品短描述 ,
 longDescription (string, optional): 产品长描述 ,
 thumbnail (string, optional): 缩略图 ,
 fullImage (string, optional): 大图 ,
 manufacturer (string, optional): 厂商 ,
 uniqueId (string, optional): 商品系统编号 ,
 hasSingleSKU (boolean, optional): 是否是单个SKU ,
 availAttributes (Array[ProductAttributeResponseBean], optional): 产品可选属性 ,
 descriptionAttributes (Array[ProductAttributeSelectedValueResponseBean], optional): 产品描述性属性 ,
 prices (Array[ProductPriceResponseBean], optional): 产品价格 ,
 childSKUs (Array[ProductSKUResponseBean], optional): 产品SKU列表 ,
 model (ProductModelResponseBean, optional): 产品模型 ,
 images (Array[ProductImagesResponseBean], optional): 产品图片 ,
 isCustomizable (boolean, optional): 是否可定制 ,
 brandId (string, optional): 品牌Id ,
 brandName (string, optional): 品牌名称 ,
 ownerId (string, optional): 厂商ID ,
 isLocked (boolean, optional): 是否已锁定 ,
 isAvailable (boolean, optional): 是否已上架 ,
 dealerId (string, optional): 经销商ID ,
 region (string, optional): 所属区域 ,
 onShelf (boolean, optional): 商品是否上架
 
 */

@interface ESProductModel : ESBaseModel

@property (nonatomic, copy) NSString *catalogEntryTypeCode;
@property (nonatomic, copy) NSString *catalogEntryId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *partNumber;
@property (nonatomic, copy) NSString *shortDescription;
@property (nonatomic, copy) NSString *longDescription;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *fullImage;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *uniqueId;

@property (nonatomic, assign) BOOL hasSingleSKU;

@property (nonatomic, retain) NSArray <ESProductAttributeModel *> *availAttributes;

@property (nonatomic, retain) NSArray <ESProductAttributeSelectedValueModel *> *descriptionAttributes;

@property (nonatomic, retain) NSArray <ESProductPriceModel *> *prices;
@property (nonatomic, retain) NSArray <ESProductPriceModel *> *priceOriginal;

@property (nonatomic, retain) NSArray <ESProductSKUModel *> *childSKUs;

@property (nonatomic, retain) ESProductBrandModel *brandResponseBean;

@property (nonatomic, retain) ESProductModelModel *model;

@property (nonatomic, retain) NSArray <ESProductImagesModel *> *images;

@property (nonatomic, assign) BOOL isCustomizable;

@property (nonatomic, copy) NSString *ownerId;

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isAvailable;

@property (nonatomic, copy) NSString *dealerId;
@property (nonatomic, copy) NSString *region;

@property (nonatomic, assign) BOOL onShelf;

@property (nonatomic, retain) NSArray <ESCartCommodityPromotion *> *productTagResponseBeans;

// 我的新增
@property (nonatomic, assign) BOOL showMinPriceStatus;
@property (nonatomic, copy) NSString *minPrice;
@property (nonatomic, copy) NSString *originalPrice;
@property (nonatomic, assign) NSInteger itemQuantity;
@property (nonatomic, assign) NSInteger cartMaxNum;

@property (nonatomic, retain) NSArray <ESProductAttributeModel *> *customizableAvailAttributes;
@property (nonatomic, retain) NSArray <ESProductSKUModel *> *customizableChildSKUs;

@end
