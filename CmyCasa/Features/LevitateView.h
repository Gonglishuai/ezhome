
//
//  LevitateView.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 12/16/15.
//
//

#import <UIKit/UIKit.h>

@interface LevitateView : UIView

@property (nonatomic, strong, readonly) UIImageView * image;

-(void)touchDown;
-(void)touchUp;
@end