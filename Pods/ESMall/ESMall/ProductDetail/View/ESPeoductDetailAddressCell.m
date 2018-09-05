
#import "ESPeoductDetailAddressCell.h"
#import "ESProductStoreModel.h"
#import <MapKit/MapKit.h>
#import "ESPeoductDetailAddressAnnotationView.h"

@interface ESPeoductDetailAddressCell ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ESPeoductDetailAddressCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code

}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductAddressAtIndexPath:)])
    {
        ESProductStoreModel *model = [(id)self.cellDelegate getProductAddressAtIndexPath:indexPath];
        if (model
            && [model isKindOfClass:[ESProductStoreModel class]]
            && model.storeAddress
            && [model.storeAddress isKindOfClass:[NSString class]])
        {
            CGFloat latitude = [model.latitude doubleValue];
            CGFloat longitude = [model.longitude doubleValue];
            MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
            [annotation0 setCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
            [self.mapView addAnnotation:annotation0];
            [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude,longitude), 3000, 3000) animated:YES];
        }
    }
}

#pragma mark - MapView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if(![annotation isKindOfClass:[MKUserLocation class]])
    {
        static NSString *identifier = @"storeID";
        ESPeoductDetailAddressAnnotationView *pulsingView = (ESPeoductDetailAddressAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(pulsingView == nil)
        {
            pulsingView = [[ESPeoductDetailAddressAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationShowColor = ColorFromRGA(0x72bada, 1);
            pulsingView.canShowCallout = YES;
        }
        
        return pulsingView;
    }
    
    return nil;
}

- (IBAction)buttonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(productDetailMapButtonDidTapped)])
    {
        [(id)self.cellDelegate productDetailMapButtonDidTapped];
    }
}

@end
