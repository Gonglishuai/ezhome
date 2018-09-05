//
//  ESDesignPricePicker.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESDesignPricePicker.h"
#import <Masonry.h>

#define PickerToolbarHeight 40
#define PickerViewHeight 220

@interface ESDesignPricePicker()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NSArray <ESFilterItem *>* data;
@property (nonatomic, strong) ESFilterItem *selectedItem;
@property (nonatomic, weak) id <ESDesignPricePickerDelegate> delegate;
@end

@implementation ESDesignPricePicker

- (instancetype)initWithData:(NSArray <ESFilterItem *>*)data
                withDelegate:(id <ESDesignPricePickerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.data = data;
        if (self.data.count > 0) {
            self.selectedItem = [self.data objectAtIndex:0];
        }
        self.delegate = delegate;
    }
    return self;
}

- (void)showDesignPricePickerInView:(UIView *)view {
    self.backgroundColor = [UIColor clearColor];
    [view addSubview:self];
    
    __block UIView *b_view = view;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_view.mas_top);
        make.leading.equalTo(b_view.mas_leading);
        make.bottom.equalTo(b_view.mas_bottom);
        make.trailing.equalTo(b_view.mas_trailing);
    }];
    
    [self setConstraints];
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backView.alpha = 0.4;
        __block ESDesignPricePicker *b_view = self;
        [self.pickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(b_view.mas_leading);
            make.trailing.equalTo(b_view.mas_trailing);
            make.bottom.equalTo(b_view.mas_bottom).with.offset(0);
        }];
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)hiddenInView {

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backView.alpha = 0;
        __block ESDesignPricePicker *b_view = self;
        [self.pickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(b_view.mas_leading);
            make.trailing.equalTo(b_view.mas_trailing);
            make.bottom.equalTo(b_view.mas_bottom).with.offset(PickerViewHeight + PickerToolbarHeight);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setConstraints {
    WS(weakSelf);
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.mas_leading);
        make.trailing.equalTo(weakSelf.mas_trailing);
        make.top.equalTo(weakSelf.mas_top);
        make.bottom.equalTo(weakSelf.mas_bottom);
    }];
    
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.mas_leading);
        make.trailing.equalTo(weakSelf.mas_trailing);
        make.bottom.equalTo(weakSelf.mas_bottom).with.offset(PickerViewHeight + PickerToolbarHeight);
        make.height.equalTo(@(PickerViewHeight));
    }];
    
    __block UIView *b_pickerView = self.pickerView;
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(b_pickerView.mas_leading);
        make.trailing.equalTo(b_pickerView.mas_trailing);
        make.bottom.equalTo(b_pickerView.mas_top);
        make.height.equalTo(@(PickerToolbarHeight));
    }];
}

#pragma mark - Getter
- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.4f;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnClick)];
        [_backView addGestureRecognizer:tgr];
        [self addSubview:_backView];
    }
    return _backView;
}

- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        [self addSubview:self.pickerView];
    }
    return _pickerView;
}

- (UIToolbar *)toolbar {
    if (_toolbar == nil) {
        _toolbar = [[UIToolbar alloc] init];

        UIBarButtonItem *lefttem = [[UIBarButtonItem alloc]
                                    initWithTitle:@"取消"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(cancelBtnClick)];
        lefttem.tintColor = ColorFromRGA(0x333333, 1);
        [lefttem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15],NSFontAttributeName, nil] forState:UIControlStateNormal];
        
        
        UIBarButtonItem *space1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                        target:self
                                        action:nil];
        
        UIBarButtonItem *title = [[UIBarButtonItem alloc]
                                    initWithTitle:@"设计费"
                                    style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
        title.enabled = NO;
        title.tintColor = ColorFromRGA(0x333333, 1);
        [title setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0f],NSFontAttributeName, nil] forState:UIControlStateNormal];
        
        UIBarButtonItem *space2 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:self
                                   action:nil];
        
        UIBarButtonItem *right = [[UIBarButtonItem alloc]
                  initWithTitle:NSLocalizedString(@"确定", nil)
                  style:UIBarButtonItemStylePlain
                  target:self
                  action:@selector(doneBtnClick)];
        [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15],NSFontAttributeName, nil] forState:UIControlStateNormal];
        
        _toolbar.items = @[lefttem, space1, title, space2, right];
        [self addSubview:self.toolbar];
    }
    return _toolbar;
}

- (void)cancelBtnClick {
    [self hiddenInView];
}

- (void)doneBtnClick {
    if ([self.delegate respondsToSelector:@selector(selectedPrice:)]) {
        [self.delegate selectedPrice:self.selectedItem];
        [self hiddenInView];
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.data.count ?: 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.frame.size.width * 2 / 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = @"";
    @try {
        ESFilterItem *item = [self.data objectAtIndex:row];
        title = item.name;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    } @finally {
        return title;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    @try {
        self.selectedItem = [self.data objectAtIndex:row];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@""];
    @try {
        ESFilterItem *item = [self.data objectAtIndex:row];
        NSDictionary *attributes = @{
                                     NSFontAttributeName:@(15),
                                     NSStrikethroughColorAttributeName:[UIColor stec_contentTextColor]};
        title = [[NSAttributedString alloc]initWithString:item.name
                                               attributes:attributes];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    } @finally {
        return title;
    }
}
@end
