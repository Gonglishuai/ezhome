
#import "ESProductAddCartViewController.h"
#import "ESProductCartView.h"
#import "ESCartUtil.h"
#import "ESProductModel.h"
#import "MBProgressHUD.h"
#import <ESBasic/ESDevice.h>


@interface ESProductAddCartViewController ()<ESProductCartViewDelegate>

@end

@implementation ESProductAddCartViewController
{
    ESProductCartView *_productCartView;
    NSArray <ESProductAttributeModel *> *_selectedAttributes;
    NSArray <ESProductSKUModel *> *_selectedSkus;
    
    NSArray *_availAttributes;
    NSArray *_skus;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
    
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unregisterForKeyboardNotifications];
}

- (void)initData
{
    // 初步过滤属性, 若某个栏位下只有一个属性, 则设置为选中且不可取消状态
    _selectedAttributes = [ESCartUtil updateProductModel:self.product
                                   withCustomizableStatus:self.buttonType == ESProductDetailButtonTypeCustomMade];
    
    if (self.buttonType == ESProductDetailButtonTypeCustomMade)
    {
        _availAttributes = self.product.customizableAvailAttributes;
        _skus = self.product.customizableChildSKUs;
    }
    else
    {
        _availAttributes = self.product.availAttributes;
        _skus = self.product.childSKUs;
    }
    
    [self updateproductSelectedData:nil];
    
    if (self.alertType == ESProductDetailAlertTypeShopCart)
    {// 如果是购物车界面更改属性
        // 1. 根据购物车传过来的已选中的sku设置选中属性, 并把其他所有属性设置成未选中可点击
        [ESCartUtil setSelectedAttributes:_availAttributes
                              selectedIDs:self.selectedAttributesIDs
                          enableAllStatus:YES];
        // 2. 筛选出当前界面的选中属性
        _selectedAttributes = [ESCartUtil getSelectedAttributes:_availAttributes];
        // 3. 筛选出当前界面的选中的sku
        _selectedSkus = [ESCartUtil getSelectedSkus:_skus
                             seletedAvailAttributes:_selectedAttributes];
    }
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navgationImageview removeFromSuperview];
    
    _productCartView = [ESProductCartView productCartView];
    _productCartView.frame = self.view.bounds;
    _productCartView.viewDelegate = self;
    [self.view addSubview:_productCartView];
}

- (void)updateUI
{
    [_productCartView refreshProductCartHeaderView];
    [_productCartView refreshProductCartLabelsView];
}

#pragma mark - ESProductCartViewDelegate
- (NSInteger)getProductCartSections
{
    if (self.product
        && _availAttributes
        && [_availAttributes isKindOfClass:[NSArray class]])
    {
        NSInteger sections = _availAttributes.count;
        if (self.alertType == ESProductDetailAlertTypeShopCart)
        {
            return sections;
        }
        
        return sections + 1;
    }

    return 0;
}

- (NSInteger)getProductCartRowsAtSection:(NSInteger)section
{
    if (_availAttributes.count > section)
    {
        ESProductAttributeModel *model = _availAttributes[section];
        if ([model isKindOfClass:[ESProductAttributeModel class]]
            && [model.values isKindOfClass:[NSArray class]])
        {
            return model.values.count;
        }
    }
    else if (_availAttributes.count == section)
    {
        return 1;
    }
    
    return 0;
}

- (CGSize)getProductCartItemSizeAtIndexPath:(NSIndexPath *)indexPath
{
    if (_availAttributes.count > indexPath.section)
    {
        ESProductAttributeModel *model = _availAttributes[indexPath.section];
        if ([model isKindOfClass:[ESProductAttributeModel class]]
            && [model.values isKindOfClass:[NSArray class]])
        {
            ESProductAttributeValueModel *valueModel = model.values[indexPath.item];
            return valueModel.size;
        }
    }
    else if (_availAttributes.count == indexPath.section)
    {
        return CGSizeMake(SCREEN_WIDTH, 60);
    }
    
    return CGSizeZero;
}

- (NSString *)getCellIDAtIndexPath:(NSIndexPath *)indexPath
{
    if (_availAttributes.count > indexPath.section)
    {
        static NSString *cellID = @"ESProductCartLabelCell";
        return cellID;
    }
    else if (_availAttributes.count == indexPath.section)
    {
        static NSString *cellID = @"ESProductCartNumerCell";
        return cellID;
    }
    
    return nil;
}

- (NSString *)getProductHeaderTipMessage
{
    return [ESCartUtil getHeaderTipMessageWithSelectedValues:_selectedAttributes
                                               defaultValues:_availAttributes];
}

- (ESProductSKUModel *)getProductHeaderSku
{
    return [_selectedSkus firstObject];
}

- (BOOL)getCustomizableeStatus
{
    return self.buttonType == ESProductDetailButtonTypeCustomMade;
}

