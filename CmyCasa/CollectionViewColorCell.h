//
//  CollectionViewColorCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 9/24/13.
//
//

#import <UIKit/UIKit.h>

#import "SinglePaletteColorViewController.h"
@interface CollectionViewColorCell : UICollectionViewCell



@property(nonatomic,strong)SinglePaletteColorViewController * pallet;
-(void)refreshWithContent:(PaintColorPalletItemDO*)data  andDelegate:( id<SinglePaletteColorDelegate>) delegate;

@end
