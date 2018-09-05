
#import <Foundation/Foundation.h>

@class ESProductModel;
@class ESProductSKUModel;
@class ESProductAttributeModel;
@interface ESCartUtil : NSObject

/// 更新选中的属性: 如果栏目里只有一个属性,状态改为选中且不可取消
+ (NSArray *)updateProductModel:(ESProductModel *)product
         withCustomizableStatus:(BOOL)customizable;

/// 根据选中属性与所有sku属性刷新属性状态
+ (void)updateProductModelWithAvailAttributes:(NSArray <ESProductAttributeModel *> *)availAttributes
                              withSeletedSkus:(NSArray <ESProductSKUModel *> *)selectedSkus;

/// 根据点击的位置刷新属性状态
+ (BOOL)updateSelectedSectionValues:(NSIndexPath *)indexPath
                     availAttribute:(NSArray <ESProductAttributeModel *> *)availAttributes;

/// 根据选中属性获取可用的sku
+ (NSArray <ESProductSKUModel *> *)getSelectedSkus:(NSArray <ESProductSKUModel *> *)skus
                            seletedAvailAttributes:(NSArray <ESProductAttributeModel *> *)attributes;

/// 获取选中的属性
+ (NSArray <ESProductAttributeModel *> *)getSelectedAttributes:(NSArray <ESProductAttributeModel *> *)attributes;

/// 根据选中属性与全部属性获取提示信息
+ (NSString *)getHeaderTipMessageWithSelectedValues:(NSArray *)selectedValues
                                      defaultValues:(NSArray *)defaultValues;

/// 重置标签属性
+ (void)resetCartWIthProduct:(ESProductModel *)product
              isCustomizable:(BOOL)isCustomizable;

/// 设置选中属性, enableAllStatus YES:所有属性可点击, NO:根据选中属性设置可点击属性
+ (void)setSelectedAttributes:(NSArray <ESProductAttributeModel *> *)availAttributes
                  selectedIDs:(NSDictionary *)seledteIDs
              enableAllStatus:(BOOL)enableAllStatus;

@end
