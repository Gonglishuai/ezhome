//
//  ESMasterSearchScreenCollectionReusableView.m
//  Mall
//
//  Created by jiang on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMasterSearchScreenCollectionReusableView.h"

@interface ESMasterSearchScreenCollectionReusableView()
@property (strong, nonatomic) NSMutableArray *screenArray;//筛选项存储
@property (strong, nonatomic) NSMutableArray *factArray;//实际筛选项存储
@property (strong, nonatomic) NSMutableArray *indexArray;//index存储
@property (strong, nonatomic) void(^myRemoveBlock)(NSInteger);
@property (strong, nonatomic) void(^myClearBlock)(void);
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@end

@implementation ESMasterSearchScreenCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    _screenArray = [NSMutableArray array];
    _factArray = [NSMutableArray array];
    _indexArray = [NSMutableArray array];
    _view1.backgroundColor = [UIColor stec_lineGrayColor];
    _view2.backgroundColor = [UIColor stec_lineGrayColor];
    _view3.backgroundColor = [UIColor stec_lineGrayColor];
    _label1.textColor = [UIColor stec_titleTextColor];
    _label1.font = [UIFont stec_subTitleFount];
    _label2.textColor = [UIColor stec_titleTextColor];
    _label2.font = [UIFont stec_subTitleFount];
    _label3.textColor = [UIColor stec_titleTextColor];
    _label3.font = [UIFont stec_subTitleFount];
    [_clearButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
    
    [_button1 setTitleColor:[UIColor stec_titleTextColor] forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor stec_titleTextColor] forState:UIControlStateNormal];
    [_button3 setTitleColor:[UIColor stec_titleTextColor] forState:UIControlStateNormal];
    
    
    // Initialization code
}

- (void)setScreenArray:(NSArray *)screenArray removeBlock:(void(^)(NSInteger index))removeBlock clearBlock:(void(^)(void))clearBlock {
    _screenArray = [NSMutableArray arrayWithArray:screenArray];
    [_factArray removeAllObjects];
    NSMutableArray *tempIndexArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIView *view = [self viewWithTag:10+i];
        view.hidden = YES;
        if (_screenArray.count>i) {
            NSDictionary *dic = _screenArray[i];
            if ([dic allKeys].count>0) {
                [_factArray addObject:dic];
                [tempIndexArray addObject:[NSString stringWithFormat:@"%d", i]];
            }
        }
        
    }
    _indexArray = [NSMutableArray arrayWithArray:tempIndexArray];
    
    for (int j = 0; j < _factArray.count; j++) {
        UIView *view = [self viewWithTag:10+j];
        view.hidden = NO;
        NSDictionary *dic = (NSDictionary *)[_factArray objectAtIndex:j];
        UILabel *label = (UILabel *)[self viewWithTag:20+j];
        label.text = [NSString stringWithFormat:@"%@", dic[@"label"]?dic[@"label"]:@""];
        
    }
    if (removeBlock) {
        _myRemoveBlock = removeBlock;
    }
    
    if (clearBlock) {
        _myClearBlock = clearBlock;
    }
}

- (IBAction)deleteButtonClicked:(UIButton *)sender {
    NSInteger index = sender.tag-30;
    if (_factArray.count>index) {
        NSInteger factIndex = [[_indexArray objectAtIndex:index] integerValue];
        [_screenArray replaceObjectAtIndex:factIndex withObject:[NSDictionary dictionary]];
        [self setScreenArray:_screenArray removeBlock:nil clearBlock:nil];
        if (_myRemoveBlock) {
            _myRemoveBlock(factIndex);
        }
    }
    
    
}
- (IBAction)clearButtonClicked:(UIButton *)sender {
    if (_myClearBlock) {
        _myClearBlock();
    }
}
@end
