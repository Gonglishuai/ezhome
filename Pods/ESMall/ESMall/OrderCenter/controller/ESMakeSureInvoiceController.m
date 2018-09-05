//
//  ESMakeSureInvoiceController.m
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMakeSureInvoiceController.h"
#import "ESMSInvoiceButtonCell.h"
#import "ESInvoiceTextFieldCell.h"

#import "ESLabelHeaderFooterView.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESInvoiceTypeHeaderFooterView.h"
#import "ESInvoiceDropListView.h"
#import "ESInvoiceAPI.h"
#import "MBProgressHUD+NJ.h"
#import "CoStringManager.h"
#import <ESBasic/ESDevice.h>
#import <ESFoundation/DefaultSetting.h>

@interface ESMakeSureInvoiceController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *datasSource;
@property (assign, nonatomic) BOOL isDrawUpInvoice;
@property (assign, nonatomic) BOOL isCompanylInvoice;
@property (assign, nonatomic) BOOL isSpecialInvoice;
@property (assign, nonatomic) BOOL isHistory;
@property (assign, nonatomic) BOOL isChange;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableDictionary *updateDic;
@property (strong, nonatomic) NSMutableDictionary *invoiceListDic;
@property (strong, nonatomic) NSMutableArray *placeholderArray;
@property (strong, nonatomic) ESInvoiceDropListView *dropListView;
@property (strong, nonatomic) void(^myblock)(NSMutableDictionary*);
@end

@implementation ESMakeSureInvoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"确认订单";
    self.rightButton.hidden = YES;
    _datasSource = [NSMutableDictionary dictionary];
    _invoiceListDic = [NSMutableDictionary dictionary];
    if (_updateDic == nil) {
        _updateDic = [NSMutableDictionary dictionary];
    }
    // Do any additional setup after loading the view.
    _titleArray = [NSMutableArray arrayWithObjects:@"单位名称", @"纳税人识别号", @"地址", @"电话", @"开户行", @"开户行账号", nil];
    
    _placeholderArray = [NSMutableArray arrayWithObjects:@"请填写单位名称", @"请填写纳税人识别号", @"请填写单位地址", @"请填写单位电话", @"请填写开户行", @"请填写开户行账号", nil];
    [self setTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self getInvoiceList];
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setInvoiceBlock:(void(^)(NSMutableDictionary*))block {
    _myblock = block;
}

