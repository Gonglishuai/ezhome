//
//  ESIMGalleryViewController.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESIMGalleryViewController.h"
#import "UIImageView+WebCache.h"

@implementation ESIMGalleryItem
@end

@interface ESIMGalleryViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *galleryImageView;
@property (nonatomic,strong) ESIMGalleryItem *currentItem;

@end

@implementation ESIMGalleryViewController
- (instancetype)initWithItem:(ESIMGalleryItem *)item {
    if (self = [super initWithNibName:@"ESIMGalleryViewController"
                               bundle:nil])
    {
        _currentItem = item;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _galleryImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSURL *url = [NSURL URLWithString:_currentItem.imageURL];
    [_galleryImageView sd_setImageWithURL:url
                         placeholderImage:[UIImage imageWithContentsOfFile:_currentItem.thumbPath]
                                  options:SDWebImageRetryFailed];
    
    if ([_currentItem.name length])
    {
        self.navigationItem.title = _currentItem.name;
    }
}

@end
