//
//  JRPageControl.m
//  Consumer
//
//  Created by jiang on 2017/5/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRPageControl.h"
#import "ESFoundationAssets.h"

@interface JRPageControl()

@property (nonatomic, assign) NSInteger lastNumberOfPages;

@end
@implementation JRPageControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@synthesize currentPage;
@synthesize numberOfPages;
@synthesize defersCurrentPageDisplay;
@synthesize hidesForSinglePage;
@synthesize wrap;
@synthesize otherColour;
@synthesize currentColor;
@synthesize controlSize;
@synthesize controlSpacing;

- (void)setup
{
    //needs redrawing if bounds change
    //this isn't a private method, but using KVC avoids having to import <QuartzCore>
    [self.layer setValue:[NSNumber numberWithBool:YES] forKey:@"needsDisplayOnBoundsChange"];
    
    //set defaults
    self.currentColor = [UIColor whiteColor];
    self.otherColour = [UIColor colorWithWhite:0.0 alpha:0.25];
    self.backgroundColor = [UIColor clearColor];
    controlSpacing = 8.0;
    controlSize = 20.0;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setup];
    }
    return self;
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    CGFloat width = controlSize + (controlSize + controlSpacing) * (numberOfPages - 1);
    return CGSizeMake(width, 10);
}

- (void)updateCurrentPageDisplay
{
    if (defersCurrentPageDisplay)
    {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    
    if (numberOfPages > 1 || !hidesForSinglePage)
    {
//        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat width = [self sizeForNumberOfPages:numberOfPages].width;
        CGFloat offset = (self.frame.size.width - width) / 2;
        
        if (_lastNumberOfPages != numberOfPages) {
            _lastNumberOfPages = numberOfPages;
            for (int i = 0; i < numberOfPages; i++) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(offset + (controlSize + controlSpacing) * i, (self.frame.size.height / 2) - (controlSize / 2), controlSize, 2.5)];
                imgView.tag = 100+i;
                imgView.clipsToBounds = YES;
                imgView.layer.cornerRadius = 1.25;
                imgView.contentMode = UIViewContentModeCenter;
                imgView.image = (i == currentPage)? [ESFoundationAssets bundleImage:@"loop_currentPageImage"]: [ESFoundationAssets bundleImage:@"loop_pageImage"];
                [self addSubview:imgView];
            }
            //            CGContextSetFillColorWithColor(context, [(i == currentPage)? currentColor: otherColour CGColor]);
            //            CGContextFillEllipseInRect(context, CGRectMake(offset + (controlSize + controlSpacing) * i, (self.frame.size.height / 2) - (controlSize / 2), controlSize, 10));
        } else {
            for (int i = 0; i < numberOfPages; i++) {
                UIImageView *imgView = [self viewWithTag:100+i];
                imgView.image = (i == currentPage)? [ESFoundationAssets bundleImage:@"loop_currentPageImage"]: [ESFoundationAssets bundleImage:@"loop_pageImage"];
            }
        }
        
    }
}

- (NSInteger)clampedPageValue:(NSInteger)page
{
    if (wrap)
    {
        return (page + numberOfPages) % numberOfPages;
    }
    else
    {
        return MIN(MAX(0, page), numberOfPages - 1);
    }
}

- (void)setCurrentPage:(NSInteger)page
{
    currentPage = [self clampedPageValue:page];
    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)pages
{
    if (numberOfPages != pages)
    {
        numberOfPages = pages;
        if (currentPage >= numberOfPages)
        {
            currentPage = numberOfPages - 1;
        }
        [self setNeedsDisplay];
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    currentPage = [self clampedPageValue:currentPage + ((point.x > self.frame.size.width/2)? 1: -1)];
    if (!defersCurrentPageDisplay)
    {
        [self setNeedsDisplay];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(self.superview.bounds.size.width, [self sizeForNumberOfPages:1].height);
}



@end
