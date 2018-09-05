//
//  ProfProjectAssetController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfProjectAssetDO.h"

@protocol ProfessionalProjectDelegate <NSObject>

-(void)designSelected:(ProfProjectAssetDO*)selectedDesign;

@end


@interface iphoneProfProjectAssetController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *assetImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *projectTitle;
@property( nonatomic) BOOL isAssetLoaded;
- (IBAction)chooseDesignAction:(id)sender;

-(void)initWithAssset:(ProfProjectAssetDO*)_sset;
@property(nonatomic)ProfProjectAssetDO * asset;

@property(nonatomic) id <ProfessionalProjectDelegate> delegate;

@end
