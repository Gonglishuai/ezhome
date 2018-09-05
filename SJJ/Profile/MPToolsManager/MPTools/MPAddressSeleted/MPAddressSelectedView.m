//
//  MPAddressSelectedView.m
//  Marketplace
//
//  Created by xuezy on 15/12/8.
//  Copyright © 2015年 xuezy. All rights reserved.
//

#import "MPAddressSelectedView.h"
#import "MPRegionManager.h"
#import "MPRegionModel.h"

#define ZHToobarHeight 40

@interface MPAddressSelectedView ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    
    NSInteger _selectedComponentOne;
    NSInteger _selectedComponentTwo;
    NSInteger _selectedComponentThree;
    
}


@property (strong, nonatomic) UIPickerView *myPicker;
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,assign)NSInteger pickeviewHeight;

@property (strong, nonatomic) NSArray *pickerArray;
@property (strong, nonatomic) NSArray <MPRegionModel*> *provinceArray;
@property (strong, nonatomic) NSArray <MPRegionModel*> *cityArray;
@property (strong, nonatomic) NSArray <MPRegionModel*> *townArray;
//@property (strong, nonatomic) NSMutableArray *selectedArray;
@end

@implementation MPAddressSelectedView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setUpToolBar];
    self.pickerArray = [[NSMutableArray alloc] init];
    self.provinceArray = [[NSMutableArray alloc] init];
    self.cityArray = [[NSArray alloc] init];
    self.townArray = [[NSMutableArray alloc] init];
//    self.selectedArray = [[NSMutableArray alloc] init];
    
      return self;
}


-(instancetype)initPickview:(NSString *)titile {
    
    self = [super init];
    
    if (self) {
        _selectedComponentOne = 0;
        _selectedComponentTwo = 0;
        _selectedComponentThree = 0;
        [self getPickerData];
        [self setUpPickView];
        [self setFrameWith:NO];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, _toolbar.frame.size.height/2.0 - 10, CGRectGetWidth(self.frame) - 100, 20)];
        titleLabel.font            = [UIFont systemFontOfSize:15.0f];
        titleLabel.textColor       = ColorFromRGA(0x333333, 1);
        titleLabel.textAlignment   = NSTextAlignmentCenter;
        titleLabel.text            = titile;
        [_toolbar addSubview:titleLabel];

    }
    
    return self;
}

-(instancetype)initPickview:(NSString *)titile provinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode townCode:(NSString*)townCode{
    if (self = [[MPAddressSelectedView alloc] initPickview:titile]) {
        [self setPickerViewprovinceCode:provinceCode cityCode:cityCode townCode:townCode];
    }
    return self;
}
-(void)setPickerViewprovinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode townCode:(NSString*)townCode{
    
    self.provinceArray = [[MPRegionManager sharedInstance] getRegionWithType:MPRegionForProvince withParentCode:@"1"];
    [_provinceArray enumerateObjectsUsingBlock:^(MPRegionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MPRegionModel class]]) {
            MPRegionModel * model = (MPRegionModel *)obj;
            if ( [model.code isEqualToString:provinceCode]) {
                _selectedComponentOne = idx;
                *stop = YES;
            }
        }
    }];
    
    self.cityArray = [[MPRegionManager sharedInstance] getRegionWithType:MPRegionForCity withParentCode:self.provinceArray[_selectedComponentOne].code];
    [self.cityArray enumerateObjectsUsingBlock:^(MPRegionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MPRegionModel class]]) {
            MPRegionModel * model = (MPRegionModel *)obj;
            if ( [model.code isEqualToString:cityCode]) {
                _selectedComponentTwo = idx;
                *stop = YES;
            }
        }
    }];
    
    self.townArray = [[MPRegionManager sharedInstance] getRegionWithType:MPRegionForDistrict withParentCode:self.cityArray[_selectedComponentTwo].code];
    [self.townArray enumerateObjectsUsingBlock:^(MPRegionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MPRegionModel class]]) {
            MPRegionModel * model = (MPRegionModel *)obj;
            if ( [model.code isEqualToString:townCode]) {
                _selectedComponentThree = idx;
                *stop = YES;
            }
        }
    }];
    [self.myPicker reloadAllComponents];
    
    [self setUpPickView];
}


-(void)showInView:(UIView *)view {
    
    [view addSubview:self];
    
}

#pragma mark - set Up PickView
- (void)setUpPickView{
    if (_myPicker == nil) {
        self.myPicker=[[UIPickerView alloc] init];
        self.myPicker.backgroundColor=[UIColor whiteColor];
        self.myPicker.delegate=self;
        self.myPicker.dataSource=self;
    }
    self.myPicker.frame=CGRectMake(0, ZHToobarHeight,SCREEN_WIDTH, self.myPicker.frame.size.height);
    _pickeviewHeight=self.myPicker.frame.size.height;
    
    [self.myPicker selectRow:_selectedComponentOne inComponent:0 animated:YES];
    [self.myPicker selectRow:_selectedComponentTwo inComponent:1 animated:YES];
    [self.myPicker selectRow:_selectedComponentThree inComponent:2 animated:YES];
    
    [self addSubview:self.myPicker];

    
}

