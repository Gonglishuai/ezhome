//
//  LayersViewController.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 6/2/15.
//
//

#import "LayersViewController.h"
#import "LayersViewCell.h"

@interface LayersViewController ()
{
    UIButton * _btnPin;
    UIButton * _leftBtn;
    UIButton * _rightBtn;
    UIButton * _closeBtn;
    BOOL _closeAnimationRunning;
}

@end

@implementation LayersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _editMode = NO;
    
    if ([ConfigManager isProductInfoLeftRightActive]) {
        [self.tableView setTableHeaderView:[self getTableHeader]];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIView*)getTableHeader{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    _btnPin = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
    [_btnPin setImage:[UIImage imageNamed:@"unpin"] forState:UIControlStateNormal];
    [_btnPin addTarget:self action:@selector(toggleEditMode) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:_btnPin];
    
    _leftBtn  = [[UIButton alloc] initWithFrame:CGRectMake(45, 5, 25, 25)];
    [_leftBtn setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(leftPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_leftBtn setEnabled:NO];
    [header addSubview:_leftBtn];
    
    _rightBtn  = [[UIButton alloc] initWithFrame:CGRectMake(85, 5, 25, 25)];
    [_rightBtn setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(rightPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn setEnabled:NO];
    [header addSubview:_rightBtn];
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 5, 25, 25)];
    [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:_closeBtn];
    
    return header;
}


-(void)toggleEditMode
{
    if(!_editMode){
        _editMode = YES;
        [_rightBtn setEnabled:YES];
        [_leftBtn setEnabled:YES];
        [_btnPin setImage:[UIImage imageNamed:@"pin"] forState:UIControlStateNormal];
        
        self.tableView.layer.borderColor = [UIColor yellowColor].CGColor;
        self.tableView.layer.borderWidth = 3.0f;
    }else{
        _editMode = NO;
        [_rightBtn setEnabled:NO];
        [_leftBtn setEnabled:NO];
        [_btnPin setImage:[UIImage imageNamed:@"unpin"] forState:UIControlStateNormal];
        
        [self.tableView setAlpha:1.0];
        self.tableView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.tableView.layer.borderWidth = 0.0f;
    }
}

-(void)leftPressed:(id)sender{
    [UIView animateWithDuration:1.0f delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        NSInteger originY = IS_IPAD ? 52 : 0;
        [self.view setFrame:CGRectMake(0, originY, self.view.frame.size.width, self.view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.isDockingToLeft = YES;
    }];
}

-(void)rightPressed:(id)sender{
    //right
    
    [UIView animateWithDuration:1.0f delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        NSInteger originY = IS_IPAD ? 52 : 0;
        
        [self.view setFrame:CGRectMake(self.parentViewController.view.frame.size.width - self.view.frame.size.width , originY, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.isDockingToLeft = NO;
    }];
}


-(void)closePressed:(id)sender{
    if (_closeAnimationRunning ) {
        return;
    }
    
    _closeAnimationRunning = YES;
    CGRect rerct = self.view.frame;
    if (self.isDockingToLeft) {
        rerct.origin = CGPointMake(rerct.origin.x - self.view.frame.size.width, self.view.frame.origin.y);
    }else{
        rerct.origin = CGPointMake(rerct.origin.x + self.view.frame.size.width, self.view.frame.origin.y);
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = rerct;
    } completion:^(BOOL finished) {
        _closeAnimationRunning = NO;
        [self.view removeFromSuperview];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[DesignsManager sharedInstance] productInfoArray] count];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LayersViewCell *cell = (LayersViewCell*)[tableView dequeueReusableCellWithIdentifier:@"LayersViewCell"];
    
    ProductInfoDO *productInfoDO = [[[DesignsManager sharedInstance] productInfoArray] objectAtIndex:[indexPath row]];
    [cell loadImage:[[productInfoDO product] ImageUrl]];
    [cell.productName setText:[[productInfoDO product] Name]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(entitySelected:)]) {
        [self.delegate entitySelected:nil];
    }
}

@end
