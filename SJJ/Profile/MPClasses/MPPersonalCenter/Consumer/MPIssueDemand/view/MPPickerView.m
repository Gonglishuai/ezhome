
#import "MPPickerView.h"
#import "MPRegionManager.h"
#import "MPRegionModel.h"
#import "MPMeasureTool.h"
#import "CoIssuePickerSelectedData.h"

#define MPPickerToobarHeight 40

@interface MPPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

/// the block for choose over.
@property (nonatomic, copy) void (^finish)(NSDictionary *dict);

@end

@implementation MPPickerView
{
    UIPickerView    *_picker;           //!< _picker the pickerView.
    NSInteger        _component;        //!< _component the component of picker.
    NSArray         *_arrayDS;          //!< _arrayDS the datasource of picker.
    NSMutableArray  *_selectedArray;    //!< _selectedArray the array of picker seleted component.
    NSMutableArray  *_arr1;             //!< _arr1 the array of picker first component.
    NSArray         *_arr2;             //!< _arr2 the array of picker sceond component.
    NSMutableArray  *_arr3;             //!< _arr3 the array of picker third component.
    NSString        *_type;             //!< _type the string of picker picker type.
    NSArray         *_nianArray;        //!< _nianArray the array of picker nian.
    NSInteger       _year;              //!< _year the num of nian.
    UIBarButtonItem *_right;            //!< _right the right bar button of toolbar.
//    NSArray         *_arrFen;           //!< _arrFen the array of minute.
    
    NSString        *_style;
    BOOL            _optional;
    
    NSString        *_title;
    
    NSArray *_tempArrRow2;
    NSArray *_tempArrRow3;
    
    CoIssuePickerSelectedData *_seletedData;
    UIControl       *backHud;
}

- (instancetype)initWithFrame:(CGRect)frame
                    plistName:(NSString *)plistName
                 compontCount:(NSInteger)compont
                      linkage:(BOOL)isLinkage
                     optional:(BOOL)isOptional
                        style:(NSString *)style
                       finish:(void(^) (NSDictionary *dict))finish
{
    self = [super initWithFrame:frame];
    if (self) {
        self.finish = finish;
        _component = compont;
        _style = style;
        _optional = isOptional;
        
        [self addBackHud];
        
        [self initDataWithType:plistName linkage:isLinkage];
        [self initUI];
        if (_component == 4)
        {
            [self showCurrentDate];
            [self updateSeletedInfo];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
              arrayDataSource:(NSArray *)arrayDataSource
                       finish:(void(^) (NSDictionary *dict))finish
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if ([title isKindOfClass:[NSString class]])
        {
            _title = title;
        }
        
        [self addBackHud];

        _component = 1;
        self.finish = finish;
        [self initDataWithDataSource:arrayDataSource];
        [self initUI];
    }
    return self;
}

- (void)initDataWithDataSource:(NSArray *)array
{
    if (!array
        || ![array isKindOfClass:[NSArray class]])
    {
        array = @[];
    }
    
    _selectedArray = [NSMutableArray array];
    _arr1 = [NSMutableArray array];
    _arr3 = [NSMutableArray array];
    
    /// The data type determines the complexity of below
    if (_component == 1)
    {
        [_arr1 addObjectsFromArray:array];
    }
    
    [self initSeletedInfo];
}

- (void)initDataWithType:(NSString *)type linkage:(BOOL)isLinkage {
    
    _type = type;
    _selectedArray = [NSMutableArray array];
    _arr1 = [NSMutableArray array];
    _arr3 = [NSMutableArray array];
    
    if (_optional && [type isEqualToString:@"RenovationStyle"]) {
        
//        _style = [_style stringByReplacingOccurrencesOfString:@"，" withString:@","];
//        _arrayDS = [_style componentsSeparatedByString:@","];
        _arrayDS = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:type ofType:@"plist"]];

        
    }else {
        _arrayDS = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:type ofType:@"plist"]];

    }
    
    
    
    /// The data type determines the complexity of below
    if (_component == 1){
        [_arr1 addObjectsFromArray:_arrayDS];
    }
    if (_component == 2){
        [_arr1 addObjectsFromArray:_arrayDS];
        _arr2 = _arrayDS[1];
    }
    else if (_component == 3 && !isLinkage) {
        [_arr1 addObjectsFromArray:_arrayDS[0]];
        _arr2 = _arrayDS[1];
        [_arr3 addObjectsFromArray:_arrayDS[2]];
    }
    else if (_component == 3 && isLinkage) {
        
        _arr1 = (id)[[MPRegionManager sharedInstance] getRegionWithType:MPRegionForProvince withParentCode:@"1"];
        MPRegionModel *modelP = _arr1[0];
        _arr2 = [[MPRegionManager sharedInstance] getRegionWithType:MPRegionForCity withParentCode:modelP.code];
        MPRegionModel *modelC = _arr2[0];
        _arr3 = (id)[[MPRegionManager sharedInstance] getRegionWithType:MPRegionForDistrict withParentCode:modelC.code];

    }
    else if (_component == 4) {
        NSInteger curYear = [self getNian];
        _nianArray = @[@(curYear),@(curYear + 1), @(curYear + 2)];
        
        for (NSDictionary *momth in _arrayDS[0]) {
            for (NSString *stringPrince in [momth allKeys]) {
                [_arr1 addObject:stringPrince];
            }
        }
        [_selectedArray addObjectsFromArray:[_arrayDS[0][0] objectForKey:_arr1[0]]];
        if (_selectedArray.count > 0) {
            _arr2 = [NSArray arrayWithArray:_selectedArray];
        }
        [_arr3 addObjectsFromArray:_arrayDS[1]];
//        _arrFen = _arrayDS[2];
    }
    
    [self updateTitleInfo];
    
    [self initSeletedInfo];
}

