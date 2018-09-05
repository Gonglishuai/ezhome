//
//  ESAddressPickerView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/10.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESAddressPickerView.h"
#import "ESRegionManager.h"
#import <ESFoundation/DefaultSetting.h>
#import <ESBasic/ESDevice.h>
#define ADDR_PICKERVIEW_HEIGHT 261
#define ADDR_TOOLBAR_HEIGHT 30

@interface ESAddressPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) id<ESAddressPickerViewDelegate> delegate;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *province_array;
@property (nonatomic, strong) NSArray *city_array;
@property (nonatomic, strong) NSArray *district_array;
@property (nonatomic, strong) NSMutableDictionary *currentRegion;

@end

@implementation ESAddressPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initPickerViewWithFram:frame];
        WS(weakSelf);
        [ESRegionManager getRegionsWithParentId:@"100000" withSuccess:^(NSArray<ESRegionModel *> *array) {
            weakSelf.province_array = array;
        }];
        self.currentRegion = [NSMutableDictionary dictionary];
        [self.currentRegion setObject:@"" forKey:@"province"];
        [self.currentRegion setObject:@"" forKey:@"provinceCode"];
        [self.currentRegion setObject:@"" forKey:@"city"];
        [self.currentRegion setObject:@"" forKey:@"cityCode"];
        [self.currentRegion setObject:@"" forKey:@"district"];
        [self.currentRegion setObject:@"" forKey:@"districtCode"];
    }
    return self;
}

- (void)initPickerViewWithFram:(CGRect)frame {
    
    UIToolbar   *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, ADDR_TOOLBAR_HEIGHT)];
//    pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerDateToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(toolBarCanelClick)];
    [barItems addObject:cancelBtn];
    
    UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace1];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = @"";
    [label setFont:[UIFont fontWithName:@".PingFangSC-Regular" size:15]];
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:label];
    [barItems addObject:title];
    
    UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace2];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(toolBarDoneClick)];
    [barItems addObject:doneBtn];
    
    [pickerDateToolbar setItems:barItems animated:YES];
    [self addSubview:pickerDateToolbar];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ADDR_TOOLBAR_HEIGHT, frame.size.width, ADDR_PICKERVIEW_HEIGHT - ADDR_TOOLBAR_HEIGHT)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self addSubview:self.pickerView];
}

- (void)initDataWithProvinceCode:(NSString *)provinceCode
                    withCityCode:(NSString *)cityCode
                 andDistrictCode:(NSString *)districtCode {
    __block NSInteger province_index = -1;
    __block NSInteger city_index = -1;
    __block NSInteger district_index = -1;
    WS(weakSelf);

    if (provinceCode) {
        for (ESRegionModel *model in self.province_array) {
            if ([model.rid isEqualToString:provinceCode]) {
                province_index = [self.province_array indexOfObject:model];
                break;
            }
        }
        [ESRegionManager getRegionsWithParentId:provinceCode withSuccess:^(NSArray<ESRegionModel *> *array) {
            weakSelf.city_array = array;
            if (cityCode && weakSelf.city_array.count > 0) {
                for (ESRegionModel *model in weakSelf.city_array) {
                    if ([model.rid isEqualToString:cityCode]) {
                        city_index = [weakSelf.city_array indexOfObject:model];
                        break;
                    }
                }
                
                [ESRegionManager getRegionsWithParentId:cityCode withSuccess:^(NSArray<ESRegionModel *> *array) {
                    weakSelf.district_array = array;
                    if (districtCode && self.district_array.count > 0) {
                        for (ESRegionModel *model in self.district_array) {
                            if ([model.rid isEqualToString:districtCode]) {
                                district_index = [self.district_array indexOfObject:model];
                                break;
                            }
                        }
                    }
                    [weakSelf updatePickerView:province_index withCity:city_index andDistrict:district_index];
                }];
                return;
            }
            
            [weakSelf updatePickerView:province_index withCity:city_index andDistrict:district_index];
        }];
    
    }else {
        if (self.province_array.count > 0) {
            ESRegionModel *province = [self.province_array objectAtIndex:0];
            [ESRegionManager getRegionsWithParentId:province.rid withSuccess:^(NSArray<ESRegionModel *> *array) {
                weakSelf.city_array = array;
                province_index = 0;
                
                if (weakSelf.city_array.count > 0) {
                    ESRegionModel *city = [weakSelf.city_array objectAtIndex:0];
                    [ESRegionManager getRegionsWithParentId:city.rid withSuccess:^(NSArray<ESRegionModel *> *array) {
                        weakSelf.district_array = array;
                        city_index = 0;
                        
                        if (weakSelf.district_array.count > 0) {
                            district_index = 0;
                        }
                        [weakSelf updatePickerView:province_index withCity:city_index andDistrict:district_index];
                    }];
                    return;
                }
                
                [weakSelf updatePickerView:province_index withCity:city_index andDistrict:district_index];
            }];
        }
        
    }
    
}

- (void)updatePickerView:(NSInteger)province_index
                withCity:(NSInteger)city_index
             andDistrict:(NSInteger)district_index {
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.pickerView reloadComponent:1];
        [weakSelf.pickerView reloadComponent:2];
        if (province_index >= 0) {
            [weakSelf.pickerView selectRow:province_index inComponent:0 animated:NO];
        }
        if (city_index >= 0) {
            [weakSelf.pickerView selectRow:city_index inComponent:1 animated:NO];
        }
        if (district_index >= 0) {
            [weakSelf.pickerView selectRow:district_index inComponent:2 animated:NO];
        }
    });
}

