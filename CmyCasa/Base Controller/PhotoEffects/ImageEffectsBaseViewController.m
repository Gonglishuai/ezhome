//
//  ImageEffectsBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/10/13.
//
//

#import "ImageEffectsBaseViewController.h"
#import "UIImage+Scale.h"
#import "EffectCollectionCell.h"
#import "EffectImageViewController.h"
#import "SaveDesignFlowBaseController.h"
#import "HSPhotolibEffectsInstance.h"
#import "ProtocolsDef.h"
#import "ProgressPopupViewController.h"
#import "HSMacros.h"


@interface ImageEffectsBaseViewController ()


@property(nonatomic,assign) BOOL isInMidleOfEffect;
@end

@implementation ImageEffectsBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.lblSwitchTitleAuthorName.text = NSLocalizedString(@"share_design_show_my_name", @"");
    CGRect frame = self.lblSwitchTitleAuthorName.frame;
    frame.origin.x = self.showMyNameSwitch.frame.origin.x + self.showMyNameSwitch.frame.size.width + 11;
    frame.size.width = self.showBeforeAfter.frame.origin.x - frame.origin.x - 10;
    self.lblSwitchTitleAuthorName.frame = frame;
    
    self.lblSwitchTitleInclude.text = NSLocalizedString(@"share_design_show_before_and_after", @"");
    frame = self.lblSwitchTitleInclude.frame;
    frame.origin.x = self.showBeforeAfter.frame.origin.x + self.showBeforeAfter.frame.size.width + 11;
    self.lblSwitchTitleInclude.frame = frame;
    
    self.isImageEffectsReady = NO;
    
    self.thumbnailsArray = [NSMutableArray arrayWithCapacity:0];
    
    [self initCollectionView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.nextButtonActivityIndicator stopAnimating];
}

- (void)initCollectionView{
    //implement in son's
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)refreshPresentingImagesWithMode:(ShareScreenMode)mode
{
    self.shareScreenMode = mode;
    if([self respondsToSelector:@selector(refreshCancelButtonText)])
    {
        [self refreshCancelButtonText];
    }
    
    if([self respondsToSelector:@selector(initializeChooseAnEffectPopup)])
    {
        [self initializeChooseAnEffectPopup];
    }
    
    if (self.presentingImage!=nil && self.originalImage) {
        
        if (![self.presentingImage.image isEqual:self.originalImage]) {
            //forces activeEffects to recreate
            self.isImageEffectsReady=NO;
        }
        
        self.afterEffectImage = self.originalImage;
        [self redrawPreviewImage];
    }
    
    [self activateEffects];
    
    if(!self.lastSelectedEffect)return;
    
    if(self.lastSelectedEffect.row<[[HSImageEffectsManager sharedInstance] getNumberOfCurrentEffects])
    {
        [self effectAtIndexSelected:self.lastSelectedEffect.row];
    }
}

- (void)refreshCancelButtonText
{
    
}

-(void)hideChooseAnEffectPopup
{
    
}

-(void)initializeChooseAnEffectPopup
{
    
}

- (IBAction)showMyNameAction:(id)sender {
    [self redrawPreviewImage];
}

- (IBAction)showBeforeAfterAction:(id)sender {
    [self redrawPreviewImage];
    
}

- (void) redrawPreviewImage {
    if (self.showBeforeAfter.isOn) {
        [self renderBeforeAndAfterImage];
    }else{
        [self renderAfterEffectImage];
    }
}

- (void) renderAfterEffectImage{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage * textImage =nil;
        if ([NSString notEmpty:self.designerName]) {
            textImage = [self imageFromText:self.designerName];
        }
        
        UIImage * resizedImage = [self.afterEffectImage scaleToFitLargestSideWithScaleFactor:1024 scaleFactor:1.0 supportUpscale:YES];
        
        CGRect frameRect = CGRectMake(0, 0, resizedImage.size.width, resizedImage.size.height);
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(frameRect.size.width,
                                                          frameRect.size.height),NO,0.0);
        [self.afterEffectImage drawInRect:frameRect];
        
        if (![ConfigManager isWhiteLabel]) {
            UIImage * logo = [UIImage imageNamed:@"logo@2x"];
            [logo drawInRect:CGRectMake(0, 10, logo.size.width, logo.size.height)];
        }
        
        if (self.showMyNameSwitch.isOn && textImage!=nil){
            UIImage * nameBG = [UIImage imageNamed:@"name_bg_share_screen@2x"];
            int bgPosX = frameRect.size.width - nameBG.size.width;
            int bgPosY = frameRect.size.height - nameBG.size.height;
            [nameBG drawInRect:CGRectMake(bgPosX,bgPosY,nameBG.size.width,nameBG.size.height)];
            
            int textPosX = frameRect.size.width - textImage.size.width -20;
            int textPosY = frameRect.size.height - textImage.size.height - 20;
            [textImage drawInRect:CGRectMake(textPosX,textPosY,textImage.size.width,textImage.size.height)];
        }
        
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.presentingImage.image = viewImage;
        });
    });
}