- (void)initUI
{
    [self initPicker];
    
    [self createToolar];
}

- (void)initPicker {
    _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, MPPickerToobarHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - MPPickerToobarHeight)];
    _picker.backgroundColor = [UIColor whiteColor];
    /// set delegate
    _picker.delegate = self;
    _picker.dataSource = self;
    [self addSubview:_picker];
}

- (void)addBackHud{
    backHud = [[UIControl alloc]initWithFrame:(CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))];
    [backHud addTarget:self action:@selector(hiddenPickerView) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)createToolar {
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), MPPickerToobarHeight)];
    
    UIBarButtonItem *lefttem = [[UIBarButtonItem alloc]
                               initWithTitle:@"取消"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(cancelBarButtonAction)];
    lefttem.tintColor = ColorFromRGA(0x333333, 1);
    [lefttem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15],NSFontAttributeName, nil] forState:UIControlStateNormal];

    
    UIBarButtonItem *centerSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:self
                                   action:nil];
    
    _right = [[UIBarButtonItem alloc]
              initWithTitle:@"确定"
              style:UIBarButtonItemStylePlain
              target:self
              action:@selector(finishBarButtonAction)];
    [_right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15],NSFontAttributeName, nil] forState:UIControlStateNormal];

    
    toolbar.items = @[lefttem,centerSpace,_right];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, MPPickerToobarHeight/2.0 - 10, CGRectGetWidth(self.frame) - 100, 20)];
    titleLabel.font            = [UIFont systemFontOfSize:15.0f];
    titleLabel.textColor       = ColorFromRGA(0x333333, 1);
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    titleLabel.text            = _title;
    [toolbar addSubview:titleLabel];
    
    [self addSubview:toolbar];
}

/// click cancel.
- (void)cancelBarButtonAction {
    [self hiddenPickerView];
//    if (self.finish) {
//        self.finish(nil);
//    }
}

