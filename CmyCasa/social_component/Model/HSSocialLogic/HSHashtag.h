//
//  HSHashtag.h
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/10/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	HSHashtagTypeFacebook = 0,
    HSHashtagTypeTwitter = 1
} HSHashtagType;

typedef enum
{
	HSHashtagLocationStart = 0,
    HSHashtagLocationEnd = 1
} HSHashtagLocation;

@interface HSHashtag : NSObject

- (id)initWithText:(NSString *)text type:(HSHashtagType)type andLocation:(HSHashtagLocation)location;
- (NSComparisonResult)compare:(HSHashtag *)hashtag;
- (BOOL)isEqual:(id)object;

@property (nonatomic, readonly) NSString *text;
@property (nonatomic) HSHashtagType type;
@property (nonatomic) HSHashtagLocation location;

@end
