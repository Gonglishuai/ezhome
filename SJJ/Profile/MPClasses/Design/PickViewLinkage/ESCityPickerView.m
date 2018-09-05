//
//  ESPickerView.m
//  Consumer
//
//  Created by shiyawei on 17/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCityPickerView.h"

#import "ESRecommendShareCustomer.h"

@interface ESCityPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong)    UIView *bgView;
@property (nonatomic,strong)    UIView *containerView;
@property (nonatomic,strong)    UIToolbar *toolbar;
@property (nonatomic,strong)    UIPickerView *pickerView;

@property (nonatomic,strong)    ESRecommendShareCustomer *customerArea;
    
@property (nonatomic,copy)    NSArray *provinceCodes;
@property (nonatomic,copy)    NSArray *provinceNames;
@property (nonatomic,assign)    NSInteger provinceIndex;
    
@property (nonatomic,copy)    NSArray *cityCodes;
@property (nonatomic,copy)    NSArray *cityNames;
@property (nonatomic,assign)    NSInteger cityIndex;
    
@property (nonatomic,copy)    NSArray *districtCodes;
@property (nonatomic,copy)    NSArray *districtNames;
@property (nonatomic,assign)    NSInteger districtIndex;
    
@property (nonatomic,assign)    NSInteger ComponentNumber;
@end

@implementation ESCityPickerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAnimation)];
        [self.bgView addGestureRecognizer:tap];
        
        self.provinceIndex = 0;
        self.cityIndex = 0;
        self.districtIndex = 0;
        self.ComponentNumber = 3;
        
        self.customerArea = [[ESRecommendShareCustomer alloc] init];
        
        NSArray *arrProvince = [self.customerArea getHolderProvince];
        
        self.provinceCodes = arrProvince.firstObject;
        self.provinceNames = arrProvince.lastObject;
        
        NSArray *arrCity = [self.customerArea getHolderCityWithProvinceCode:self.provinceCodes[self.provinceIndex]];
        self.cityCodes = arrCity.firstObject;
        self.cityNames = arrCity.lastObject;
        
        NSArray *arrDistrict = [self.customerArea getHolderDistrictWithProvinceCode:self.provinceCodes[self.provinceIndex] cityCode:self.cityCodes[self.cityIndex]];
        if (arrCity == nil || arrCity.count == 0){
            self.ComponentNumber = 1;
        }else if (arrDistrict == nil || arrDistrict.count == 0) {
            self.ComponentNumber = 2;
        }else {
            self.ComponentNumber = 3;
            self.districtCodes = arrDistrict.firstObject;
            self.districtNames = arrDistrict.lastObject;
        }
        
        [self addSubview:self.bgView];
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.bgView.frame = CGRectMake(0, 0, self.frame.size.width, 2 * self.frame.size.height / 3);
    self.containerView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height / 3 + BOTTOM_SAFEAREA_HEIGHT);
    self.toolbar.frame = CGRectMake(0, 0, self.containerView.frame.size.width, 44);
    self.pickerView.frame = CGRectMake(0, 44, self.containerView.frame.size.width, self.containerView.frame.size.height - 44 - BOTTOM_SAFEAREA_HEIGHT);
}
#pragma mark --- UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.ComponentNumber;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceNames.count;
    }else if (component == 1) {
        return self.cityNames.count;
    }else {
        return self.districtNames.count;
    }
}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    if (component == 0) {
//       return self.provinceNames[row];
//    }
//    return @"title";
//}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    
    NSString *title = @"title";
    if (component == 0) {
        title = self.provinceNames[row];
    }else if (component == 1) {
        title = self.cityNames[row];
    }else {
        title = self.districtNames[row];
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, SCREEN_WIDTH / self.ComponentNumber, 30);
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [view addSubview:label];
    return view;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.provinceIndex = row;
        self.cityIndex = 0;
        self.districtIndex = 0;
        [self reloadCityArray];
        
        if (self.ComponentNumber > 1) {
            [self.pickerView selectRow:0 inComponent:1 animated:YES];
        }
        if (self.ComponentNumber == 3) {
            [self.pickerView selectRow:0 inComponent:2 animated:YES];
        }
    }else if (component == 1) {
        self.cityIndex = row;
        self.districtIndex = 0;
        [self reloadCityArray];
        if (self.ComponentNumber == 3) {
            [self.pickerView selectRow:0 inComponent:2 animated:YES];
        }
    } else {
        self.districtIndex = row;
    }
    
}
#pragma mark --- Private Method
#pragma mark --刷新城市、区数据
- (void)reloadCityArray {
    NSArray *arrCity = [self.customerArea getHolderCityWithProvinceCode:self.provinceCodes[self.provinceIndex]];
    self.cityCodes = arrCity.firstObject;
    self.cityNames = arrCity.lastObject;
    
    NSArray *arrDistrict = [self.customerArea getHolderDistrictWithProvinceCode:self.provinceCodes[self.provinceIndex] cityCode:self.cityCodes[self.cityIndex]];
    if (arrCity == nil || arrCity.count == 0){
        self.ComponentNumber = 1;
    }else if (arrDistrict == nil || arrDistrict.count == 0) {
        self.ComponentNumber = 2;
    }else {
        self.ComponentNumber = 3;
        self.districtCodes = arrDistrict.firstObject;
        self.districtNames = arrDistrict.lastObject;
    }
    [self.pickerView reloadAllComponents];
}
- (void)showAnimation {
    [UIView transitionWithView:self.containerView duration:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.frame = CGRectMake(0, 2 * self.frame.size.height / 3, self.frame.size.width, self.frame.size.height / 3);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)dismissAnimation {
    [UIView transitionWithView:self.containerView duration:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height / 3);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
#pragma mark --- Publick Method
- (void)didSelectedPickView {
    
    self.customerArea.province = self.provinceCodes[self.provinceIndex];
    self.customerArea.provinceName = self.provinceNames[self.provinceIndex];
    self.customerArea.city = @"";
    self.customerArea.cityName = @"";
    self.customerArea.district = @"";
    self.customerArea.districtName = @"";
    
    if (self.ComponentNumber == 2) {
        self.customerArea.city = self.cityCodes[self.cityIndex];
        self.customerArea.cityName = self.cityNames[self.cityIndex];
    }else if (self.ComponentNumber == 3) {
        
        self.customerArea.city = self.cityCodes[self.cityIndex];
        self.customerArea.cityName = self.cityNames[self.cityIndex];
        self.customerArea.district = self.districtCodes[self.districtIndex];
        self.customerArea.districtName = self.districtNames[self.districtIndex];
        
    }
    
    
    if ([self.delegate respondsToSelector:@selector(esCityPickerView:didSelectedArea:)]) {
        [self.delegate esCityPickerView:self didSelectedArea:self.customerArea];
    }
    
    [self dismissAnimation];
}
- (void)showPickView {
    self.hidden = NO;
    [self showAnimation];
}
#pragma mark --- 懒加载
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        
        [_containerView addSubview:self.toolbar];
        [_containerView addSubview:self.pickerView];
    }
    return _containerView;
}
- (UIToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAnimation)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *sureBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(didSelectedPickView)];
        
        _toolbar.items = @[cancelBtn,space,space1,sureBtn];
    }
    return _toolbar;
}
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor whiteColor];
    }
    return _pickerView;
}
@end
