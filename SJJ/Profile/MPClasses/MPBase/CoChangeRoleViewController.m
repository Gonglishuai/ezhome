//
//  CoChangeRoleViewController.m
//  Consumer
//
//  Created by jiang on 2017/5/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "CoChangeRoleViewController.h"
#import "JRKeychain.h"

@interface CoChangeRoleViewController ()
@property (weak, nonatomic) IBOutlet UIButton *consumerButton;
@property (weak, nonatomic) IBOutlet UIButton *designerButton;
@property (copy, nonatomic) NSString *role;
@property (weak, nonatomic) IBOutlet UIImageView *roleHeaderImageView;

@end

@implementation CoChangeRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //now Menu can push/ pop App sections
    [self.navigationController setNavigationBarHidden:YES];
    
    _role = @"member";
    _consumerButton.clipsToBounds = YES;
    _consumerButton.layer.cornerRadius = 22.5;
    _consumerButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    _consumerButton.layer.borderWidth = 1;
    _consumerButton.titleLabel.font = [UIFont stec_titleFount];
    [_consumerButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
    [_consumerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_consumerButton setBackgroundImage:[UIImage imageNamed:@"button_back_blue"] forState:UIControlStateSelected];
    _consumerButton.selected = YES;
    _designerButton.clipsToBounds = YES;
    _designerButton.layer.cornerRadius = 22.5;
    _designerButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    _designerButton.layer.borderWidth = 1;
    _designerButton.titleLabel.font = [UIFont stec_titleFount];
    [_designerButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
//    [_designerButton sett]
    [_designerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_designerButton setBackgroundImage:[UIImage imageNamed:@"button_back_blue"] forState:UIControlStateSelected];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)consumerButtonClicked:(UIButton *)sender {
    _consumerButton.selected = YES;
    _consumerButton.layer.borderWidth = 0;
    _designerButton.layer.borderWidth = 1;
    _designerButton.selected = NO;
    _role = @"member";
    _roleHeaderImageView.image = [UIImage imageNamed:@"choose_role_consumer"];

    
}
- (IBAction)designerButtonClicked:(UIButton *)sender {
    _consumerButton.selected = NO;
    _designerButton.selected = YES;
    _consumerButton.layer.borderWidth = 1;
    _designerButton.layer.borderWidth = 0;
    _role = @"designer";
    _roleHeaderImageView.image = [UIImage imageNamed:@"choose_role_designer"];
//    SHMember *member = [[SHMember alloc] init];
//    [member MemberSetMemberType:@"designer"];
//    if (self.clickEnter) {
//        self.clickEnter();
//    }
}
- (IBAction)enterButtonClicked:(UIButton *)sender {
//    SHMember *member = [[SHMember alloc] init];
//    [member MemberSetMemberType:_role];
    [JRKeychain saveSingleInfo:_role infoCode:UserInfoCodeType];
    if (self.clickEnter) {
        self.clickEnter();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
