//
//  ARConfigManager.h
//  EZHome
//
//  Created by xiefei on 19/9/17.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface ARConfigManager : NSObject

@property (copy,nonatomic) NSString *baseFilePath;

+(id)sharedInstance;
-(void)clearArModelsData;
@end
