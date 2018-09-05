
#import "ESProductCartView.h"
#import "UIImageView+WebCache.h"
#import "ESCartHeaderReusableView.h"
#import "ESproductCollectionBaseCell.h"
#import "ESProductCartFlowLayout.h"
#import "ESProductSKUModel.h"
#import <ESBasic/ESDevice.h>

@interface ESProductCartView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedInformationLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectView;
@property (weak, nonatomic) IBOutlet UILabel *customizableTipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customizableTipLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customizableTipLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addButtonHeightLayoutConstraint;

@end

@implementation ESProductCartView
{
    UIEdgeInsets _collectInsets;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initUI];
}

- (void)initUI
{
    self.topHeightConstraint.constant = SCREEN_WIDTH * 125/375.0f;
    self.customizableTipLabelHeightConstraint.constant = 17.0f;
    self.customizableTipLabelBottomConstraint.constant = 0.0f;
    self.addButtonHeightLayoutConstraint.constant = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT;
    self.productImageView.clipsToBounds = YES;
    self.productImageView.layer.cornerRadius = 2.0f;
    self.productImageView.layer.borderColor = [UIColor stec_lineBorderColor].CGColor;
    self.productImageView.layer.borderWidth = 0.5f;
    
    self.selectedInformationLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    ESProductCartFlowLayout * flowLayout = [[ESProductCartFlowLayout alloc] initWthType:ESItemAlignTypeLeft];
    flowLayout.betweenOfCell = 18;
    flowLayout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);
    self.collectView.collectionViewLayout = flowLayout;
    
    [self.collectView registerNib:[UINib nibWithNibName:@"ESCartHeaderReusableView" bundle:[ESMallAssets hostBundle]]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"ESCartHeaderReusableView"];
    [self.collectView registerNib:[UINib nibWithNibName:@"ESProductCartNumerCell" bundle:[ESMallAssets hostBundle]]
       forCellWithReuseIdentifier:@"ESProductCartNumerCell"];
    [self.collectView registerNib:[UINib nibWithNibName:@"ESProductCartLabelCell" bundle:[ESMallAssets hostBundle]]
       forCellWithReuseIdentifier:@"ESProductCartLabelCell"];
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        self.addButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

#pragma mark - Public Methods
+ (instancetype)productCartView
{
    NSArray *array = [[ESMallAssets hostBundle] loadNibNamed:@"ESProductCartView"
                                                   owner:self
                                                 options:nil];
    return [array firstObject];
}

#pragma mark - Button Click
- (IBAction)addButtonDidTapped:(id)sender
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(productCartAddButtonDidTapped)])
    {
        [self.viewDelegate productCartAddButtonDidTapped];
    }
}

- (IBAction)productCartCloseButtonDidTapped:(id)sender
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(productCartCloseButtonDidTapped)])
    {
        [self.viewDelegate productCartCloseButtonDidTapped];
    }
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger section = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getProductCartSections)])
    {
        section = [self.viewDelegate getProductCartSections];
    }
    
    return section;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getProductCartRowsAtSection:)])
    {
        row = [self.viewDelegate getProductCartRowsAtSection:section];
    }
    
    return row;
}

-(CGSize)            collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 26);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString: UICollectionElementKindSectionHeader])
    {
        static NSString *headerID = @"ESCartHeaderReusableView";
        ESCartHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:headerID
                                                                                     forIndexPath:indexPath];
        header.headerDelegate = (id )self.viewDelegate;
        [header updateHeaderAtSection:indexPath.section];
        return header;
    }
    
    return nil;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getCellIDAtIndexPath:)])
    {
        NSString *cellID = [self.viewDelegate getCellIDAtIndexPath:indexPath];
        if (cellID
            && [cellID isKindOfClass:[NSString class]])
        {
            ESproductCollectionBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID
                                                                                          forIndexPath:indexPath];
            cell.cellDelegate = (id)self.viewDelegate;
            [cell updateCellAtIndexPath:indexPath];
            return cell;
        }
    }
    
    SHLog(@"view代理未签订说着cellID有问题");
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getProductCartItemSizeAtIndexPath:)])
    {
        size = [self.viewDelegate getProductCartItemSizeAtIndexPath:indexPath];
    }
    
    return size;
}

// 竖向滚动时的左右距离
-(CGFloat)                    collectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 18;
}

// 竖向滚动时的左右上下
-(CGFloat)              collectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
   minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 16;
}

- (void)     collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(productCartItemDidTappedWithIndexPath:)])
    {
        [self.viewDelegate productCartItemDidTappedWithIndexPath:indexPath];
    }
}

#pragma mark - Public Methods
- (void)refreshProductCartHeaderView
{
    self.productImageView.image = [UIImage imageNamed:@"search_case_logo"];
    
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getProductHeaderTipMessage)]
        && [self.viewDelegate respondsToSelector:@selector(getProductHeaderSku)]
        && [self.viewDelegate respondsToSelector:@selector(getCustomizableeStatus)])
    {
        BOOL customizableeStatus = [self.viewDelegate getCustomizableeStatus];
        self.customizableTipLabel.hidden = !customizableeStatus;
        self.customizableTipLabelHeightConstraint.constant = customizableeStatus?17.0f:0.0f;
        self.customizableTipLabelBottomConstraint.constant = customizableeStatus?6.0f:0.0f;
        
        NSString *headerTipMessage = [self.viewDelegate getProductHeaderTipMessage];
        ESProductSKUModel *skuModel = [self.viewDelegate getProductHeaderSku];
        if ([headerTipMessage isKindOfClass:[NSString class]]
            && [skuModel isKindOfClass:[ESProductSKUModel class]])
        {
            self.selectedInformationLabel.text = headerTipMessage;
            self.productNameLabel.text = skuModel.name;

            [self.productImageView sd_setImageWithURL:[NSURL URLWithString:skuModel.fullImage]
                                     placeholderImage:[UIImage imageNamed:@"search_case_logo"]];
            
            ESProductPriceModel *priceModel = [skuModel.prices firstObject];
            if ([priceModel isKindOfClass:[ESProductPriceModel class]])
            {
                self.productPriceLabel.text = [@"¥" stringByAppendingString:priceModel.showValue];
            }
        }
    }
}

- (void)refreshProductCartLabelsView
{
    [self.collectView reloadData];
    
    _collectInsets = self.collectView.contentInset;
}

- (void)keyboardWillBeShownWithKeyBoardHeight:(NSInteger)kbHeight
{
    self.collectView.contentInset = UIEdgeInsetsMake(_collectInsets.top,
                                                     _collectInsets.left,
                                                     kbHeight - 49 + 16,
                                                     _collectInsets.right);
    
    [self.collectView scrollRectToVisible:CGRectMake(0, MAXFLOAT, SCREEN_WIDTH, 60) animated:YES];
}

- (void)keyboardWillBeHidden
{
    self.collectView.contentInset = _collectInsets;
}

@end
