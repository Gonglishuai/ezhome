//
//  SinglePaletteWallpaperViewController.m
//  CmyCasa
//
//  Created by Or Sharir on 2/6/13.
//
//

#import "SinglePaletteWallpaperViewController.h"
#import "ControllersFactory.h"
#import "NSString+Contains.h"
#import "UILabel+NUI.h"


@interface SinglePaletteWallpaperViewController () {
}

-(IBAction)wallpaperPressed:(id)sender;

@end

@implementation SinglePaletteWallpaperViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![ConfigManager isWhiteLabel]) {
        [self.patternImageView setImage:[UIImage imageNamed:@"loading.png"]];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)dealloc
{
    self.patternImageView.image = nil;
    self.patternImageView = nil;
    self.wallpaper = nil;
}

+(SinglePaletteWallpaperViewController*)palleteWithPatternImage:(UIImage*)image {
    if (!image) return nil;
    SinglePaletteWallpaperViewController* ret = (SinglePaletteWallpaperViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"SinglePaletteWallpaper" inStoryboard:kRedesignStoryboard];
    
    if (ret) {
        ret.wallpaper.image = image;
        ret.view = ret.view;
        ret.view.frame = CGRectMake(0, 0, kSinglePaletteWallpaperViewWidth, kSinglePalleteWallpaperViewHeight);
    }
    return ret;
}

+(SinglePaletteWallpaperViewController*)palleteWithWallpaperDO:(TilingDO *)wallpaper {
    if (!wallpaper) return nil;
    SinglePaletteWallpaperViewController* ret = (SinglePaletteWallpaperViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"SinglePaletteWallpaper" inStoryboard:kRedesignStoryboard];
    
    if (ret)
    {
        ret.paletteName = wallpaper.title;
        ret.wallpaper = wallpaper;
        ret.view = ret.view;
        ret.view.frame = CGRectMake(0, 0, kSinglePaletteWallpaperViewWidth, kSinglePalleteWallpaperViewHeight);
    }
    return ret;
}

-(IBAction)wallpaperPressed:(id)sender {
    
    if (self.delegate && self.wallpaper.image !=nil && self.wallpaper.isImageDataAvailable )
    {
        [self.delegate wallpaperSelected:self.wallpaper.image  withParentObject:self.wallpaper];
    }
    else
    {
        HSMDebugLog(@"wallpaperPressed, image not loaded");
    }
}

-(void)loadWallpaperForCollection:(TilingDO *)wall
{
    self.wallpaper = wall;
    self.paletteName = wall.title;
    
    if ([NSString isNullOrEmpty:self.paletteName])
    {
        [self.paletteNameView setHidden:YES];
    }
    else
    {
        self.paletteNameLbl.text = self.paletteName;
        [self.paletteNameView setHidden:NO];
    }
    
    if (wall.tilingProperties && [wall.tilingProperties count] > 0)
    {
        // We display the top 2 properties
        self.paletteNameLbl.text = @"";
        for (NSDictionary *propAndVal in wall.tilingProperties)
        {
            NSArray *properitesArray = [propAndVal allKeys];
            
            NSString *property = [properitesArray objectAtIndex:0];
            NSString *value = [propAndVal objectForKey:property];
            
            NSString *line = [NSString stringWithFormat:@"%@:\n%@", property, value];
            
            if ([self.paletteNameLbl.text isEqual:@""])
            {
                self.paletteNameLbl.text = line;
            }
            else
            {
                self.paletteNameLbl.text = [NSString stringWithFormat:@"%@\n\n%@", self.paletteNameLbl.text, line];
            }
            
            if (wall.tileURL)
            {
                [self.paletteNameLbl setNuiClass:@"SinglePaletteViewController_PaletteNameLabelLink"];
                [self.paletteNameLbl applyNUI];
            }
            
        }
        
        
    }
    else if (![NSString isNullOrEmpty:self.paletteName])
    {
        // If we only have a title for this pallette we display it regularly
        self.paletteNameLbl.text = self.paletteName;
        [self.paletteNameView setHidden:NO];
    }
    
    
    if (self.wallpaper.image)
    {
        self.patternImageView.image = self.wallpaper.image;
    }
    else
    {
        //Loading the image in background
        self.patternImageView.image = nil;
        [self.loadingIndicator startAnimating];
        
        [self.wallpaper loadThumbnailInBackground:^(UIImage *image) {
            //We get here on the main thread
            if ([self.wallpaper.thumbURL isEqualToString:wall.thumbURL]) {
                self.patternImageView.image = image;
                [self.loadingIndicator stopAnimating];
            }
        }];
        
        [self.wallpaper loadImageInBackground:^(UIImage *image) {
            //We get here on the main thread
            if ([self.wallpaper.imageURL isEqualToString:wall.imageURL] && !self.wallpaper.thumbURL) {
                self.patternImageView.image = image;
                [self.loadingIndicator stopAnimating];
            }
        }];
    }
}

- (IBAction)paletteNamePressed:(id)sender
{
    if (self.wallpaper.tileURL == nil)
        return;
    
    NSString *url = [[NSString alloc] initWithString:self.wallpaper.tileURL];
    if (![NSString isNullOrEmpty:url])
    {
        if ([url rangeOfString:@"http://"].location == NSNotFound)
        {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        
        NSURL * surl=[NSURL URLWithString:url];
        if (surl)
        {
            [[UIApplication sharedApplication] openURL:surl];
        }
    }
}

@end
