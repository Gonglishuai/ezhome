//
//  SwappableVariationView.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/23/14.
//
//

#import <UIKit/UIKit.h>


@protocol SwappableVariationViewDelegate <NSObject>

-(void)swappableVariationClickedWithIndex:(NSNumber*)index;

@end


//////////////////////////////////////////////////////////////////////
// CLASS
/////////////////////////////////////////////////////////////////////
@interface SwappableVariationView : UIView

+(id)getSwappableVriationView;

-(void)setupSwappabelVariationImage:(NSString*)imageURL;

@property (weak, nonatomic) id<SwappableVariationViewDelegate> swappableVariationViewDelegate;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;


@end