/// click finish.
- (void)finishBarButtonAction
{
    if (self.finish) {
        self.finish(@{@"comp1"  : _seletedData.row1,
                      @"comp2"  : _seletedData.row2,
                      @"comp3"  : _seletedData.row3,
                      @"nian"   : _seletedData.year,
                      @"fen"    : _seletedData.fen});
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _component;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_component == 4) {
        if (component == 0) {
            return _nianArray.count;
        }else if (component == 1) {
            return _arr1.count;
        }else if (component == 2) {
            return _arr2.count;
        } else if (component == 3) {
            return _arr3.count;
        }
//        else {
//            return _arrFen.count;
//        }
    }
    
    if (component == 0) {
        return _arr1.count;
    }else if (component == 1) {
        return _arr2.count;
    } else {
        return _arr3.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([_type isEqualToString:@"Property"]) {
        MPRegionModel *model;
        if (component == 0) {
            model = _arr1[row];
        } else if (component == 1) {
            model = _arr2[row];
        } else {
            model = _arr3[row];
        }
        return model.region_name;
        
    } else if (_component == 4) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%@%@",_nianArray[row],@"年"];
        } else if (component == 1) {
            return _arr1[row];
        } else if (component == 2) {
            return _arr2[row];
        } else
            return _arr3[row];

//        } else if (component == 3){
//            return _arr3[row];
//        }
//        else {
//            return _arrFen[row];
//        }
        
    } else {
        if (component == 0) {
            return _arr1[row];
        } else if (component == 1) {
            return _arr2[row];
        } else {
            return _arr3[row];
        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat width = self.frame.size.width;
    if (_component == 4) {
        return width / 4.0 - 5;

    }else {
        return (width - 11.0)/3.0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if ([_type isEqualToString:@"Property"]) {
        if (component == 0) {
            MPRegionModel *modelP = _arr1[row];
            _arr2 = [[MPRegionManager sharedInstance]getRegionWithType:MPRegionForCity withParentCode:modelP.code];
            MPRegionModel *modelC = _arr2[0];
            _arr3 = (id)[[MPRegionManager sharedInstance]getRegionWithType:MPRegionForDistrict withParentCode:modelC.code];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
        
        if (component == 1) {
            MPRegionModel *modelC = _arr2[row];
            _arr3 = (id)[[MPRegionManager sharedInstance]getRegionWithType:MPRegionForDistrict withParentCode:modelC.code];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
        [_picker reloadAllComponents];

    } else if ([_type isEqualToString:@"MeasureTime"]) {
        
        if (component == 0) {
            _year = [_nianArray[row] integerValue];
            [self changeTimeData:[_picker selectedRowInComponent:1]];
        }
        if (component == 1) {
            [self changeTimeData:row];
        }
        [pickerView selectedRowInComponent:0];
        [pickerView reloadAllComponents];

        if ([self isLaterTime] && _component == 4) {
            _right.enabled = YES;
        } else {
            [self showCurrentDate];
        }
    }
    else if ([_type isEqualToString:@"HouseSize"])
    {
        NSInteger row = [_picker selectedRowInComponent:0];
        if (row > 4) // loft， 复式， 别墅，其他
        {
            if (!_tempArrRow2 || !_tempArrRow2.count)
            {
                _tempArrRow2 = _arr2;
                _tempArrRow3 = _arr3;
                _arr2 = nil;
                _arr3 = nil;
            }
        }
        else
        {
            if (!_arr2)
            {
                _arr2 = _tempArrRow2;
                _arr3 = (id)_tempArrRow3;
                _tempArrRow2 = nil;
                _tempArrRow3 = nil;
            }
        }
        
        [_picker reloadAllComponents];
    }
    
    [self updateSeletedInfo];
}

- (void)changeTimeData:(NSInteger)row {
    [_selectedArray removeAllObjects];
    [_selectedArray addObjectsFromArray:_arrayDS[0][row][_arr1[row]]];
    
    if (![self isRunNian:_year]) {
        if (row == 1) {
            [_selectedArray removeLastObject];
        }
    }
    
    if (_selectedArray.count > 0)
        _arr2 = _selectedArray;
    else
        _arr2 = nil;

}

/// Get the current time.
- (NSInteger)getNian {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    return [[formatter stringFromDate:[NSDate date]] integerValue];
}

- (BOOL)isRunNian:(NSInteger)nian {
    if ((nian % 4 == 0 && nian % 100 != 0) || nian % 400 == 0) {
        return YES;
    }
    return NO;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont boldSystemFontOfSize:15];
    }

    // Fill the label text here.
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (BOOL)isLaterTime
{
    NSString *year = [NSString stringWithFormat:@"%@",_nianArray[[_picker selectedRowInComponent:0]]];
    NSString *month = [NSString stringWithFormat:@"%@",_arr1[[_picker selectedRowInComponent:1]]];
    NSString *day = [NSString stringWithFormat:@"%@",_arr2[[_picker selectedRowInComponent:2]]];
    NSString *hour = [NSString stringWithFormat:@"%@",_arr3[[_picker selectedRowInComponent:3]]];
//    NSString *fen = [NSString stringWithFormat:@"%@",_arrFen[[_picker selectedRowInComponent:4]]];
    
    return [MPMeasureTool isCurrentDataOverMeasure:[year integerValue]
                                             month:[month integerValue]
                                               day:[day integerValue]
                                              hour:[hour integerValue]
                                            minute:59];
}

- (void)showCurrentDate {
    NSDictionary *dateDict = [MPMeasureTool getCurrentDate];
    NSInteger month = [_arr1[0] integerValue];
    NSInteger day = [_arr2[0] integerValue];
    NSInteger hour = [_arr3[0] integerValue];
//    NSInteger minute = [_arrFen[0] integerValue];
//    
//    NSInteger rowFen = 0;
//    if ([dateDict[@"minute"] integerValue]- minute > 0) {
//        rowFen = [dateDict[@"minute"] integerValue] / 10 - 1;
//    }
    [self changeTimeData:[dateDict[@"month"] integerValue]- month];

    [_picker selectRow:0 inComponent:0 animated:YES];
    [_picker selectRow:[dateDict[@"month"] integerValue]- month inComponent:1 animated:YES];
    [_picker selectRow:[dateDict[@"day"] integerValue]- day inComponent:2 animated:YES];
    [_picker selectRow:[dateDict[@"hour"] integerValue]- hour inComponent:3 animated:YES];
//    [_picker selectRow:rowFen inComponent:4 animated:YES];
}

#pragma mark- Public interface methods
- (void)removePickerView {
    [self removeFromSuperview];
}

- (void)showInView:(UIView *)view {
    [view addSubview:backHud];
    [view bringSubviewToFront:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - 220, SCREEN_WIDTH, 220);
    }];
}

- (void)hiddenPickerView {
    if (backHud) {
        [backHud removeFromSuperview];
        backHud = nil;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT,SCREEN_WIDTH, 0);
    } completion:^(BOOL finished) {
        [self removePickerView];
    }];
}



