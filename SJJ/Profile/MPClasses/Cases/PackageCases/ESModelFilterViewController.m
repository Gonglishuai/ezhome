
#import "ESModelFilterViewController.h"
#import "ESModelFilterView.h"
#import "ESSampleRoomTagModel.h"

@interface ESModelFilterViewController ()<ESModelFilterViewDelegate>

@property (weak, nonatomic) IBOutlet ESModelFilterView *modelFilterView;

@end

@implementation ESModelFilterViewController
{
    NSMutableArray *_arrayDS;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
}

- (void)initData
{
    if (!self.tags
        || ![self.tags isKindOfClass:[NSArray class]])
    {
        self.tags = @[];
    }
    
    [ESSampleRoomTagModel updateTags:self.tags];
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"筛选";
    [self.leftButton setImage:[UIImage imageNamed:@"alert_close"]
                     forState:UIControlStateNormal];
    
    self.modelFilterView.viewDelegate = self;
}

#pragma mark - ESModelFilterViewDelegate
- (NSInteger)getModelFilterSections
{
    return self.tags.count;
}

- (NSInteger)getModelFilterRowsAtSection:(NSInteger)section
{
    if (section >= self.tags.count)
    {
        return 0;
    }
    
    ESSampleRoomTagModel *tagModel = self.tags[section];
    if ([tagModel isKindOfClass:[ESSampleRoomTagModel class]]
        && [tagModel.tagList isKindOfClass:[NSArray class]])
    {
        return tagModel.tagList.count;
    }
    
    return 0;
}

#pragma mark - ESModelFilterReusableViewDelegate
- (NSString *)getFilterHeaderTitleAtSection:(NSInteger)section
{
    if (section < self.tags.count)
    {
        ESSampleRoomTagModel *tagModel = self.tags[section];
        return tagModel.tagName;
    }
    
    return @"";
}

#pragma mark - ESModelFilterCellDelegate
- (ESSampleRoomTagFilterModel *)getFilterDataWithIndexPath:(NSIndexPath *)indexPath
{

    ESSampleRoomTagModel *tagModel = self.tags[indexPath.section];
    if ([tagModel.tagList isKindOfClass:[NSArray class]]
        && indexPath.row < tagModel.tagList.count)
    {
        return tagModel.tagList[indexPath.row];
    }
    
    return nil;
}

- (void)itemDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    //    ESSampleRoomTagModel *tagModel = self.tags[indexPath.section];
    //    if ([tagModel.tagsBeans isKindOfClass:[NSArray class]]
    //        && indexPath.row < tagModel.tagsBeans.count)
    //    {
    //        ESSampleRoomTagFilterModel *filterModel = tagModel.tagsBeans[indexPath.row];
    //        filterModel.currentSelectedStatus = !filterModel.currentSelectedStatus;
    //    }
    
    
    [ESSampleRoomTagModel updateTags:self.tags
                           indexPath:indexPath];
    [_modelFilterView refreshTagSection:indexPath.section];
}

#pragma mark - Super Methods
- (void)tapOnLeftButton:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(closeButtonDidTapped)])
    {
        [self.delegate closeButtonDidTapped];
    }
}

#pragma mark - Button Methods
- (IBAction)resetButtonDidTapped:(id)sender
{
    SHLog(@"样板间筛选条件-重置");
    
    [ESSampleRoomTagModel resetTags:self.tags];
    
    [_modelFilterView refreshTags];
}

- (IBAction)sureButtonDidTapped:(id)sender
{
    SHLog(@"样板间筛选条件-确定");
    
    NSString *tagsStr = [ESSampleRoomTagModel getSelectedTagsStrWithTags:self.tags];
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(filterCompleteButtonDidTapped:)])
    {
        [self.delegate filterCompleteButtonDidTapped:tagsStr];
    }
}

@end
