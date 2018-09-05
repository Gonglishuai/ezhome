
#import "ESHomePageItemsCell.h"
#import "UIImageView+WebCache.h"

@interface ESHomePageItemsCell ()

@property (weak, nonatomic) IBOutlet UIView *adornmentView;
@property (weak, nonatomic) IBOutlet UIView *packageModelView;
@property (weak, nonatomic) IBOutlet UIView *caseModelView;
@property (weak, nonatomic) IBOutlet UIView *financialView;
@property (weak, nonatomic) IBOutlet UIView *consumerBbsView;

@property (weak, nonatomic) IBOutlet UIImageView *firstItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstItemTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *secondItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondItemTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thirdItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *thirdItemTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fourItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *fourItemTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fiveItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *fiveItemTitleLabel;

@end

@implementation ESHomePageItemsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.adornmentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adornmentDidTapped)]];
    [self.packageModelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(packageDidTapped)]];
    [self.caseModelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(caseDidTapped)]];
    [self.financialView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(financialDidTapped)]];
    [self.consumerBbsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(consumerBbsDidTapped)]];
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getHeadItemsInformation)])
    {
        NSArray *items = [self.cellDelegate getHeadItemsInformation];
        if (items
            && [items isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arrM = [[NSMutableArray alloc] initWithArray:items];
            items = [self sortItems:arrM];
            for (NSInteger i = 0; i < items.count; i++)
            {
                NSString *imageUrl = @"";
                NSString *name = @"";
                NSDictionary *dic = items[i];
                if (dic
                    && [dic isKindOfClass:[NSDictionary class]])
                {
                    if (dic[@"title"]
                        && [dic[@"title"] isKindOfClass:[NSString class]])
                    {
                        name = dic[@"title"];
                    }
                    if (dic[@"extend_dic"]
                        && [dic[@"extend_dic"] isKindOfClass:[NSDictionary class]]
                        && dic[@"extend_dic"][@"image"]
                        && [dic[@"extend_dic"][@"image"] isKindOfClass:[NSString class]])
                    {
                        imageUrl = dic[@"extend_dic"][@"image"];
                    }
                }
                switch (i) {
                    case 0:
                    {
                        [self.firstItemImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"home_page_item_default"]];
                        self.firstItemTitleLabel.text = name;
                        break;
                    }
                    case 1:
                    {
                        [self.secondItemImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"home_page_item_default"]];
                        self.secondItemTitleLabel.text = name;
                        break;
                    }
                    case 2:
                    {
                        [self.thirdItemImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"home_page_item_default"]];
                        self.thirdItemTitleLabel.text = name;
                        break;
                    }
                    case 3:
                    {
                        [self.fourItemImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"home_page_item_default"]];
                        self.fourItemTitleLabel.text = name;
                        break;
                    }
                    case 4:
                    {
                        [self.fiveItemImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"home_page_item_default"]];
                        self.fiveItemTitleLabel.text = name;
                        break;
                    }
                    default:
                        break;
                }
            }
            
        }
    }
}

#pragma mark --排序item
- (NSArray *)sortItems:(NSArray *)items
{
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    NSArray *sortedArray = [items sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (void)adornmentDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(itemDidTappedWithType:)])
    {
        [self.cellDelegate itemDidTappedWithType:0];
    }
}

- (void)packageDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(itemDidTappedWithType:)])
    {
        [self.cellDelegate itemDidTappedWithType:1];
    }
}

- (void)caseDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(itemDidTappedWithType:)])
    {
        [self.cellDelegate itemDidTappedWithType:2];
    }
}

- (void)financialDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(itemDidTappedWithType:)])
    {
        [self.cellDelegate itemDidTappedWithType:3];
    }
}

- (void)consumerBbsDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(itemDidTappedWithType:)])
    {
        [self.cellDelegate itemDidTappedWithType:4];
    }
}

@end
