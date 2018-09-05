//
//  EffectCollectionCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/10/13.
//
//

#import "EffectCollectionCell.h"
#import "ControllersFactory.h"

@implementation EffectCollectionCell
- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		[self setBackgroundColor:[UIColor whiteColor]];
	}
	return self;
}

-(void)updateCellWithData:(UIImage*)image andDelegate:(id<ImageEffectsCellDelegate>)delegate  andIndex:(NSInteger)index title:(NSString*)title
{
    if (!image || [image isKindOfClass:[NSNull class]])
        return;
    
    if (!self.effectItem) {
        self.effectItem = [ControllersFactory instantiateViewControllerWithIdentifier:@"EffectImageViewController" inStoryboard:kRedesignStoryboard];
        
        if (self.effectItem) {
            [self addSubview:self.effectItem.view];
        }
    }
    
    if (self.effectItem)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.effectItem.effectImage.image = image;
            self.effectItem.effectTitle.text = title;
        });
        
        self.effectItem.delegate = delegate;
        self.effectItem.effectIndex = index;
        self.effectItem.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

@end






