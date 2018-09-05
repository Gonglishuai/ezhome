//
//  SinglePaletteColorViewController.h
//  CmyCasa
//
//  Created by Or Sharir on 1/29/13.
//
//

#import <UIKit/UIKit.h>
#import "PaintColorPalletItemDO.h"

#define kSinglePaletteColorViewWidth (116)
#define kSinglePalleteColorViewHeight (286)

@protocol SinglePaletteColorDelegate <NSObject>

-(void)colorSelected:(UIColor*)color andSourceObject:(PaintColorPalletItemDO*)colorObject;
-(void)setChoosenColorName:(NSString*)colorIDName;
@end

@interface SinglePaletteColorViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton* colorButton1;
@property (strong, nonatomic) IBOutlet UILabel* colorLabel1;

@property (strong, nonatomic) IBOutlet UIButton* colorButton2;
@property (strong, nonatomic) IBOutlet UILabel* colorLabel2;

@property (strong, nonatomic) IBOutlet UIButton* colorButton3;
@property (strong, nonatomic) IBOutlet UILabel* colorLabel3;

@property (strong, nonatomic) IBOutlet UIButton* colorButton4;
@property (strong, nonatomic) IBOutlet UILabel* colorLabel4;
@property (weak, nonatomic) id<SinglePaletteColorDelegate> delegate;


@property (nonatomic)PaintColorPalletItemDO * myPallet;
+(SinglePaletteColorViewController*)initWithArray:(PaintColorPalletItemDO*)data;
-(void)refreshWithData:(PaintColorPalletItemDO*)data;

@end

