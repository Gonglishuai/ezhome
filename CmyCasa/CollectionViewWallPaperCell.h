//
//  CollectionViewWallPaperCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 9/24/13.
//
//

#import <UIKit/UIKit.h>

#import "SinglePaletteWallpaperViewController.h"
@interface CollectionViewWallPaperCell : UICollectionViewCell

@property(nonatomic,strong)SinglePaletteWallpaperViewController * pallet;

-(void)refreshWithContent:(TilingDO *)data  andDelegate:( id<SinglePaletteWallpaperDelegate>) delegate;

@end
