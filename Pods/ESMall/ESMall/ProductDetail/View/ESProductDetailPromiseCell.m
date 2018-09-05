
#import "ESProductDetailPromiseCell.h"
#import "ESProductPromiseCell.h"

@interface ESProductDetailPromiseCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectView;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@end

@implementation ESProductDetailPromiseCell
{
    NSArray <NSDictionary *> *_arrayDS;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [_collectView registerNib:[UINib nibWithNibName:@"ESProductPromiseCell" bundle:[ESMallAssets hostBundle]]
   forCellWithReuseIdentifier:@"ESProductPromiseCell"];
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductPromisesAtIndexPath:)])
    {
        NSArray *array = [(id)self.cellDelegate getProductPromisesAtIndexPath:indexPath];
        if (array
            && [array isKindOfClass:[NSArray class]])
        {
            _arrayDS = array;
            [_collectView reloadData];
        }
    }
}

#pragma mark - Button Click
- (IBAction)detailButtonDidTapped:(id)sender
{
    SHLog(@"查看承诺详情");
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(productDetailPromiseDetailButtonDidTapped)])
    {
        [(id)self.cellDelegate productDetailPromiseDetailButtonDidTapped];
    }
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _arrayDS?1:0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return _arrayDS.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *promiseCellID = @"ESProductPromiseCell";
    ESProductPromiseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:promiseCellID forIndexPath:indexPath];
    [cell updatePromiseItemWithDict:_arrayDS[indexPath.item]];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SCREEN_WIDTH - 20 * 2 - 12 * 3)/4.0f, (SCREEN_WIDTH- 20 * 2 - 12 * 3)/4.0f + 16);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                       layout:(UICollectionViewLayout *)collectionViewLayout
       insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(26, 20, 0, 20);
}

-(CGFloat)                    collectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}


-(CGFloat)              collectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
   minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}

@end
