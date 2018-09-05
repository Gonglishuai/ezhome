//
//  ESWebView.m
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESWebView.h"
#import <ESBasic/ESDevice.h>
#import "DefaultSetting.h"

@interface ESWebView()
@property (strong, nonatomic) void(^contentSizeChangeCallBack)(CGSize);
@property (assign, nonatomic) CGSize lastContentSize;
@end

@implementation ESWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        self.lastContentSize = CGSizeZero;
        
    }
    return self;
    
}
- (void)setContentSizeCallBack:(void(^)(CGSize))block {
    _contentSizeChangeCallBack = block;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize contentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        if (!CGSizeEqualToSize(contentSize, _lastContentSize)) {
            _lastContentSize = contentSize;
            if (_lastContentSize.height > SCREEN_HEIGHT) {
                if (_contentSizeChangeCallBack) {
                    _contentSizeChangeCallBack(contentSize);
                }
            }
            
        }
    }
}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    NSLog(@"----------dealloc---------");
}

@end
