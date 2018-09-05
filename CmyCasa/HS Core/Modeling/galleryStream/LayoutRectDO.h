//
//  LayoutRectDO.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/12/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"

@interface LayoutRectDO : BaseRO <NSCoding,RestkitObjectProtocol>


@property(nonatomic,readonly)int x;
@property(nonatomic,readonly)int y;
@property(nonatomic,readonly)int w;
@property(nonatomic,readonly)int h;
@property(nonatomic,readonly)int left;
@property(nonatomic,readonly)int top;
@property(nonatomic,readonly)int _id;

-(id)initWithDictionary:(NSMutableDictionary*)dict;

@end
