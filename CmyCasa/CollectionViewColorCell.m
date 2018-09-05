//
//  CollectionViewColorCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 9/24/13.
//
//

#import "CollectionViewColorCell.h"

@implementation CollectionViewColorCell

-(void)refreshWithContent:(PaintColorPalletItemDO*)data  andDelegate:( id<SinglePaletteColorDelegate>) delegate{
    
    if (!self.pallet) {
        self.pallet = [SinglePaletteColorViewController initWithArray:data];
        if (self.pallet) {
            [self addSubview:self.pallet.view];
        }
    }
        
    self.pallet.delegate = delegate;
    [self.pallet refreshWithData:data];
    
}
@end
