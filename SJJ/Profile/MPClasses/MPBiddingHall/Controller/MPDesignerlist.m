/**
 * @file    MPDesignerlist.m.
 * @brief   the frame of demand list ViewController.
 * @author  Xue.
 * @version 1.0.
 * @date    2016-01-11.
 */

#import "MPDesignerlist.h"
#import "MPOrderEmptyView.h"

@interface MPDesignerlist ()
{
    MPOrderEmptyView *_emptyView;               //!< _emptyView the view for no needs.
}
@end

@implementation MPDesignerlist

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.rightButton.hidden = YES;
    self.leftButton.hidden = YES;
    
    self.menuLabel.text = nil;
    //    self.leftButton.hidden = YES;
    self.titleLabel.text = @"应标大厅";
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat x = 0;
    CGFloat y = NAVBAR_HEIGHT;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - NAVBAR_HEIGHT;
    [self showNoDataIn:self.view imgName:@"nodata_datas" frame:CGRectMake(x, y, width, height) Title:@"暂无结果" buttonTitle:nil Block:nil];
//    _emptyView = [[MPOrderEmptyView alloc] initWithFrame:CGRectMake(x, y, width, height)];
//    [self.view addSubview:_emptyView];
}

@end
