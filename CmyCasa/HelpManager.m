//
//  HelpManager.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/3/13.
//
//

#import "HelpManager.h"
#import "HelpViewController.h"
#import "ControllersFactory.h"

@interface HelpManager ()
{
}

@property(nonatomic) NSMutableDictionary * helpPages;
@property(nonatomic) NSString * imageBasePath;
@end

@implementation HelpManager
@synthesize helpTempDicts;


static HelpManager *sharedInstance = nil;

+ (HelpManager *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[HelpManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        self.helpPages = [NSMutableDictionary dictionaryWithCapacity:0];
        
        //replace plist load from local to remote
        self.helpTempDicts = [NSMutableDictionary dictionaryWithCapacity:0];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"helplinks" ofType:@"plist"];
        
        if (!IS_IPAD) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"helplinks_iphone" ofType:@"plist"];
        }

        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
      
        if(dict != NULL){
            
            self.imageBasePath = [dict objectForKey:@"base_image_path"];
            
            NSString * helplocale=[NSString stringWithFormat:@"helppages_%@",language];
            if ([dict objectForKey:helplocale]) {
                self.helpPages=[dict objectForKey:helplocale];
            }else
                self.helpPages=[dict objectForKey:@"helppages_en"];
        }
     
        if ( [self.helpPages objectForKey:@"remove_tip"] ) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"remove_tip"];
            
        }
        if ( [self.helpPages objectForKey:@"paint_line"] ) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"paint_line"];
            
        }
    }
    return self;
}


-(NSString*)getHelpImageForKey:(NSString*)pageKey{
    if ([sharedInstance.helpPages objectForKey:pageKey]) {
        
        if ([sharedInstance.imageBasePath length]>0) {
            
            NSString * image=[[sharedInstance.helpPages objectForKey:pageKey] objectForKey:@"image"];
            return [NSString stringWithFormat:@"%@/%@",sharedInstance.imageBasePath,
                    image];
        } else {
            NSString * image=[[sharedInstance.helpPages objectForKey:pageKey] objectForKey:@"image"];
            return [NSString stringWithFormat:@"%@",image];
        }
    }
    
    return nil;
}

-(NSMutableArray*)gelpHelpTitlesForKey:(NSString*)pageKey{
    
    return [[sharedInstance.helpPages objectForKey:pageKey] objectForKey:@"labels"];
}

-(NSDictionary*)getHelpOffsetForKey:(NSString*)pageKey{
    
    return [[sharedInstance.helpPages objectForKey:pageKey] objectForKey:@"offset"];
}

+(BOOL)isRemoteUrl:(NSString*)path{
 
    if ([path hasPrefix:@"http"]) {
        return true;
    }
    return false;
}
    
-(CGRect)frameOfHelpWithKey:(NSString*)key {
    if (self.helpTempDicts) {
        UIViewController* viewController = helpTempDicts[key];
        if (viewController) {
            return viewController.view.frame;
        }
    }
    return CGRectNull;
}
    
-(void)helpClosedForKey:(NSString*)closekey{
    //crash fix from build 96
    if (!closekey) {
        return;
    }
    if (self.helpTempDicts) {
        HelpViewController* viewController = helpTempDicts[closekey];
        if (viewController) {
            if (viewController.parentViewController) [viewController removeFromParentViewController];
            if (viewController.view.superview) {
                [viewController setBtnState:NO];
                [UIView animateWithDuration:0.35 animations:^{
                    viewController.view.alpha = 0;
                } completion:^(BOOL finished) {
                    if (viewController.view.superview) [viewController.view removeFromSuperview];
                }];
            }
        }
        
        [helpTempDicts removeObjectForKey:closekey];
    }
}
    
-(BOOL)isHelpOpenForKey:(NSString*)helpkey{
    if (self.helpTempDicts) {
        HelpViewController* viewController = helpTempDicts[helpkey];
        if (viewController) {
            return [viewController isViewLoaded];
        }
    }
    return NO;
}

-(void)resetToShowHelp
{
     for (NSString * key  in [self.helpPages allKeys]) {
         [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:key];
     }
}

-(void)resetHelpKey:(NSString*)helpKey
{
    for (NSString * key  in [self.helpPages allKeys]) {
        if ([key isEqualToString:helpKey]) {
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:key];
            break;
        }
    }
}

-(BOOL)presentHelpViewController:(id)helpKey withController:(UIViewController*)controller{
    return [self presentHelpViewController:helpKey withController:controller isForceToShow : NO ];
}

-(BOOL)presentHelpViewController:(id)helpKey withController:(UIViewController*)controller isForceToShow:(BOOL) bIsForceToShow {
    
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self presentHelpViewController:helpKey withController:controller isForceToShow:bIsForceToShow];
                       });
        return NO;
    }
    
    NSString * currentKey=@"";
    if ([helpKey isKindOfClass:[NSString class]]) {
        currentKey=helpKey;
        if(bIsForceToShow == NO)
        {
            bool bShown = [[[NSUserDefaults standardUserDefaults] objectForKey:currentKey] boolValue];
                
            if (bShown==YES )
            {
                return NO;
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:currentKey];
    
    HelpBaseViewController * _helpView = (HelpBaseViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"helpViewController" inStoryboard:kMainStoryBoard];
    
    if ([helpKey isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray* _helpKey=(NSMutableArray*)helpKey;
        if ([_helpKey count]>0) {
            currentKey=[_helpKey objectAtIndex:0];
            
            [_helpKey removeObjectAtIndex:0];
            
            _helpView.extraKeys = _helpKey;
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:currentKey] boolValue]==YES) {
               return false;
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:currentKey];
        }
    }
    
    _helpView.pageKey=currentKey;
      
    if ([self.helpTempDicts objectForKey:currentKey]) {
        HelpViewController * v=[self.helpTempDicts objectForKey:currentKey];
        [v removeFromParentViewController];
        [v.view removeFromSuperview];
        [self.helpTempDicts removeObjectForKey:currentKey];
    }
    
    [self.helpTempDicts setObject:_helpView forKey:currentKey];
    _helpView.view.alpha = 0;
    [controller.view addSubview:_helpView.view];
    [controller.view bringSubviewToFront:_helpView.view];
    [_helpView setBtnState:NO];

    [UIView animateWithDuration:0.35 animations:^{
        _helpView.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        [_helpView setBtnState:YES];

    }];
    
    return YES;
}

@end
