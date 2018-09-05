
#import <MapKit/MapKit.h>

@interface ESPeoductDetailAddressAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIColor *annotationShowColor;
@property (nonatomic, readwrite) NSTimeInterval pulseDuration;//1s
@property (nonatomic, readwrite) NSTimeInterval delayBetweenPulse;//1s

@end
