//
//  EffectCollectionCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 10/10/13.
//
//

#import <UIKit/UIKit.h>

#import "EffectImageViewController.h"

@class PSTCollectionView;
@class ImageEffectsBaseViewController;

@interface EffectCollectionCell : UICollectionViewCell

@property(nonatomic,strong) EffectImageViewController *effectItem;

-(void)updateCellWithData:(UIImage*)image
              andDelegate:(id<ImageEffectsCellDelegate>)delegate
                 andIndex:(NSInteger)index
                    title:(NSString*)title;
@end

