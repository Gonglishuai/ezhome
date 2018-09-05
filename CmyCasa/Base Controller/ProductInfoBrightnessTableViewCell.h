//
//  ProductInfoBrightnessTableViewCell.h
//  Homestyler
//
//  Created by Dan Baharir on 11/18/14.
//
//

#import <UIKit/UIKit.h>

@interface ProductInfoBrightnessTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *optionButton;
@property (weak, nonatomic) IBOutlet UIButton *resetBrightnessButton;
- (IBAction)resetBrightness:(id)sender;

@end
