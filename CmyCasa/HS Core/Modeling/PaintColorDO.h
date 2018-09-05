//
//  PaintColorDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <Foundation/Foundation.h>

@interface PaintColorDO : NSObject

- (id) initWithDict:(NSDictionary*)dict;

@property (nonatomic, readonly) NSString* colorHex;
@property (nonatomic, readonly) NSString* colorID;

@end
