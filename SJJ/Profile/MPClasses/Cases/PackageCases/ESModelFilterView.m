
#import "ESModelFilterView.h"
#import "ESModelFilterReusableView.h"
#import "ESModelFilterCell.h"

@interface ESModelFilterView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectView;

@end

@implementation ESModelFilterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectView registerNib:[UINib nibWithNibName:@"ESModelFilterReusableView" bundle:nil]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"ESModelFilterReusableView"];
    [self.collectView registerNib:[UINib nibWithNibName:@"ESModelFilterCell" bundle:nil]
       forCellWithReuseIdentifier:@"ESModelFilterCell"];
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger section = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getModelFilterSections)])
    {
        section = [self.viewDelegate getModelFilterSections];
    }
    
    return section;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getModelFilterRowsAtSection:)])
    {
        row = [self.viewDelegate getModelFilterRowsAtSection:section];
    }
    
    return row;
}

-(CGSize)            collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString: UICollectionElementKindSectionHeader])
    {
        static NSString *headerID = @"ESModelFilterReusableView";
        ESModelFilterReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:headerID
                                                                                     forIndexPath:indexPath];
        header.headerDelegate = (id )self.viewDelegate;
        [header updateFilterHeaderViewWithSection:indexPath.section];
        return header;
    }
    
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = (CGRectGetWidth(collectionView.frame) - 15 * 2 - 9 * 3)/4.0f;
    CGSize size = CGSizeMake(itemWidth, itemWidth * (76.0f/112.0f));
    return size;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ESModelFilterCell";
    ESModelFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID
                                                                        forIndexPath:indexPath];
    cell.cellDelegate = (id)self.viewDelegate;
    [cell updateFilterCellWithIndexPath:indexPath];
    return cell;
}

// 竖向滚动时的左右距离
-(CGFloat)                    collectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 9.0f;
}

// 竖向滚动时的左右上下
-(CGFloat)              collectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
   minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                       layout:(UICollectionViewLayout *)collectionViewLayout
       insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.1, 15, 0.1, 15);
}

#pragma mark - Public Methods
- (void)refreshTags
{
    [_collectView reloadData];
}

- (void)refreshTagSection:(NSInteger)section
{
    NSInteger sectionCount = [_collectView numberOfSections];
    if (section < sectionCount)
    {
        [_collectView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    }
}

@end
