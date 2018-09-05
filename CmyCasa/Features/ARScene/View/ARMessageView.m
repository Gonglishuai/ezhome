//
//  MessageView.m
//  ardemo
//
//  Created by lvwei on 6/24/17.
//  Copyright © 2017 juran. All rights reserved.
//

#import "ARMessageView.h"


@interface MessageView ()

@property (nonatomic, retain) NSMutableArray<NSString*> *queueMessage;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, strong) UILabel *label;
@end

@implementation MessageView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.bounds.size.width - 160, self.bounds.size.height)];
        _label.numberOfLines = 0;
        _label.font = [UIFont systemFontOfSize:12];
        _label.textColor = [UIColor redColor];
        [self.contentView addSubview:_label];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
     _label.frame = CGRectMake(80, 0, self.bounds.size.width - 160, self.bounds.size.height);
}


- (void)queueMessage: (NSString *)message
{
    // If we are currently showing a message, queue the next message. We will show
    // it once the previous message has disappeared. If multiple messages come in
    // we only care about showing the last one
    
    if (!self.queueMessage) {
        self.queueMessage = [NSMutableArray new];
    }
    [self.queueMessage addObject:message];
    
    [self showNextMessage];
}

- (void)showNextMessage
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        if ([self.queueMessage count] == 0) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//                self.alpha = 0;
            } completion:^(BOOL finished) {
            }];
            return;
        }
        
        _label = self.contentView.subviews[0];
        _label.text = [self.queueMessage objectAtIndex:0];
        [self.queueMessage removeObjectAtIndex:0];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            // Wait 1 seconds
            self.timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [self showNextMessage];
            }];
        }];
    });
}

@end