-(void)setFrameWith:(BOOL)isHaveNavControler {
    
    CGFloat toolViewX = 0;
    CGFloat toolViewH = _pickeviewHeight+ZHToobarHeight;
    CGFloat toolViewY ;
    
    if (isHaveNavControler) {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH-50;
    }else {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH - NAVBAR_HEIGHT;
    }
    
    CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(toolViewX, toolViewY, toolViewW, toolViewH);
}

-(void)setUpToolBar {
    _toolbar=[self setToolbarStyle];
    [self setToolbarWithPickViewFrame];
    [self addSubview:_toolbar];
}

-(UIToolbar *)setToolbarStyle {
    
    UIToolbar *toolbar=[[UIToolbar alloc] init];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    lefttem.tintColor = [UIColor blackColor];
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
    UIBarButtonItem *rightSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    leftSpace.width = 10;
    rightSpace.width = 10;
    toolbar.items=@[leftSpace, lefttem,centerSpace,right, rightSpace];
    
    return toolbar;
}

-(void)setToolbarWithPickViewFrame {
    _toolbar.frame=CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, ZHToobarHeight);
}


#pragma mark - get data
- (void)getPickerData {
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Property" ofType:@"plist"];
//    
//    
//    self.pickerArray = [[NSArray alloc] initWithContentsOfFile:path];
//    
//    for (NSDictionary *prince in self.pickerArray) {
//        NSArray *princeArr=[NSArray arrayWithArray:[prince allKeys]];
//        for (NSString *stringPrince in princeArr) {
//            
//            [self.provinceArray addObject:stringPrince];
//        }
//        
//    }
//    
//    self.selectedArray = [[self.pickerArray objectAtIndex:0] objectForKey:[self.provinceArray objectAtIndex:0]];
//    
//    
//    if (self.selectedArray.count > 0) {
//        self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
//    }
//    
//    if (self.cityArray.count > 0) {
//        self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:0]];
//    }
    self.provinceArray = [[MPRegionManager sharedInstance] getRegionWithType:MPRegionForProvince withParentCode:@"1"];
    self.cityArray = [[MPRegionManager sharedInstance] getRegionWithType:MPRegionForCity withParentCode:self.provinceArray[0].code];
    self.townArray = [[MPRegionManager sharedInstance] getRegionWithType:MPRegionForDistrict withParentCode:self.cityArray[0].code];
    
}

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == 0) {
        return self.provinceArray.count;
    } else if (component == 1) {
        return self.cityArray.count;
    } else {
        return self.townArray.count;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        return [self.provinceArray objectAtIndex:row].region_name;
    } else if (component == 1) {
        return [self.cityArray objectAtIndex:row].region_name;
    } else {
        return [self.townArray objectAtIndex:row].region_name;
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    if (component == 0) {
        return 110;
    } else if (component == 1) {
        return 100;
    } else {
        return 110;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (component == 0) {
        self.cityArray = [[MPRegionManager sharedInstance]getRegionWithType:MPRegionForCity withParentCode:[self.provinceArray objectAtIndex:row].code];
        self.townArray = [[MPRegionManager sharedInstance]getRegionWithType:MPRegionForDistrict withParentCode:[self.cityArray objectAtIndex:0].code];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    
    
    
    if (component == 1) {
        self.townArray = [[MPRegionManager sharedInstance]getRegionWithType:MPRegionForDistrict withParentCode:[self.cityArray objectAtIndex:row].code];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    }
    _selectedComponentOne = [self.myPicker selectedRowInComponent:0];
    _selectedComponentTwo = [self.myPicker selectedRowInComponent:1];
    _selectedComponentThree = [self.myPicker selectedRowInComponent:2];
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        // pickerLabel.minimumFontSize = 8.;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)remove {
    
//    [self.delegate selectedAddressinitwithResultString:@"NO" isCertain:NO];
    [self.delegate selectedAddressinitWithProvince:@"NO" withCity:@"NO" withTown:@"NO" isCertain:NO];

}

- (void)doneClick{
    
//    NSString *resultString = [NSString stringWithFormat:@"%@-%@-%@",[self.provinceArray objectAtIndex:[self.myPicker selectedRowInComponent:0]],[self.cityArray objectAtIndex:[self.myPicker selectedRowInComponent:1]],[self.townArray objectAtIndex:[self.myPicker selectedRowInComponent:2]]];
    NSString *province = [NSString stringWithFormat:@"%@",[self.provinceArray objectAtIndex:_selectedComponentOne].code];
    NSString *city = [NSString stringWithFormat:@"%@",[self.cityArray objectAtIndex:_selectedComponentTwo].code];
    NSString *town;
    if (self.townArray.count > 0) {
        town = [NSString stringWithFormat:@"%@",[self.townArray objectAtIndex:_selectedComponentThree].code];
    } else {
        town = @" ";
    }
    
//    [self.delegate selectedAddressinitwithResultString:resultString isCertain:YES];
    [self.delegate selectedAddressinitWithProvince:province withCity:city withTown:town isCertain:YES];
    SHLog(@"------->%ld",(long)_selectedComponentOne);
    SHLog(@"------->%ld",(long)_selectedComponentTwo);
    SHLog(@"------->%ld",(long)_selectedComponentThree);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