- (void) renderBeforeAndAfterImage {
    __block UIImage *viewImage = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        CGRect frameRect = CGRectMake(0, 0, 1024, 576);
        
        UIImage * textImage =nil;
        
        if ([NSString notEmpty:self.designerName]) {
            textImage = [self imageFromText:self.designerName];
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(frameRect.size.width,
                                                          frameRect.size.height),NO,0.0);
        
        // draw background color
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(ctx,0.14,0.14,0.14,1.0);
        CGContextFillRect(ctx, frameRect);
        
        int startX = 25;
        int startY = 25;
        
        // draw images
        UIImage* resizedOriginal = [self.designBaseImage scaleToFitLargestSideWithScaleFactor:400 scaleFactor:1.0 supportUpscale:YES] ;
        [resizedOriginal drawInRect:CGRectMake(startX,startY, resizedOriginal.size.width, resizedOriginal.size.height)];
        
        UIImage* resizedAfterEffects = [self.afterEffectImage scaleToFitLargestSideWithScaleFactor:660 scaleFactor:1.0 supportUpscale:YES] ;
        int aaPosX = 330;
        int aaPosY = 50;
        resizedAfterEffects = [resizedAfterEffects imageWithShadow];
        
        [resizedAfterEffects drawInRect:CGRectMake(aaPosX,aaPosY, resizedAfterEffects.size.width, resizedAfterEffects.size.height)];
        
        if (![ConfigManager isWhiteLabel]) {
            
            UIImage * logo = [UIImage imageNamed:@"logo@2x"];
            
            if (!IS_IPAD)
            {
                [logo drawInRect:CGRectMake(startX, aaPosY + resizedAfterEffects.size.height-logo.size.height, logo.size.width, logo.size.height)];
            }
            else
            {
                [logo drawInRect:CGRectMake(startX, aaPosY + resizedAfterEffects.size.height-logo.size.height, logo.size.width, logo.size.height)];
            }
        }
        
        // draw text
        if (self.showMyNameSwitch.isOn && textImage!=nil){
            UIImage * nameBG = [UIImage imageNamed:@"name_bg_share_screen@2x"];
            int bgPosX = aaPosX + resizedAfterEffects.size.width - nameBG.size.width;
            int bgPosY = aaPosY + resizedAfterEffects.size.height - nameBG.size.height;
            [nameBG drawInRect:CGRectMake(bgPosX,bgPosY,nameBG.size.width,nameBG.size.height)];
            
            int textPosX = aaPosX + resizedAfterEffects.size.width - textImage.size.width - 20;
            int textPosY = aaPosY + resizedAfterEffects.size.height - textImage.size.height - 20;
            [textImage drawInRect:CGRectMake(textPosX-4,textPosY+4,textImage.size.width,textImage.size.height)];
        }
        
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.presentingImage.image = viewImage;
        });
    });
}

//http://stackoverflow.com/questions/2765537/how-do-i-use-the-nsstring-draw-functionality-to-create-a-uiimage-from-text
-(UIImage *)imageFromText:(NSString *)text
{
    CGFloat fontSize = 28.0;
    float fontColor = 1.0;
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: font}];

    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    
    // set colors
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx,fontColor,fontColor,fontColor,1.0);
    
    // draw in context, you can use also drawInRect:withFont:
    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:@{NSFontAttributeName:font}];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)skipAction:(id)sender {
    if (self.isMaskLandscape) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(skipStepRequested)]) {
        [self.delegate performSelector:@selector(skipStepRequested)];
    }
}

- (IBAction)nextAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(nextStepRequested:)])
    {
        [self.nextButtonActivityIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
        [self.delegate performSelector:@selector(nextStepRequested:) withObject:self.presentingImage.image];
        [self.nextButtonActivityIndicator stopAnimating];
    }
}

