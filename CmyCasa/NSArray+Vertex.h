//
//  NSArray+Vertex.h
//  CmyCasa
//
//  Created by Or Sharir on 12/30/12.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@interface NSArray (Vertex)
-(GLKVector3)getVectorForVertex:(NSUInteger)index;
-(NSDictionary*)getDictionaryForVertex:(NSUInteger)index;
@end
