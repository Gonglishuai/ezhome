//
//  DesignMetaData.h
//  CmyCasa
//
//  Created by Dor Alon on 1/31/13.
//
//

#import <Foundation/Foundation.h>

@interface DesignMetaData : NSObject
@property (nonatomic, strong) NSString* DesignId;
@property (nonatomic, strong) NSString* Title;
@property (nonatomic, strong) NSString* Description;
@property (assign) Boolean IsPublished;
@end