#pragma mark - Title Info
- (void)updateTitleInfo
{
    NSDictionary *dict = @{@"DesignBudget"      : @"设计预算",
                           @"DecorationBudget"  : @"装修预算",
                           @"HouseType"         : @"房屋类型",
                           @"HouseSize"         : @"户型",
                           @"RenovationStyle"   : @"风格",
                           @"Property"          : @"项目地址",
                           @"MeasureTime"       : @"量房时间",
                           @"DesignerPersonCenter":@"设计预算",
                           @"PaymentStyle"      : @"款项类型",
                           @"HousingStyle"      : @"户型",
                           @"HousingState"      : @"房屋类型",
                           @"PackageDecorationBudget":@"装修预算"};
    
    _title = dict[_type];
    if (!_title) _title = @"";
}

- (void)initSeletedInfo
{
    _seletedData = [[CoIssuePickerSelectedData alloc] init];
    
    if ([_type isEqualToString:@"Property"])
    {
        MPRegionModel *modelP = [_arr1 firstObject];
        _seletedData.row1 = modelP.code;
        
        MPRegionModel *modelC = [_arr2 firstObject];
        _seletedData.row2 = modelC.code;
        
        if (_arr3.count > 0) {
            MPRegionModel *modelD = [_arr3 firstObject];
            _seletedData.row3 = modelD.code;
        }
    } else
    {
        _seletedData.row1 = [_arr1 firstObject];
        _seletedData.row2 = [_arr2 firstObject];
        _seletedData.row3 = [_arr3 firstObject];
        _seletedData.year = [_nianArray firstObject];
        //    _seletedData.fen = [_arrFen firstObject];
    }
    
    
}

/// click finish.
- (void)updateSeletedInfo
{
    //    if (_component == 5 && [self isLaterTime]) {
    //        [self showCurrentDate];
    //        return;
    //    }
    
    if (_component == 1) {
        _seletedData.row1 = [NSString stringWithFormat:@"%@",_arr1[[_picker selectedRowInComponent:0]]];
    } else if (_component == 4) {
        _seletedData.year = [NSString stringWithFormat:@"%@",_nianArray[[_picker selectedRowInComponent:0]]];
        _seletedData.row1 = [NSString stringWithFormat:@"%@",_arr1[[_picker selectedRowInComponent:1]]];
        _seletedData.row2 = [NSString stringWithFormat:@"%@",_arr2[[_picker selectedRowInComponent:2]]];
        _seletedData.row3 = [NSString stringWithFormat:@"%@",_arr3[[_picker selectedRowInComponent:3]]];
        //        strFen = [NSString stringWithFormat:@"%@",_arrFen[[_picker selectedRowInComponent:4]]];
    }
    else {
        
        if ([_type isEqualToString:@"Property"]) {
            MPRegionModel *modelP = _arr1[[_picker selectedRowInComponent:0]];
            _seletedData.row1 = modelP.code;
            
            MPRegionModel *modelC = _arr2[[_picker selectedRowInComponent:1]];
            _seletedData.row2 = modelC.code;
            
            if (_arr3.count > 0) {
                MPRegionModel *modelD = _arr3[[_picker selectedRowInComponent:2]];
                _seletedData.row3 = modelD.code;
            } else
                _seletedData.row3 = @"";
            
        } else {
            _seletedData.row1 = [NSString stringWithFormat:@"%@",_arr1[[_picker selectedRowInComponent:0]]];
            _seletedData.row2 = [NSString stringWithFormat:@"%@",_arr2[[_picker selectedRowInComponent:1]]];
            _seletedData.row3 = [NSString stringWithFormat:@"%@",_arr3[[_picker selectedRowInComponent:2]]];
            
            if ([_seletedData.row2 isEqualToString:@"(null)"])
            {
                _seletedData.row2 = @" ";
                _seletedData.row3 = @" ";
            }
        }
    }
}

@end
