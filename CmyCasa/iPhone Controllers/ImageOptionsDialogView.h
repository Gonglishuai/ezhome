//
//  ImageOptionsDialogView.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 7/28/14.
//
//

#import <UIKit/UIKit.h>

@protocol ImageOptionsDialogViewDelegate <NSObject>

- (void)closeImageOptionsDialogView;
- (void)concealClicked;
- (void)brightnessClicked;

@end

@interface ImageOptionsDialogView : UIView{
    IBOutlet UIButton* _concealerBtn;
    IBOutlet UIButton* _brightnessBtn;
}

@property (nonatomic, weak) id<ImageOptionsDialogViewDelegate> delegate;
@end
