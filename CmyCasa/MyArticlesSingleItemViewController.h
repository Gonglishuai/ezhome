//
//  MyArticlesSingleItemViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 1/10/13.
//
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"

@interface MyArticlesSingleItemViewController : UIViewController
{
    @private
    NSString* _articleId;
}
- (void) setArticle:(GalleryItemDO*) article;
@property (nonatomic, assign) id<MyDesignEditDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *articleText;
- (IBAction)articlePressed:(id)sender;
@end