+ (instancetype)addressPickerViewWithDelegate:(UIViewController <ESAddressPickerViewDelegate> *)delegate {
    ESAddressPickerView *view = [[ESAddressPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ADDR_PICKERVIEW_HEIGHT)];
    view.delegate = delegate;
    [delegate.view addSubview:view];
    return view;
}

- (void)showAddrPickerWithProvinceCode:(NSString *)provinceCode
                          withCityCode:(NSString *)cityCode
                       andDistrictCode:(NSString *)districtCode {
    [self initDataWithProvinceCode:provinceCode withCityCode:cityCode andDistrictCode:districtCode];

    
    [UIView transitionWithView:self duration:0.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setFrame:CGRectMake(0, SCREEN_HEIGHT - ADDR_PICKERVIEW_HEIGHT, SCREEN_WIDTH, ADDR_PICKERVIEW_HEIGHT)];
    } completion:nil];
}

- (void)hiddenAddrPicker {
    [self toolBarCanelClick];
}

- (void)toolBarCanelClick {
    [UIView transitionWithView:self duration:0.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ADDR_PICKERVIEW_HEIGHT)];
    } completion:nil];
}

- (void)toolBarDoneClick {
    [self checkSelected];
    if ([self.delegate respondsToSelector:@selector(confirmAddressWithDict:)]) {
        [self.delegate confirmAddressWithDict:self.currentRegion];
    }
    [UIView transitionWithView:self duration:0.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ADDR_PICKERVIEW_HEIGHT)];
    } completion:nil];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.province_array.count;
    }
    if (component == 1) {
        return self.city_array.count;
    }
    if (component == 2) {
        return self.district_array.count;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    @try {
        NSArray *array = [self getDataFromComponent:component];
        if (array) {
            ESRegionModel *model = [array objectAtIndex:row];
            return model.name;
        }
        return @"";
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 3, 30)];
        [label setFont:[UIFont fontWithName:@".PingFangSC-Regular" size:14.0f]];
        [label setTextColor:[UIColor blackColor]];
        
        label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    @try {
        [self reloadESComponent:component withRow:row];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

- (void)reloadESComponent:(NSInteger)component withRow:(NSInteger)row {
    WS(weakSelf);
    switch (component) {
        case 0: {
            if (self.province_array.count > row) {
                ESRegionModel *province = [self.province_array objectAtIndex:row];
                [ESRegionManager getRegionsWithParentId:province.rid withSuccess:^(NSArray<ESRegionModel *> *array) {
                    weakSelf.city_array = array;
                    if (self.city_array.count > 0) {
                        ESRegionModel *city = [self.city_array objectAtIndex:0];
                        [ESRegionManager getRegionsWithParentId:city.rid withSuccess:^(NSArray<ESRegionModel *> *array) {
                            weakSelf.district_array = array;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.pickerView reloadComponent:1];
                                [weakSelf.pickerView reloadComponent:2];
                                [weakSelf.pickerView selectRow:0 inComponent:1 animated:YES];
                                [weakSelf.pickerView selectRow:0 inComponent:2 animated:YES];
                            });
                        }];
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.pickerView reloadComponent:1];
                        [weakSelf.pickerView selectRow:0 inComponent:1 animated:YES];
                    });
                }];
            }
            break;
        }
        case 1: {
            if (self.city_array.count > row) {
                ESRegionModel *city = [self.city_array objectAtIndex:row];
                [ESRegionManager getRegionsWithParentId:city.rid withSuccess:^(NSArray<ESRegionModel *> *array) {
                    weakSelf.district_array = array;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.pickerView reloadComponent:2];
                        [weakSelf.pickerView selectRow:0 inComponent:2 animated:YES];
                    });
                }];
            }
            break;
        }
        default:
            break;
    }

}

- (void)checkSelected {
    NSInteger province_index = [self.pickerView selectedRowInComponent:0];
    NSInteger city_index     = [self.pickerView selectedRowInComponent:1];
    NSInteger district_index = [self.pickerView selectedRowInComponent:2];
    
    if (self.province_array.count > province_index) {
        ESRegionModel *province = [self.province_array objectAtIndex:province_index];
        [self.currentRegion setObject:province.name forKey:@"province"];
        [self.currentRegion setObject:province.rid forKey:@"provinceCode"];
        [self.currentRegion setObject:province.zipcode forKey:@"zipcode"];
    }
    if (self.city_array.count > city_index) {
        ESRegionModel *city     = [self.city_array objectAtIndex:city_index];
        [self.currentRegion setObject:city.name forKey:@"city"];
        [self.currentRegion setObject:city.rid forKey:@"cityCode"];
        [self.currentRegion setObject:city.zipcode forKey:@"zipcode"];
    }
    if (self.district_array.count > district_index) {
        ESRegionModel *district = [self.district_array objectAtIndex:district_index];
        [self.currentRegion setObject:district.name forKey:@"district"];
        [self.currentRegion setObject:district.rid forKey:@"districtCode"];
        [self.currentRegion setObject:district.zipcode forKey:@"zipcode"];
    }
}

- (NSArray *)getDataFromComponent:(NSInteger)component {
    NSArray *result = nil;
    switch (component) {
        case 0:
            result = self.province_array;
            break;
        case 1:
            result = self.city_array;
            break;
        case 2:
            result = self.district_array;
            break;
        default:
            break;
    }
    return result;
}

#pragma mark - Getter
- (NSArray *)province_array {
    if (_province_array == nil) {
        _province_array = [NSArray array];
    }
    return _province_array;
}

- (NSArray *)city_array {
    if (_city_array == nil) {
        _city_array = [NSArray array];
    }
    return _city_array;
}

- (NSArray *)district_array {
    if (_district_array == nil) {
        _district_array = [NSArray array];
    }
    return _district_array;
}
@end
