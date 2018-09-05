//
//  HSHashtag.m
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/10/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import "HSHashtag.h"

@interface HSHashtag ()

@property (nonatomic, strong) NSString *text;

@end


@implementation HSHashtag

- (id)initWithText:(NSString *)text type:(HSHashtagType)type andLocation:(HSHashtagLocation)location
{
    self = [super init];
    
    if (self)
    {
        self.text = text;
        self.type = type;
        self.location = location;
    }
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[HSHashtag class]])
    {
        HSHashtag *otherHashtag = object;
        return [self.text isEqualToString:otherHashtag.text];
    }
    
    return NO;
}

- (NSComparisonResult)compare:(HSHashtag *)hashtag
{
    NSComparisonResult result = [[NSNumber numberWithInt:self.location] compare:[NSNumber numberWithInt:hashtag.location]];
    
    return result;
}

@end
