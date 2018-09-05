//
//  ImageEffectsViewController_iPad.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/10/13.
//
//

#import "ImageEffectsViewController_iPad.h"
#import "EffectCollectionCell.h"

@interface ImageEffectsViewController_iPad ()
@property (weak, nonatomic) IBOutlet UIButton *btnCancelButton;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblChooseAnEffect;

@end

@implementation ImageEffectsViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lblChooseAnEffect.text = NSLocalizedString(@"choose_an_effect_title", @"choose an effect popup title");
    self.lblTitle.text = NSLocalizedString(@"share_your_design_title", @"view title");
    
    if (self.isMaskLandscape) {
        self.lblChooseAnEffect.hidden = YES;
        self.showMyNameSwitch.hidden = YES;
        self.lblSwitchTitleAuthorName.hidden = YES;
        self.showBeforeAfter.hidden = YES;
        self.lblSwitchTitleInclude.hidden = YES;
        self.collectionViewPlaceholder.hidden = YES;
        self.btnCancelButton.hidden = YES;
    }
    
}

#pragma mark - PSUICollectionView stuff
- (void)refreshCancelButtonText
{
    switch (self.shareScreenMode)
    {
        case ShareScreenModeOpenFromOtherController:
        {
            [self.btnCancelButton setTitle:NSLocalizedString(@"share_your_design_skip_button_title", @"button title skip") forState:UIControlStateNormal];
            [self.btnCancelButton setTitle:NSLocalizedString(@"share_your_design_skip_button_title", @"button title skip") forState:UIControlStateHighlighted];
        }
            break;
        case ShareScreenModeOpenByUser:
        {
            [self.btnCancelButton setTitle:NSLocalizedString(@"redesign_sign_in_cancel_button", @"button title cancel") forState:UIControlStateNormal];
            [self.btnCancelButton setTitle:NSLocalizedString(@"redesign_sign_in_cancel_button", @"button title cancel") forState:UIControlStateHighlighted];
            break;
        }
            
        default:
            break;
    }
}

-(void)initCollectionView{
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
   
	[collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	[collectionViewFlowLayout setItemSize:CGSizeMake(EFFECT_THUMB_SIZE, EFFECT_THUMB_SIZE)];
	[collectionViewFlowLayout setHeaderReferenceSize:CGSizeMake(0, 0)];
	[collectionViewFlowLayout setFooterReferenceSize:CGSizeMake(0, 0)];
	[collectionViewFlowLayout setMinimumInteritemSpacing:10];
	[collectionViewFlowLayout setMinimumLineSpacing:10];
	[collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	
    CGRect frm = self.collectionViewPlaceholder.frame;
    frm.origin = CGPointMake(0, 0);
    
	self.collectionView = [[UICollectionView alloc] initWithFrame:frm collectionViewLayout:collectionViewFlowLayout];
	[self.collectionView setDelegate:self];
	[self.collectionView setDataSource:self];
	[self.collectionView setBackgroundColor:[UIColor clearColor]];
	[self.collectionView registerClass:[EffectCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionViewPlaceholder addSubview:self.collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(EFFECT_THUMB_SIZE, EFFECT_THUMB_SIZE);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