- (void)productCartAddButtonDidTapped
{
    SHLog(@"添加至购物车或定制");
    if (_selectedAttributes.count != _availAttributes.count)
    {
        NSString *message = [ESCartUtil
                             getHeaderTipMessageWithSelectedValues:_selectedAttributes
                             defaultValues:_availAttributes];
        [self showHudWithMessage:message
                  hideAfterDelay:1];
    }
    else
    {
        if (_selectedSkus.count <= 0)
        {
            [self showHudWithMessage:self.buttonType == ESProductDetailButtonTypeCustomMade?@"出现点小问题，暂不可定制":@"出现点小问题，暂不可购买"
                      hideAfterDelay:1];
        }
        else
        {
            if (self.delegate
                && [self.delegate respondsToSelector:@selector(addItemWithSkuId:itemQuantity:isCustomizable:alertType:)])
            {
                SHLog(@"_selectedSkus.count:%ld", _selectedSkus.count);
                ESProductSKUModel *skuModel = [_selectedSkus firstObject];
                [self.delegate addItemWithSkuId:skuModel?skuModel.uniqueId:@""
                                   itemQuantity:self.product.itemQuantity
                                 isCustomizable:self.buttonType
                                      alertType:self.alertType];
            }
        }
    }
}

- (void)productCartCloseButtonDidTapped
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(cartCloseButtonDidTapped)])
    {
        [self.delegate cartCloseButtonDidTapped];
    }
}

- (void)productCartItemDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= _availAttributes.count)
    {
        // 数量item被点击
        return;
    }
    
    ESProductAttributeModel *attributeModel = _availAttributes[indexPath.section];
    ESProductAttributeValueModel *valueModel = attributeModel.values[indexPath.item];
    if (valueModel.valueStatus == ESCartLabelStatusDisEnable)
    {
        return;
    }
    
    [ESCartUtil updateSelectedSectionValues:indexPath
                             availAttribute:_availAttributes];
    
    [self updateproductSelectedData:attributeModel];
    
    [self updateUI];
}

#pragma mark - ESCartHeaderReusableViewDelegate
- (NSString *)getCartHeaderTitleAtSection:(NSInteger)section
{
    if (_availAttributes.count > section)
    {
        ESProductAttributeModel *model = _availAttributes[section];
        return model.name;
    }
    else if (_availAttributes.count == section)
    {
        return @"数量";
    }
    
    return @"";
}

#pragma mark - ESProductCartNumerCellDelegate
- (BOOL)getCartNumberEnableStatus
{
    return self.buttonType != ESProductDetailButtonTypeCustomMade;
}

- (NSInteger)getCartNumber
{
    return self.product.itemQuantity;
}

- (NSInteger)getMaxCartNumber
{
    return self.product.cartMaxNum;
}

- (void)cartNumberButtonDidTappedWithNumber:(NSInteger)number
{
    SHLog(@"购物车数量%ld", number);
    self.product.itemQuantity = number;
}

- (void)cartShowMessage:(NSString *)message
{
    [self showHudWithMessage:message hideAfterDelay:1];
}

#pragma mark - ESProductCartLabelCellDelegate
- (ESProductAttributeValueModel *)getCartItemMessageAtIndexPath:(NSIndexPath *)indexPath
{
    ESProductAttributeModel *attributeModel = _availAttributes[indexPath.section];
    ESProductAttributeValueModel *valueModel = attributeModel.values[indexPath.item];
    if (valueModel
        && [valueModel isKindOfClass:[ESProductAttributeValueModel class]])
    {
        return valueModel;
    }
    
    return nil;
}

#pragma mark - 键盘相关
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillBeShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    SHLog(@"%@", NSStringFromCGSize(kbSize));
    [_productCartView keyboardWillBeShownWithKeyBoardHeight:kbSize.height];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [_productCartView keyboardWillBeHidden];
}

#pragma mark - Methods
- (void)updateproductSelectedData:(ESProductAttributeModel *)attributeModel
{
    NSArray *skus = [ESCartUtil getSelectedSkus:_skus
                         seletedAvailAttributes:attributeModel ? @[attributeModel] : _selectedAttributes];
    
    [ESCartUtil updateProductModelWithAvailAttributes:_availAttributes
                                      withSeletedSkus:skus];
    
    _selectedAttributes = [ESCartUtil getSelectedAttributes:_availAttributes];
    _selectedSkus = [ESCartUtil getSelectedSkus:_skus
                         seletedAvailAttributes:_selectedAttributes];
    
    SHLog(@"%@ %ld", _selectedSkus, _selectedSkus.count);
}

- (void)showHudWithMessage:(NSString *)message
            hideAfterDelay:(NSTimeInterval)afterDelay
{
    if (!message
        || ![message isKindOfClass:[NSString class]])
    {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:afterDelay];
}

@end
