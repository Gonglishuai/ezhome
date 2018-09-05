//
//  SinglePaletteWallpaperViewController.h
//  CmyCasa
//
//  Created by Or Sharir on 2/6/13.
//
//

#import <UIKit/UIKit.h>
#import "TilingDO.h"

#define kSinglePaletteWallpaperViewWidth (151)
#define kSinglePalleteWallpaperViewHeight (286)

@protocol SinglePaletteWallpaperDelegate <NSObject>

-(void)wallpaperSelected:(UIImage*)image withParentObject:(TilingDO *)wallpaper;

@end

@interface SinglePaletteWallpaperViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView                     *paletteNameView;
@property (weak, nonatomic) IBOutlet UILabel                    *paletteNameLbl;
@property (weak, nonatomic) IBOutlet UIButton                   *paletteNameButton;
@property (strong, nonatomic) NSString                          *paletteName;
@property (weak, nonatomic) IBOutlet UIImageView                *patternImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *loadingIndicator;
@property (strong, nonatomic) TilingDO * wallpaper;
@property (weak, nonatomic) id<SinglePaletteWallpaperDelegate> delegate;

+(SinglePaletteWallpaperViewController*)palleteWithPatternImage:(UIImage*)image;
+(SinglePaletteWallpaperViewController*)palleteWithWallpaperDO:(TilingDO *)wallpaper;
-(void)loadWallpaperForCollection:(TilingDO *)wall;
-(IBAction)paletteNamePressed:(id)sender;
@end
