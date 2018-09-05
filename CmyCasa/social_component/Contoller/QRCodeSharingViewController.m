//
//  QRCodeSharingViewController.m
//  Homestyler
//
//  Created by lvwei on 19/04/2017.
//
//

#import "QRCodeSharingViewController.h"

@interface QRCodeSharingViewController ()

@property (nonatomic, weak) IBOutlet UIView *bkgdView;
@property (nonatomic, weak) IBOutlet UIImageView *qrImage;
@property (nonatomic, weak) IBOutlet UILabel *qrDesc;

@property (nonatomic, strong) NSString * url;

@end

@implementation QRCodeSharingViewController

-(id)initWithString:(NSString*)url
{
    self = [self initWithNibName:@"QRCodeSharingViewController" bundle:[NSBundle mainBundle]];
    
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.qrImage.image = [self createQRCode:self.url];
    self.qrDesc.text = NSLocalizedString(@"qrcode_sharing_lable_msg", @"");
    
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.bkgdView addGestureRecognizer:singleRecognizer];
}

-(void)singleTap:(UITapGestureRecognizer*)recognizer
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)createQRCode:(NSString *)stringURL {
    
    //1.实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //2.恢复滤镜的默认属性
    [filter setDefaults];
    
    ///Error correction level L 7%, M 15%, Q 25%, H 30%
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    //3.将字符串转化为NSData
    NSData *data = [stringURL dataUsingEncoding:NSUTF8StringEncoding];
    
    //4.通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    //5.获得滤镜输出的图像
    CIImage *outputImg = [filter outputImage];
    
    //6.将CIImage转换为UIImage 并放大显示
    return [self createUIImageFormCIImage:outputImg withSize:240];
}

- (UIImage *)createUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


@end
