//
//  CollectionViewWallPaperCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 9/24/13.
//
//

#import "CollectionViewWallPaperCell.h"

@implementation CollectionViewWallPaperCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
    if (self)
		[self setBackgroundColor:[UIColor clearColor]];
    
	return self;
}

-(void)prepareForReuse
{
    if (self.pallet)
    {
        [self.pallet.wallpaper clearCache];
    }
}

- (void)dealloc
{
    self.pallet = nil;
}

-(void)refreshWithContent:(TilingDO *)data  andDelegate:( id<SinglePaletteWallpaperDelegate>) delegate{
    
    if (!self.pallet)
    {
        self.pallet = [SinglePaletteWallpaperViewController palleteWithWallpaperDO:data];
        if (self.pallet)
        {
            [self addSubview:self.pallet.view];
        }
    }
    if (self.pallet)
    {
        [self.pallet.wallpaper clearCache];
        self.pallet.delegate = delegate;
        [self.pallet loadWallpaperForCollection:data];
    }
}

@end
