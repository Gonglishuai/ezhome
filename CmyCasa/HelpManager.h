//
//  HelpManager.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/3/13.
//
//

#import <Foundation/Foundation.h>
static NSString * HelpViewClosedNotification=@"HelpViewClosedNotification";
@interface HelpManager : NSObject


+ (id)sharedInstance;
+(BOOL)isRemoteUrl:(NSString*)path;
-(NSString*)getHelpImageForKey:(NSString*)pageKey;
-(NSMutableArray*)gelpHelpTitlesForKey:(NSString*)pageKey;
-(NSDictionary*)getHelpOffsetForKey:(NSString*)pageKey;

-(BOOL)presentHelpViewController:(id)helpKey withController:(UIViewController*)controller;
-(BOOL)presentHelpViewController:(id)helpKey withController:(UIViewController*)controller isForceToShow:(BOOL) bIsForceToShow; 
-(void)helpClosedForKey:(NSString*)closekey;
-(BOOL)isHelpOpenForKey:(NSString*)helpkey;
-(void)resetHelpKey:(NSString*)helpKey;
-(void)resetToShowHelp;
-(CGRect)frameOfHelpWithKey:(NSString*)key;
@property(nonatomic)NSMutableDictionary * helpTempDicts;
@end
