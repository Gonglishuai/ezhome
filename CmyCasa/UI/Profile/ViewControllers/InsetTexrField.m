//
//  InsetTexrField.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 6/24/14.
//
//

#import "InsetTexrField.h"

@implementation InsetTexrField

- (CGRect)textRectForBounds:(CGRect)bounds {
    int margin = 5;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    int margin = 5;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}


@end
