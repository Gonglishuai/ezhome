//
//  MyDesignDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import <Foundation/Foundation.h>
#import "DesignBaseClass.h"


@interface MyDesignDO : DesignBaseClass <NSCoding,RestkitObjectProtocol>

@property(nonatomic, strong) NSString *autoSavedDesignRefID;


- (id)initWithDict:(NSDictionary*)dict;
- (MyDesignDO*)duplicate;
- (NSString *)getAutoSavedDesignReference;
- (void)setupAutoSaveRef:(NSString *)designId;

@end
