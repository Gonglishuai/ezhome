//
//  PaintColorCompanyCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 6/6/13.
//
//

#import <UIKit/UIKit.h>

@interface PaintColorCompanyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingInicator;
@property (weak, nonatomic) IBOutlet UIImageView *companyLogo;
@property (weak, nonatomic) IBOutlet UIImageView *selectionBG;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (nonatomic,strong) NSString * websiteURL;
@property (nonatomic,weak) id<GenericWebViewDelegate> genericWebViewDelegate;

- (IBAction)openWebSiteAction:(id)sender;

@end
