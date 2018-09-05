//
//  ESReceiptViewController.m
//  Consumer
//
//  Created by jiang on 2017/7/4.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReceiptViewController.h"
#import "ESOrderAPI.h"
#import "ESLabelHeaderFooterView.h"
#import "ESInvoiceCell.h"
#import "ESTitleTableViewCell.h"
#import "MBProgressHUD+NJ.h"

@interface ESReceiptViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (copy, nonatomic)NSString *invid;//发票id
@property (strong, nonatomic)NSMutableDictionary *dataDic;//发票信息
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation ESReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"发票信息";
    _dataDic = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view.
    [self setTableView];
    [self getInvoiceInfo];
}

- (void)setInvoiceId:(NSString *)nvoiceId {
    _invid = nvoiceId;
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getInvoiceInfo {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getInvoiceWithInvoiceId:self.invid Success:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        _dataDic = [NSMutableDictionary dictionaryWithDictionary:dict];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
    }];
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESInvoiceCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESInvoiceCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESTitleTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESTitleTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelHeaderFooterView"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *invoiceType = [NSString stringWithFormat:@"%@", ([_dataDic objectForKey:@"invoiceType"]? [_dataDic objectForKey:@"invoiceType"] : @"2")];
//    NSString *invoiceTitle = [NSString stringWithFormat:@"%@", [_dataDic objectForKey:@"invoiceTitle"]?[_dataDic objectForKey:@"invoiceTitle"]:@""];
//    if ([invoiceTitle isEqualToString:@"个人"]) {
//        return 1;
//    } else
        if ([invoiceType isEqualToString:@"0"]) {
        return 3;
    } else if ([invoiceType isEqualToString:@"1"]) {
        return 7;
    } else{
        return 7;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (0 == indexPath.row) {
        return 40;
    } else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESLabelHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
    [header setTitle:@"" titleColor:nil subTitle:nil subTitleColor:nil backColor:[UIColor whiteColor]];
    header.lineLabel.hidden = YES;
    return header;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            ESTitleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESTitleTableViewCell" forIndexPath:indexPath];
            NSString *cellStr = @"发票信息       纸质发票";
            NSString *invoiceId = [NSString stringWithFormat:@"%@", ([_dataDic objectForKey:@"invoiceId"] ? [_dataDic objectForKey:@"invoiceId"] : @"")];
            
            if ([invoiceId isEqualToString:@"0"]) {
                cellStr = [cellStr stringByAppendingString:@"       个人"];
            } else {
                NSString *invoiceType = [NSString stringWithFormat:@"%@", [_dataDic objectForKey:@"invoiceType"]?[_dataDic objectForKey:@"invoiceType"]:@""];
                NSString *invoiceTitle = [NSString stringWithFormat:@"%@", [_dataDic objectForKey:@"invoiceTitle"]?[_dataDic objectForKey:@"invoiceTitle"]:@""];
                if ([invoiceTitle isEqualToString:@"个人"]) {
                    cellStr = [cellStr stringByAppendingString:@"       个人"];
                } else if ([invoiceType isEqualToString:@"0"]) {
                    cellStr = [cellStr stringByAppendingString:@"       普票"];
                } else if ([invoiceType isEqualToString:@"1"]) {
                    cellStr = [cellStr stringByAppendingString:@"       增值税"];
                } else if ([invoiceType isEqualToString:@"2"]){
                    cellStr = [cellStr stringByAppendingString:@"       专票"];
                } else {
                }
            }
            [cell setTitle:cellStr textColor:[UIColor stec_titleTextColor] font:[UIFont stec_subTitleFount]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 1: {
            ESInvoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceCell" forIndexPath:indexPath];
            NSString *invoiceTitle = [NSString stringWithFormat:@"%@", (([_dataDic objectForKey:@"invoiceTitle"] != [NSNull null])? [_dataDic objectForKey:@"invoiceTitle"] : @"")];
            [cell setTitle:@"单位名称" subTitle:invoiceTitle];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 2: {
            ESInvoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceCell" forIndexPath:indexPath];
            NSString *taxpayerRegistrationNumber = [NSString stringWithFormat:@"%@", (([_dataDic objectForKey:@"taxpayerRegistrationNumber"]!= [NSNull null])? [_dataDic objectForKey:@"taxpayerRegistrationNumber"] : @"")];
            [cell setTitle:@"纳税人识别号" subTitle:taxpayerRegistrationNumber];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 3: {
            ESInvoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceCell" forIndexPath:indexPath];
            NSString *companyAddress = [NSString stringWithFormat:@"%@", (([_dataDic objectForKey:@"companyAddress"]!= [NSNull null]) ? [_dataDic objectForKey:@"companyAddress"] : @"")];
            [cell setTitle:@"地址" subTitle:companyAddress];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 4: {
            ESInvoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceCell" forIndexPath:indexPath];
            NSString *companyMobile = [NSString stringWithFormat:@"%@", (([_dataDic objectForKey:@"companyMobile"]!= [NSNull null]) ? [_dataDic objectForKey:@"companyMobile"] : @"")];
            [cell setTitle:@"电话" subTitle:companyMobile];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 5: {
            ESInvoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceCell" forIndexPath:indexPath];
            NSString *companyBank = [NSString stringWithFormat:@"%@", (([_dataDic objectForKey:@"companyBank"]!= [NSNull null]) ? [_dataDic objectForKey:@"companyBank"] : @"")];
            [cell setTitle:@"开户行" subTitle:companyBank];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
            
        }
        case 6: {
            ESInvoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceCell" forIndexPath:indexPath];
            NSString *companyBankNumbers = [NSString stringWithFormat:@"%@", (([_dataDic objectForKey:@"companyBankNumbers"]!= [NSNull null]) ? [_dataDic objectForKey:@"companyBankNumbers"] : @"")];
            [cell setTitle:@"开户行账号" subTitle:companyBankNumbers];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        default: {
            ESTitleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESTitleTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    
}

- (NSString *)getErrorMessage:(NSError *)error {
    NSString *msg = @"网络错误, 请稍后重试!";
    @try {
        NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *err = nil;
        NSDictionary * errorDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && errorDict && [errorDict objectForKey:@"msg"]) {
            msg = [errorDict objectForKey:@"msg"];
        }
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    } @finally {
        return msg;
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
