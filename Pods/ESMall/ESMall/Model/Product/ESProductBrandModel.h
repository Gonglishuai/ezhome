
#import "ESBaseModel.h"

/**
 brandName (string, optional): 品牌名称 ,
 brandId (string, optional): 品牌ID ,
 pinyin (string, optional): 首字母 ,
 logo (string, optional): 品牌Logo ,
 description (string, optional): 品牌描述 ,
 relatedCategory (Array[string], optional): 相关目录 ,
 deposit (number, optional): 区域定金 ,
 deliverDate (integer, optional): 区域配送时间 ,
 brandOwner (string, optional): 品牌厂商
 }
 */

@interface ESProductBrandModel : ESBaseModel

@property (nonatomic, copy) NSString *brandName;
@property (nonatomic, copy) NSString *brandId;
@property (nonatomic, copy) NSString *pinyin;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, retain) NSArray <NSString *> *relatedCategory;
@property (nonatomic, retain) NSArray <NSString *> *deposit;
@property (nonatomic, retain) NSArray <NSString *> *deliverTime;

@property (nonatomic, copy) NSString *brandOwner;
@property (nonatomic, copy) NSString *brandCorrelation;

@end