-(void)activateEffects{
    
    if (self.isImageEffectsReady) {
        return;
    }
    
    self.isImageEffectsReady = YES;
    
    self.thumbnailOriginalImage = [self.originalImage scalingAndCroppingForSize:CGSizeMake(EFFECT_THUMB_SIZE, EFFECT_THUMB_SIZE)];
    
    if (![[HSImageEffectsManager sharedInstance] isAnyEffectInstanceActive]) {
        
        HSPhotolibEffectsInstance * photoEff=[[HSPhotolibEffectsInstance alloc] init];
        
        [[HSImageEffectsManager sharedInstance] setupEffects:[NSMutableArray arrayWithObject:photoEff] withDefaultEffect:0];
    }
    
    [self.thumbnailsArray removeAllObjects] ;
    
    if ([[HSImageEffectsManager sharedInstance]getNumberOfCurrentEffects]>0) {
        
        //add one for the none effect
        for (int i=0; i<[[HSImageEffectsManager sharedInstance]getNumberOfCurrentEffects] + 1;i++) {
            [self.thumbnailsArray addObject:[NSNull null]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)effectAtIndexSelected:(NSInteger)index{
    
    if (index==0) {
        //remove any effects
        self.afterEffectImage = self.originalImage;
        [self redrawPreviewImage];
        return;
    }
    
    if (self.isInMidleOfEffect) {
        return;
    }
    
    self.isInMidleOfEffect=YES;
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       UIImage * respo = [[HSImageEffectsManager sharedInstance] applyCurrentEffectOnImage:self.originalImage withEffectIndex:index - 1];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if (respo) {
                               self.afterEffectImage = respo;
                               [self redrawPreviewImage];
                           }
                           self.isInMidleOfEffect=NO;
                           [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                       });
                   });
}

#pragma mark - Effect Loading notification
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.isImageEffectsReady) {
        return  [[HSImageEffectsManager sharedInstance]getNumberOfCurrentEffects] + 1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    EffectCollectionCell* cl = (EffectCollectionCell*)cell;
    
    if (indexPath.row == 0) {
        NSString * title =  NSLocalizedString(@"none_effect_title", @"");
        [cl updateCellWithData:self.thumbnailOriginalImage andDelegate:self andIndex:indexPath.row title:title];
    }else{
        if (indexPath.row < [self.thumbnailsArray count]) {
            
            if ([[self.thumbnailsArray objectAtIndex:indexPath.row] isEqual:[NSNull null]]) {
                
                [cl updateCellWithData:[UIImage imageNamed:@"iph_pixlr_effect_frame_none.png"] andDelegate:self andIndex:indexPath.row title:@""];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
                    
                    UIImage * respo = [[HSImageEffectsManager sharedInstance] applyCurrentEffectOnImage:self.thumbnailOriginalImage
                                                                                        withEffectIndex:indexPath.row - 1];
                    if (respo) {
                        [self.thumbnailsArray insertObject:respo atIndex:indexPath.row];
                        NSString * title = [[HSImageEffectsManager sharedInstance] getNameOfEffectAtIndex:indexPath.row - 1];
                        [cl updateCellWithData:[self.thumbnailsArray objectAtIndex:indexPath.row] andDelegate:self andIndex:indexPath.row title:title];
                    }
                });
                
            }else{
                
                NSString * title = [[HSImageEffectsManager sharedInstance] getNameOfEffectAtIndex:indexPath.row - 1];
                [cl updateCellWithData:[self.thumbnailsArray objectAtIndex:indexPath.row] andDelegate:self andIndex:indexPath.row title:title];
            }
        }
        
        if (self.lastSelectedEffect) {
            cl.effectItem.frameImage.hidden=![self.lastSelectedEffect isEqual:indexPath];
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell =(UICollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self effectAtIndexSelected:indexPath.row];
    if (cell)
    {
        if ([self respondsToSelector:@selector(hideChooseAnEffectPopup)])
        {
            [self hideChooseAnEffectPopup];
        }
        
        EffectCollectionCell * cef = (EffectCollectionCell*)cell;
        cef.effectItem.frameImage.hidden = NO;
        self.lastSelectedEffect = indexPath;
    }
}

- (void)collectionView:(PSTCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =(UICollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell) {
        EffectCollectionCell* cef = (EffectCollectionCell*)cell;
        cef.effectItem.frameImage.hidden = YES;
    }
}

-(void)comeBackFromArController {
    if (self.backBlock) {
        self.backBlock();
    }
}

@end




