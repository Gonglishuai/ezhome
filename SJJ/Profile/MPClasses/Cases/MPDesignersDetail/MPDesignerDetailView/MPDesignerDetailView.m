
#import "MPDesignerDetailView.h"
#import "MPDesignerDetailHeaderTableViewCell.h"
#import "MPDesignerDetailTableViewCell.h"
#import "CoDesignerDetailHeadView.h"
#import "CoDesignerCommentCell.h"
#import "CoDesignerDetailScoreCell.h"
#import "MPDesignerDetail3DTableViewCell.h"
#import "ESDiyRefreshHeader.h"

@interface MPDesignerDetailView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) CoDesignerDetailHeadView *headView;

@end

@implementation MPDesignerDetailView
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createDesignerDetailTableView];
    }
    return self;
}

- (CoDesignerDetailHeadView *)headView {
    if (_headView == nil) {
        _headView = [[[NSBundle mainBundle] loadNibNamed:@"CoDesignerDetailHeadView" owner:self options:nil] firstObject];
        _headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        _headView.delegate = (id)self.delegate;
    }
    return _headView;
}
- (void)createDesignerDetailTableView {
    self.designerType = 0;
    
    self.deisgnerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.deisgnerTableView.delegate = self;
    self.deisgnerTableView.dataSource = self;
    self.deisgnerTableView.showsVerticalScrollIndicator = NO;
    self.deisgnerTableView.backgroundColor = [UIColor whiteColor];
    self.deisgnerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [ self.deisgnerTableView registerNib:[UINib nibWithNibName:@"MPDesignerDetailHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPDesignerDetailHeader"];
    
    [ self.deisgnerTableView registerNib:[UINib nibWithNibName:@"MPDesignerDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPDesignerDetail"];
    [ self.deisgnerTableView registerNib:[UINib nibWithNibName:@"CoDesignerCommentCell" bundle:nil] forCellReuseIdentifier:@"CoDesignerCommentCell"];
    [ self.deisgnerTableView registerNib:[UINib nibWithNibName:@"CoDesignerDetailScoreCell" bundle:nil] forCellReuseIdentifier:@"CoDesignerDetailScoreCell"];
    [self.deisgnerTableView registerNib:[UINib nibWithNibName:@"MPDesignerDetail3DTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPDesignerDetail3D"];
    
     self.deisgnerTableView.estimatedRowHeight = 500;
    
    [self addSubview: self.deisgnerTableView];
    
    [self addDesignerDetailRefresh];
}

- (void)addDesignerDetailRefresh {
    WS(weakSelf);
     self.deisgnerTableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(designerDetailViewRefreshLoadNewData:)]) {
            [weakSelf endFooterRefresh];
            [weakSelf.delegate designerDetailViewRefreshLoadNewData:^{
                [weakSelf endHeaderRefresh];
            }];
        }
    }];
    
     self.deisgnerTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(designerDetailViewRefreshLoadMoreData:)]) {
            [weakSelf endHeaderRefresh];
            [weakSelf.delegate designerDetailViewRefreshLoadMoreData:^{
                [weakSelf endFooterRefresh];
            }];
        }
    }];
}

/// end header refresh
- (void)endHeaderRefresh {
    [ self.deisgnerTableView.mj_header endRefreshing];
}

/// end footer refresh
- (void)endFooterRefresh {
    [ self.deisgnerTableView.mj_footer endRefreshing];
}



#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }else {
        
        if (self.designerType == 0) {
            if ([self.delegate respondsToSelector:@selector(getDesignerDetailCaseCount)]) {
                return [self.delegate getDesignerDetailCaseCount];
            }
            return 0;
            
        } else if (self.designerType == 2){
            if ([self.delegate respondsToSelector:@selector(getDesignerDetail3DCaseCount)]) {
                return [self.delegate getDesignerDetail3DCaseCount];
            }
            return 0;
        } else {
            if ([self.delegate respondsToSelector:@selector(getDesignerDetailCommentsCount)]) {
                return [self.delegate getDesignerDetailCommentsCount];
            }
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        MPDesignerDetailHeaderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MPDesignerDetailHeader" forIndexPath:indexPath];
        cell.delegate = (id)self.delegate;
        [cell updateCellForIndex:indexPath.row isCenter:self.isDesigner];
        return cell;
    }
    
    if (self.designerType == 0) {
        MPDesignerDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPDesignerDetail" forIndexPath:indexPath];
        cell.delegate = (id)self.delegate;
        [cell updateCellForIndex:indexPath.row];
        return cell;

    }else if (self.designerType == 2){
        MPDesignerDetail3DTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPDesignerDetail3D" forIndexPath:indexPath];
        cell.delegate = (id)self.delegate;
        [cell update3DCellForIndex:indexPath.row];
        return cell;
    } else {
        if (indexPath.row == 0) {
            CoDesignerDetailScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoDesignerDetailScoreCell" forIndexPath:indexPath];
            cell.delegate = (id)self.delegate;
            [cell updateCellForIndex:indexPath.row];
            return cell;

        }else {
            CoDesignerCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoDesignerCommentCell" forIndexPath:indexPath];
            cell.delegate = (id)self.delegate;
            [cell updateCellForIndex:indexPath.row];
            return cell;

        }
    }
    SHLog(@"-----%@",NSStringFromUIEdgeInsets(_deisgnerTableView.contentInset));
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        self.headView.index = self.designerType;
        [self.headView updateDesignerDetailHeadView];
        return self.headView;
    }
    
    return nil;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section ==1) {
        return 50.0f;
    }
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
//        if (self.isDesigner) {
//            return 212.0f;
//        }
        return 255.0f;
    }else {
        if (self.designerType == 0) {
            return SCREEN_WIDTH * CASE_IMAGE_RATIO + 63;

        }if (self.designerType == 2) {
            return SCREEN_WIDTH * CASE_IMAGE_RATIO + 63;
        }
        else {
//            return 50;///评价高度
            
            if (indexPath.row == 0) {
                return 39;
            }else {
                return UITableViewAutomaticDimension;
            }

        }
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectCellAtIndex:withInSection:)]) {
        [self.delegate didSelectCellAtIndex:indexPath.row withInSection:indexPath.section];
    }
}

#pragma mark- Public interface methods
- (void)refreshDesignerDetailUI {
    
    if ([self.delegate respondsToSelector:@selector(getDesignerCellType)]) {
        self.designerType = [self.delegate getDesignerCellType];
    }
    [self.deisgnerTableView reloadData];

    if ((self.designerType == 2) && ( [self.delegate getDesignerDetail3DCaseCount] == 0)) {
        NSIndexPath* indexPat = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.deisgnerTableView scrollToRowAtIndexPath:indexPat atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

@end