- (void)setInvoiceDic:(NSMutableDictionary *)invoiceDic {
    _updateDic = [NSMutableDictionary dictionary];
    _updateDic = invoiceDic;
    if (invoiceDic.allKeys.count>0) {
        _updateDic = invoiceDic;
        _isHistory = YES;
        _isDrawUpInvoice = YES;
        NSString *invoiceHeadType = [NSString stringWithFormat:@"%@", [_updateDic objectForKey:@"invoiceHeadType"]];
        if ([invoiceHeadType isEqualToString:@"1"]) {
            _isCompanylInvoice = YES;
        } else {
            _isCompanylInvoice = NO;
        }
        
        
        NSString *invoiceType = [NSString stringWithFormat:@"%@", [_updateDic objectForKey:@"invoiceType"]];
        if ([invoiceType isEqualToString:@"2"]) {
            _isSpecialInvoice = YES;
        } else {
            _isSpecialInvoice = NO;
        }
    } else {
        _isDrawUpInvoice = NO;
    }
    [self.tableView reloadData];

}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESMSInvoiceButtonCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMSInvoiceButtonCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESInvoiceTextFieldCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESInvoiceTextFieldCell"];

    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESInvoiceTypeHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESInvoiceTypeHeaderFooterView"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
    
    UIButton *subButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT, SCREEN_WIDTH, TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT)];
    [subButton setTitle:@"确认" forState:UIControlStateNormal];
    [subButton addTarget:self action:@selector(makeSureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    subButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    subButton.titleLabel.font = [UIFont stec_bigTitleFount];
    [subButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:subButton];
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        subButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    
}

- (void)makeSureButtonClicked:(UIButton *)button {
    [self scrollViewDidScroll:_tableView];
    if (_isDrawUpInvoice == NO) {
        if (_myblock) {
            _myblock(_updateDic);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (_isHistory) {
            if (_myblock) {
                _myblock(_updateDic);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if(!_isCompanylInvoice) {
            if (_myblock) {
                _myblock(_updateDic);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            
            NSString *companyName = [CoStringManager judgeNSString:_updateDic forKey:@"companyName"];
            NSString *taxpayerRegistrationNumber = [CoStringManager judgeNSString:_updateDic forKey:@"taxpayerRegistrationNumber"];
            NSString *companyAddress = [CoStringManager judgeNSString:_updateDic forKey:@"companyAddress"];
            NSString *companyMobile = [CoStringManager judgeNSString:_updateDic forKey:@"companyMobile"];
            NSString *companyBank = [CoStringManager judgeNSString:_updateDic forKey:@"companyBank"];
            NSString *companyBankNumbers = [CoStringManager judgeNSString:_updateDic forKey:@"companyBankNumbers"];
            
            NSString *alertString = nil;
            if ([CoStringManager stringContainsEmoji:companyName]) {
                alertString = @"单位名称";
            } else if ([CoStringManager stringContainsEmoji:taxpayerRegistrationNumber]) {
                alertString = @"纳税人识别号";
            } else if ([CoStringManager stringContainsEmoji:companyAddress]) {
                alertString = @"地址";
            } else if ([CoStringManager stringContainsEmoji:companyMobile]) {
                alertString = @"电话";
            } else if ([CoStringManager stringContainsEmoji:companyBank]) {
                alertString = @"开户行";
            } else if ([CoStringManager stringContainsEmoji:companyBankNumbers]) {
                alertString = @"开户行账号";
            }
            
            if (alertString) {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@含有特殊字符", alertString]];
                return;
            }
            
            NSString *invoiceType = [CoStringManager judgeNSString:_updateDic forKey:@"invoiceType"];
            NSString *nullAlertStr = nil;
            if ([invoiceType isEqualToString:@"0"]) {
                if (companyName == nil || companyName.length<1) {
                    nullAlertStr = @"请填写单位名称";
                }  else if (taxpayerRegistrationNumber == nil || taxpayerRegistrationNumber.length<1) {
                    nullAlertStr = @"请填写纳税人识别号";
                }

            } else {
                if (companyName == nil || companyName.length<1) {
                    nullAlertStr = @"请填写单位名称";
                } else if (taxpayerRegistrationNumber == nil || taxpayerRegistrationNumber.length<1) {
                    nullAlertStr = @"请填写纳税人识别号";
                } else if (companyAddress == nil || companyAddress.length<1) {
                    nullAlertStr = @"请填写地址";
                }  else if (companyMobile == nil ||  companyMobile.length<1) {
                    nullAlertStr = @"请填写电话";
                }  else if (companyBank == nil ||  companyBank.length<1) {
                    nullAlertStr = @"请填写开户行";
                }  else if (companyBankNumbers == nil ||  companyBankNumbers.length<1) {
                    nullAlertStr = @"请填写开户行账号";
                }
            }
            if (nullAlertStr) {
                [MBProgressHUD showError: nullAlertStr];
                return;
            }
            
            
            WS(weakSelf)
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [ESInvoiceAPI createInvoiceWithParamDic:_updateDic Success:^(NSDictionary *dict) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                NSString *invoiceId = [NSString stringWithFormat:@"%@", dict[@"data"] ? dict[@"data"] : @""];
                [_updateDic setObject:invoiceId forKey:@"invoiceId"];
                if (_myblock) {
                    _myblock(_updateDic);
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            } failure:^(NSError *error) {
                SHLog(@"%@", error);
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
            }];
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

- (void)getInvoiceList {
    [ESInvoiceAPI getInvoiceListWithSuccess:^(NSDictionary *dict) {
        _invoiceListDic = [NSMutableDictionary dictionaryWithDictionary:dict];
    } failure:^(NSError *error) {

    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isDrawUpInvoice) {
        if (_isCompanylInvoice) {
            return 4;
        } else {
            return 2;
        }
    } else {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    } else if (1 == section) {
        return 1;
    } else if (2 == section) {
        if (_isSpecialInvoice) {
            return 0;
        } else {
            return 2;
        }
    } else {
        if (_isSpecialInvoice) {
            return 6;
        } else {
            return 0;
        }
        
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (3 == section) {
        return 50;
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (0 == section || 1 == section) {
        ESLabelHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
        if (0 == section) {
            [header setTitle:@"发票类型" titleColor:[UIColor stec_subTitleTextColor] subTitle:nil subTitleColor:nil backColor:[UIColor whiteColor]];
        } else {
            [header setTitle:@"发票抬头" titleColor:[UIColor stec_subTitleTextColor] subTitle:nil subTitleColor:nil backColor:[UIColor whiteColor]];
        }
        return header;
    } else {
        ESInvoiceTypeHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESInvoiceTypeHeaderFooterView"];
        WS(weakSelf)
        if (2 == section) {
            [header setTitle:@"普票" selected:(!_isSpecialInvoice) isHistory:_isHistory block:^(NSString *type) {
                _isHistory = NO;
                [_updateDic removeObjectForKey:@"invoiceId"];
                if ([type isEqualToString:@"1"]) {
                    _isChange = NO;
                    [weakSelf.view endEditing:YES];
                    if (weakSelf.isSpecialInvoice == YES) {
                        [_dropListView removeFromSuperview];
                        weakSelf.isSpecialInvoice = NO;
                        [weakSelf.updateDic removeAllObjects];
                        [weakSelf.updateDic setObject:@"1" forKey:@"invoiceHeadType"];
                        [weakSelf.updateDic setObject:@"单位" forKey:@"invoiceTitle"];
                        [weakSelf.updateDic setObject:@"0" forKey:@"invoiceType"];
                        [weakSelf.updateDic setObject:@"0" forKey:@"type"];
                        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:2];
                        [indexSet addIndex:3];
                        [weakSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
                } else {
                    [weakSelf.tableView reloadData];
                    _isChange = YES;
                }
                
            }];

        } else {
            [header setTitle:@"专票" selected:_isSpecialInvoice isHistory:_isHistory block:^(NSString *type) {
                _isHistory = NO;
                [_updateDic removeObjectForKey:@"invoiceId"];
                if ([type isEqualToString:@"1"]) {
                    _isChange = NO;
                    [weakSelf.view endEditing:YES];
                    [_dropListView removeFromSuperview];
                    if (weakSelf.isSpecialInvoice == NO) {
                        weakSelf.isSpecialInvoice = YES;
                        [weakSelf.updateDic removeAllObjects];
                        [weakSelf.updateDic setObject:@"1" forKey:@"invoiceHeadType"];
                        [weakSelf.updateDic setObject:@"单位" forKey:@"invoiceTitle"];
                        [weakSelf.updateDic setObject:@"2" forKey:@"invoiceType"];
                        [weakSelf.updateDic setObject:@"0" forKey:@"type"];
                        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:2];
                        [indexSet addIndex:3];
                        [weakSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }
                    
                } else {
                    [weakSelf.tableView reloadData];
                    _isChange = YES;
                }
            }];
        }
        return header;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WS(weakSelf)
    if (0 == indexPath.section) {
        ESMSInvoiceButtonCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSInvoiceButtonCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setLeftTitle:@"不开具发票" leftType:ESMSInvoiceBtnTypeNone rightTitle:@"纸质发票" rightType:ESMSInvoiceBtnTypePaper isSelectRight:_isDrawUpInvoice block:^(ESMSInvoiceBtnType type) {
            weakSelf.isCompanylInvoice = NO;
            [weakSelf.updateDic removeAllObjects];
            if (type == ESMSInvoiceBtnTypeNone) {
                weakSelf.isDrawUpInvoice = NO;
            } else {
                weakSelf.isDrawUpInvoice = YES;
                [weakSelf.updateDic setObject:@"0" forKey:@"invoiceHeadType"];
                [weakSelf.updateDic setObject:@"个人" forKey:@"invoiceTitle"];
                [weakSelf.updateDic setObject:@"0" forKey:@"type"];
            }
            [weakSelf.tableView reloadData];
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (1 == indexPath.section) {
        ESMSInvoiceButtonCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSInvoiceButtonCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setLeftTitle:@"个人" leftType:ESMSInvoiceBtnTypePersonal rightTitle:@"单位" rightType:ESMSInvoiceBtnTypeCompany isSelectRight:_isCompanylInvoice block:^(ESMSInvoiceBtnType type) {
            weakSelf.isSpecialInvoice = NO;
            NSString *invoiceHeadType = [weakSelf.updateDic objectForKey:@"invoiceHeadType"];
            [weakSelf.updateDic removeAllObjects];
            if (type == ESMSInvoiceBtnTypePersonal) {
                weakSelf.isCompanylInvoice = NO;
                [weakSelf.updateDic setObject:@"0" forKey:@"invoiceHeadType"];
                [weakSelf.updateDic setObject:@"个人" forKey:@"invoiceTitle"];
                [weakSelf.updateDic setObject:@"0" forKey:@"type"];
            } else {
                weakSelf.isCompanylInvoice = YES;
                [weakSelf.updateDic setObject:@"1" forKey:@"invoiceHeadType"];
                [weakSelf.updateDic setObject:@"单位" forKey:@"invoiceTitle"];
                [weakSelf.updateDic setObject:@"0" forKey:@"invoiceType"];
                [weakSelf.updateDic setObject:@"0" forKey:@"type"];
            }
            if (![invoiceHeadType isEqualToString:[weakSelf.updateDic objectForKey:@"invoiceHeadType"]]) {
                _isHistory = NO;
            }
            [weakSelf.tableView reloadData];
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        NSString *title = _titleArray[indexPath.row];
        NSString *subTitle = @"";
        switch (indexPath.row) {
            case 0: {
                subTitle = [_updateDic objectForKey:@"companyName"];
                break;
            }
            case 1: {
                subTitle = [_updateDic objectForKey:@"taxpayerRegistrationNumber"];
                break;
            }
            case 2: {
                subTitle = [_updateDic objectForKey:@"companyAddress"];
                break;
            }
            case 3: {
                subTitle = [_updateDic objectForKey:@"companyMobile"];
                break;
            }
            case 4: {
                subTitle = [_updateDic objectForKey:@"companyBank"];
                break;
            }
            case 5: {
                subTitle = [_updateDic objectForKey:@"companyBankNumbers"];
                break;
            }
            default:
                break;
        }
        
        NSString *placeholder = _placeholderArray[indexPath.row];
        ESInvoiceTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceTextFieldCell" forIndexPath:indexPath];
        if (0 == indexPath.row) {
            
            [cell setTitle:title subTitle:subTitle placeholder:placeholder userEnabled:!_isHistory block:^(NSString *subTitleStr) {
                [_dropListView removeFromSuperview];
                [weakSelf.updateDic setObject:subTitleStr forKey:@"companyName"];
            } dropListblock:^{
                CGRect frame = CGRectMake(112, CGRectGetMaxY(cell.frame)-6, SCREEN_WIDTH-112-15, 124);
                NSMutableArray *strArray = [NSMutableArray array];
                if (2 == indexPath.section) {
                    NSArray *invoiceArr = _invoiceListDic[@"generalInvoices"] ? _invoiceListDic[@"generalInvoices"] : [NSArray array];
                    if ([invoiceArr isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *dic in invoiceArr) {
                            NSString *companyName = dic[@"companyName"]?dic[@"companyName"]:@"";
                            if ([companyName isKindOfClass:[NSString class]]) {
                            } else {
                                companyName = @"";
                            }
                            [strArray addObject:companyName];
                            
                        }
                    } else {
                        return ;
                    }
                } else {
                    NSArray *invoiceArr = _invoiceListDic[@"specialInvoices"] ? _invoiceListDic[@"specialInvoices"] : [NSArray array];
                    if ([invoiceArr isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *dic in invoiceArr) {
                            NSString *companyName = dic[@"companyName"]?dic[@"companyName"]:@"";
                            if ([companyName isKindOfClass:[NSString class]]) {
                            } else {
                                companyName = @"";
                            }
                            [strArray addObject:companyName];
                        }
                    } else {
                        return ;
                    }
                }
                if (strArray.count == 0) {
                    return;
                }
                if (_dropListView) {
                    [_dropListView setWithFrame:frame datasSource:strArray Block:^(NSIndexPath *index) {
                        SHLog(@"%@", strArray[index.section]);
//                        cell.inputTextField.text = strArray[index.section];
                        [weakSelf.view endEditing:YES];
                        NSMutableArray *invoiceArr = [NSMutableArray array];
                        if (2 == indexPath.section) {
                            NSArray *invoices = weakSelf.invoiceListDic[@"generalInvoices"];
                            [invoiceArr addObjectsFromArray:invoices];
                            
                        } else {
                            NSArray *invoices = weakSelf.invoiceListDic[@"specialInvoices"];
                            [invoiceArr addObjectsFromArray:invoices];
                        }
                        
                        if (invoiceArr.count > index.section) {
                            NSDictionary *dic = invoiceArr[index.section];
                            _updateDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [weakSelf.updateDic removeObjectForKey:@"memberId"];
                        }
//                        [weakSelf.updateDic setObject:strArray[index.section] forKey:@"companyName"];
//                        cell.inputTextField.text = strArray[index.section];
                        weakSelf.isHistory = YES;
                        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//                        [weakSelf dropListWillHide];
                        
                    }];
                    [weakSelf.view bringSubviewToFront:_dropListView];
                } else {
                    _dropListView = [ESInvoiceDropListView creatWithFrame:frame datasSource:strArray Block:^(NSIndexPath *index) {
                        SHLog(@"%@", strArray[index.section]);
//                        cell.inputTextField.text = strArray[index.section];
                        [weakSelf.view endEditing:YES];
                        NSMutableArray *invoiceArr = [NSMutableArray array];
                        if (2 == indexPath.section) {
                            NSArray *invoices = weakSelf.invoiceListDic[@"generalInvoices"];
                            [invoiceArr addObjectsFromArray:invoices];
                            
                        } else {
                            NSArray *invoices = weakSelf.invoiceListDic[@"specialInvoices"];
                            [invoiceArr addObjectsFromArray:invoices];
                        }
                        
                        if (invoiceArr.count > index.section) {
                            NSDictionary *dic = invoiceArr[index.section];
                            _updateDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [weakSelf.updateDic removeObjectForKey:@"memberId"];
                        }
                        
                        //                        [weakSelf.updateDic setObject:strArray[index.section] forKey:@"companyName"];
                        //                        cell.inputTextField.text = strArray[index.section];
                        weakSelf.isHistory = YES;
                        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                        
                    }];
                    [_dropListView initTable];
                    [weakSelf.view bringSubviewToFront:_dropListView];
                    
                }
                [weakSelf.tableView addSubview:_dropListView];
                [weakSelf.tableView bringSubviewToFront:_dropListView];
                
//                [weakSelf dropListWillShow];
                
            }];
            if (_isChange) {
                [cell setFirstResponder];
                _isChange = NO;
            }
            
        } else {
            [cell setTitle:title subTitle:subTitle placeholder:placeholder userEnabled:!_isHistory block:^(NSString *subTitle) {
                switch (indexPath.row) {
                    case 0: {
                        
                        break;
                    }
                    case 1: {
                        [weakSelf.updateDic setObject:subTitle forKey:@"taxpayerRegistrationNumber"];
                        break;
                    }
                    case 2: {
                        [weakSelf.updateDic setObject:subTitle forKey:@"companyAddress"];
                        break;
                    }
                    case 3: {
                        [weakSelf.updateDic setObject:subTitle forKey:@"companyMobile"];
                        break;
                    }
                    case 4: {
                        [weakSelf.updateDic setObject:subTitle forKey:@"companyBank"];
                        break;
                    }
                    case 5: {
                        [weakSelf.updateDic setObject:subTitle forKey:@"companyBankNumbers"];
                        break;
                    }
                    default:
                        break;
                }
            } dropListblock:nil];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section ||1 == indexPath.section){
        return 65;
    } else {
        return 55;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
//    [self dropListWillHide];
    [_dropListView removeFromSuperview];
}

#pragma mark - 键盘处理
#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [UIView animateWithDuration:0.3 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, -220);
        }];
    }];
    
    
}
#pragma mark 键盘即将退出
- (void)keyBoardWillHide:(NSNotification *)note{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

//#pragma mark 下拉即将显示
//- (void)dropListWillShow{
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.transform = CGAffineTransformMakeTranslation(0, -220);
//    }];
//    
//    
//}
//#pragma mark 下拉即将退出
//- (void)dropListWillHide{
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.transform = CGAffineTransformIdentity;
//    }];
//}

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
