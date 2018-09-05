//
//  UILabel+Size.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/24/13.
//
//

#import "UILabel+Size.h"

@implementation UILabel (Size)

-(CGFloat)resizeHeightToFit {
    return [self resizeHeightToFitWithMinimumHeight:0];
}

-(CGFloat)resizeHeightToFitWithMinimumHeight:(CGFloat)minHeight {
    CGFloat height = [self expectedHeight];
    if (height < minHeight) {
        height = minHeight;
    }
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return height;
}

-(CGFloat)expectedHeight {
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping];

    CGSize expectedLabelSize = [self getActualTextHeightForLabelWithCGFloat:9999];
    return expectedLabelSize.height;
}

-(CGSize)getActualTextHeightForLabelWithCGFloat:(CGFloat)maxHeightFloat
{
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width, maxHeightFloat);
	
    CGRect textRect = [self.text boundingRectWithSize:maximumLabelSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:self.font}
                                         context:nil];
    
    CGSize expectedLabelSize = textRect.size;
    
	//adjust the label the the new height.
	CGRect newFrame = self.frame;
	newFrame.size.height = expectedLabelSize.height;
	
	return expectedLabelSize;
}

-(CGSize)getActualTextHeightForLabel:(NSInteger)maxHeight
{
	return [self getActualTextHeightForLabelWithCGFloat:(float)maxHeight];
}

-(CGSize)getActualTextWidthForLabel:(CGFloat)maxWidth
{	
	CGSize maximumLabelSize = CGSizeMake(maxWidth,self.frame.size.height);
	
    CGRect textRect = [self.text boundingRectWithSize:maximumLabelSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:self.font}
                                              context:nil];

    CGSize expectedLabelSize = textRect.size;
	
	//adjust the label the the new height.
	CGRect newFrame = self.frame;
	newFrame.size.height = expectedLabelSize.height;

	return expectedLabelSize;
}

@end
