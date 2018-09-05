//
//  GalleryStreamViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import "GalleryStreamBaseController.h"

@interface GalleryStreamViewController_iPhone : GalleryStreamBaseController <GalleryStreamViewControllerDelegate, IphoneMenuManagerDelegate>
{
    BOOL _isPickerShowen;
}

- (IBAction)scrollToTopStream:(id)sender;

@end
