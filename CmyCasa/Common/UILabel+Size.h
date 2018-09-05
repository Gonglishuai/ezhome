    //
//  UILabel+Size.h
//  CmyCasa
//
//  Created by Berenson Sergei on 1/24/13.
//
//

#import <Foundation/Foundation.h>

@interface UILabel (Size)

- (CGFloat)resizeHeightToFit;
- (CGFloat)resizeHeightToFitWithMinimumHeight:(CGFloat)minHeight;
- (CGFloat)expectedHeight;

-(CGSize)getActualTextHeightForLabelWithCGFloat:(CGFloat)maxHeightFloat;
-(CGSize)getActualTextHeightForLabel:(NSInteger)maxHeight;
-(CGSize)getActualTextWidthForLabel:(CGFloat)maxWidth;
@end
