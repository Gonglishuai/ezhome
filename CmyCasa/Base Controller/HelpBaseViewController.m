//
//  HelpBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import "HelpBaseViewController.h"
#import "UILabel+Size.h"

@interface HelpBaseViewController ()
@end

@implementation HelpBaseViewController

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self loadHelpImage];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)loadHelpImage{
    
    if (self.pageKey) {
        NSString * helpImage = [[HelpManager sharedInstance] getHelpImageForKey:self.pageKey];
        
        NSDictionary * helpOffset = [[HelpManager sharedInstance] getHelpOffsetForKey:self.pageKey];
        int xOffset  = 0;
        int yOffset  = 0;
        
        xOffset =[[helpOffset objectForKey:@"x"] intValue];
        yOffset =[[helpOffset objectForKey:@"y"] intValue];
        
        if ([HelpManager isRemoteUrl:helpImage]) {
    
            [[GalleryServerUtils sharedInstance] loadImageFromUrl:self.helpImageUI url:helpImage];

        }else{
            UIImage * img=[UIImage imageNamed:helpImage];
            if (IS_IPAD) {
                 self.view.frame = CGRectMake(xOffset, yOffset, img.size.width, img.size.height);
            }
            [self.helpImageUI setImage:img];
            [self loadHelpLabels:img.size];
        }
    }
}

-(void)loadHelpLabels:(CGSize)imageSize{
    
    for (UILabel *lbl in [self.view subviews] ) {
        if ([lbl isKindOfClass:[UILabel class]]) {
            [lbl removeFromSuperview];
        }
    }
    
    NSMutableArray * helpLabels = [[HelpManager sharedInstance] gelpHelpTitlesForKey:self.pageKey];
    
    for (int i=0; i<[helpLabels count]; i++) {
        
        NSDictionary * item=[helpLabels objectAtIndex:i];
        
        //get label width
        int labelwidth=[[item objectForKey:@"max_width"] intValue];
        float fontSize =[[item objectForKey:@"fontSize"] intValue];
        if(fontSize == 0)
        {
            fontSize = 17.0f;
        }
        
        int x=[[item objectForKey:@"x"] intValue];
        int y=[[item objectForKey:@"y"] intValue];
        
        if (!IS_IPAD) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            CGFloat scaleW = screenSize.width * 0.85 / imageSize.width;
            CGFloat scaleH = screenSize.height * 0.85 / imageSize.height;
            CGFloat scale = scaleW > scaleH ? scaleH : scaleW;
            CGFloat imageX = (screenSize.width - imageSize.width * scale) * 0.5;
            CGFloat imageY = (screenSize.height - imageSize.height * scale) * 0.5;
            x = (int)(imageX + x * scale);
            y = (int)(imageY + y * scale);
            labelwidth = (int)(labelwidth * scale);
            fontSize *= scale;
        }
        
        UILabel * lbl=[[UILabel alloc] initWithFrame:CGRectMake(x,
                                                                y
                                                                , labelwidth, 22)];
        
        [lbl setBackgroundColor:[UIColor clearColor]];
        float color =[[item objectForKey:@"fontColor"] intValue];
        if(color == 0)
        {
            [lbl setTextColor:[UIColor colorWithRed:133.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1.0]];
        }
        else
        {
            [lbl setTextColor:[UIColor colorWithRed:color/255.0f green:color/255.0f blue:color/255.0f alpha:1.0]];
        }
        [lbl setValue:@"AbortNUILabel" forKeyPath:@"nuiClass"];

        [lbl setFont:[UIFont systemFontOfSize:fontSize]];
        [lbl setNumberOfLines:[[item objectForKey:@"rows"] intValue]];
        lbl.adjustsFontSizeToFitWidth=YES;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            lbl.minimumScaleFactor=0.6f;
        }
        
        NSString * key=[item objectForKey:@"label"];
        
        if ([key isEqualToString:@"help_note_label1"]) {
            if ([ConfigManager isWhiteLabel]) {
                lbl.text = @"";
            }else{
                lbl.text = NSLocalizedString(key, @"");
            }
        }else{
            lbl.text = NSLocalizedString(key, @"");
        }
        
        //get text size for real text and limit
        
        CGSize sz=[lbl getActualTextWidthForLabel:labelwidth];
        BOOL isCentered = [[item objectForKey:@"isCentered"] boolValue];
     
        if(isCentered) {
            [lbl setTextAlignment:NSTextAlignmentCenter];
        }
        CGRect rect = CGRectMake(x, y, labelwidth, sz.height*[[item objectForKey:@"rows"] intValue]);

        lbl.frame=rect;
        [lbl setAccessibilityLabel:@"lbl_refine_your_resualts"];
        [self.view addSubview:lbl];
    }
}



-(void)HelpImageLoaded:(NSNotification*)notification{
    NSString* path = [[notification userInfo] objectForKey:@"path"];
    
    UIImage * img=[UIImage safeImageWithContentsOfFile:path];
    if(img!=NULL)
    {
        [self.helpImageUI setImage:img];
        [self loadHelpLabels:img.size];
    }
}

- (IBAction)closeHelpAction:(id)sender {
    if (self.closeHelpButton) self.closeHelpButton.enabled = NO;
    NSString* strKey = self.pageKey;
    if (self.extraKeys==nil || [self.extraKeys count]==0) {
        [[HelpManager sharedInstance] helpClosedForKey:strKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:HelpViewClosedNotification object:strKey];
        
    }else{
        if([self.extraKeys count]>0)
        {
            NSString * nextKey=[self.extraKeys objectAtIndex:0];
            [self.extraKeys removeObjectAtIndex:0];
            self.pageKey=nextKey;
            
            [self loadHelpImage];
        }
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

-(void)setBtnState:(BOOL) bIsEnabled
{
    _closeHelpButton.enabled = bIsEnabled;
}

@end
