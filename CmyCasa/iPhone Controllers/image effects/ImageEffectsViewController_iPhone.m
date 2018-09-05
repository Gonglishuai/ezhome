//
//  ImageEffectsViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/13/13.
//
//

#import "ImageEffectsViewController_iPhone.h"
#import "EffectCollectionCell.h"
#define EFFECT_THUMB_SIZE_IPHONE 67

@interface ImageEffectsViewController_iPhone ()
@property (weak, nonatomic) IBOutlet UILabel *lblScreenTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblChooseAnEffect;
@property (weak, nonatomic) IBOutlet UIImageView *imgChooseAnEffect;
@property (weak, nonatomic) IBOutlet UILabel *lblAuthorName;
@property (weak, nonatomic) IBOutlet UILabel *lblBeforeAndAfter;
@property (weak, nonatomic) IBOutlet UISwitch *switchAuthorName;
@property (weak, nonatomic) IBOutlet UISwitch *switchBeforeAndAfter;
@property (weak, nonatomic) IBOutlet UIButton *arrowButton;


@property(nonatomic)BOOL isInMiddleAnimation;
@end

@implementation ImageEffectsViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lblScreenTitle.text = NSLocalizedString(@"share_your_design_title", @"view title");
    self.lblChooseAnEffect.text = NSLocalizedString(@"choose_an_effect_title", @"Choose an effect popup title");
    
    if (self.isMaskLandscape) {
        [self toggleEffectsPresentation:nil];
        self.arrowButton.hidden = YES;
    }
}

- (void)refreshCancelButtonText
{
    switch (self.shareScreenMode)
    {
        case ShareScreenModeOpenFromOtherController:
        {
            [self.btnLeftButton setTitle:NSLocalizedString(@"share_your_design_skip_button_title", @"button title skip") forState:UIControlStateNormal];
            [self.btnLeftButton setTitle:NSLocalizedString(@"share_your_design_skip_button_title", @"button title skip") forState:UIControlStateHighlighted];
        }
            break;
        case ShareScreenModeOpenByUser:
        {
            [self.btnLeftButton setTitle:NSLocalizedString(@"redesign_sign_in_cancel_button", @"button title cancel") forState:UIControlStateNormal];
            [self.btnLeftButton setTitle:NSLocalizedString(@"redesign_sign_in_cancel_button", @"button title cancel") forState:UIControlStateHighlighted];
            break;
        }
            
        default:
            break;
    }
}

-(void)hideChooseAnEffectPopup
{
//    self.imgChooseAnEffect.hidden = YES;
//    self.lblChooseAnEffect.hidden = YES;
}

-(void)initializeChooseAnEffectPopup
{
//    self.imgChooseAnEffect.hidden = NO;
//    self.lblChooseAnEffect.hidden = NO;
}

-(void)initCollectionView{
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
	[collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	[collectionViewFlowLayout setItemSize:CGSizeMake(EFFECT_THUMB_SIZE_IPHONE, EFFECT_THUMB_SIZE_IPHONE)];
	[collectionViewFlowLayout setHeaderReferenceSize:CGSizeMake(0, 0)];
	[collectionViewFlowLayout setFooterReferenceSize:CGSizeMake(0, 0)];
	[collectionViewFlowLayout setMinimumInteritemSpacing:10];
	[collectionViewFlowLayout setMinimumLineSpacing:10];
	[collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	
    CGRect frm = self.collectionViewPlaceholder.frame;
    frm.size.width = [UIScreen currentScreenBoundsDependOnOrientation].size.width;
    frm.origin=CGPointMake(0, 10);
    frm.size.height=EFFECT_THUMB_SIZE_IPHONE;
    frm.origin.x=5;
    frm.size.width-=10;
	self.collectionView = [[UICollectionView alloc] initWithFrame:frm collectionViewLayout:collectionViewFlowLayout];
	[self.collectionView setDelegate:self];
	[self.collectionView setDataSource:self];
	[self.collectionView setBackgroundColor:[UIColor clearColor]];
	[self.collectionView registerClass:[EffectCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionViewPlaceholder addSubview:self.collectionView];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - PSUICollectionView stuff
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(EFFECT_THUMB_SIZE_IPHONE, EFFECT_THUMB_SIZE_IPHONE);
}

- (IBAction)toggleEffectsPresentation:(id)sender {
   
    if ([self respondsToSelector:@selector(hideChooseAnEffectPopup)])
    {
        [self hideChooseAnEffectPopup];
    }
    
    UIButton *btn=(UIButton*)sender;
    
    if (self.isInMiddleAnimation) {
        return;
    }
    
    self.isInMiddleAnimation=YES;
    if (self.collectionViewPlaceholder.frame.origin.y<300) { //going to lower the bar
        //close
        
        btn.selected = YES;

        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect frn=self.collectionViewPlaceholder.frame;
            
            frn.origin.y= [UIScreen mainScreen].bounds.size.height;
            
            self.collectionViewPlaceholder.frame=frn;
            
            CGRect fr=btn.frame;
            fr.origin.y=[UIScreen mainScreen].bounds.size.height-fr.size.height;
            btn.frame=fr;
            
        } completion:^(BOOL finished) {
            self.isInMiddleAnimation=NO;
            
        }];
    }else{
        //open
        
        btn.selected = NO;
        
        [UIView animateWithDuration:0.2 animations:^{ //going to raise the bar
            
            CGRect frn=self.collectionViewPlaceholder.frame;
            
            frn.origin.y= [UIScreen mainScreen].bounds.size.height - self.collectionViewPlaceholder.frame.size.height;
            
            self.collectionViewPlaceholder.frame=frn;
            
            
            CGRect fr=btn.frame;
            fr.origin.y=frn.origin.y-fr.size.height;
            btn.frame=fr;
            
        } completion:^(BOOL finished) {
            self.isInMiddleAnimation=NO;
        }];
    }
}

@end
