//
//  SinglePaletteColorViewController.m
//  CmyCasa
//
//  Created by Or Sharir on 1/29/13.
//
//

#import "SinglePaletteColorViewController.h"
#import "PaintColorDO.h"
#import "ControllersFactory.h"


@interface SinglePaletteColorViewController ()
@property (nonatomic, strong) PaintColorPalletItemDO* data;

-(IBAction)colorButtonPressed:(id)sender;
-(UIButton*)buttonForIndex:(int)index;
@end

@implementation SinglePaletteColorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, kSinglePaletteColorViewWidth, kSinglePalleteColorViewHeight);
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)refreshWithData:(PaintColorPalletItemDO*)data{
    
    self.data=data;
    if (self.data) {
        NSArray *colors = [self.data getColorsForPallet];
        if (colors) {
            int index = 0;
            for (PaintColorDO* colorData in colors) {
                if (index >= colors.count - 4) {
                    UIButton* button = [self buttonForIndex:(int)(index - colors.count + 4)];
                    UILabel* label = [self labelForIndex:(int)(index - colors.count + 4)];
                    if (label && button) {
                        button.backgroundColor = [colorData.colorHex hextoColorDIY];
                        button.accessibilityLabel = [NSString stringWithFormat:@"btn_%@",label.text];
                        label.text = colorData.colorID;
                        label.accessibilityLabel = [NSString stringWithFormat:@"lbl_%@",label.text];
                    }
                }
                ++index;
            }
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(SinglePaletteColorViewController*)initWithArray:(PaintColorPalletItemDO*)data {
   
    
    if (data == nil) return nil;

    SinglePaletteColorViewController* ret = (SinglePaletteColorViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"SinglePaletteColor" inStoryboard:kRedesignStoryboard];
        
    if (ret) {
        ret.data = data;
    }
    return ret;
}

-(UIButton*)buttonForIndex:(int)index {
    switch (index) {
        case 0:
            return self.colorButton1;
            break;
        case 1:
            return self.colorButton2;
            break;
        case 2:
            return self.colorButton3;
            break;
        case 3:
            return self.colorButton4;
            break;
        default:
            return nil;
            break;
    }
}

-(UILabel*)labelForIndex:(int)index {
    switch (index) {
        case 0:
            return self.colorLabel1;
            break;
        case 1:
            return self.colorLabel2;
            break;
        case 2:
            return self.colorLabel3;
            break;
        case 3:
            return self.colorLabel4;
            break;
        default:
            return nil;
            break;
    }
}

-(IBAction)colorButtonPressed:(id)sender {
    UIButton* button = sender;
    if ([sender isEqual:self.colorButton1]) {
        [self.delegate setChoosenColorName:self.colorLabel1.text];
    }
    if ([sender isEqual:self.colorButton2]) {
        [self.delegate setChoosenColorName:self.colorLabel2.text];
    }
    if ([sender isEqual:self.colorButton3]) {
        [self.delegate setChoosenColorName:self.colorLabel3.text];
    }
    
    if ([sender isEqual:self.colorButton4]) {
        [self.delegate setChoosenColorName:self.colorLabel4.text];
    }
    [self.delegate colorSelected:button.backgroundColor  andSourceObject:self.data];
}
@end


