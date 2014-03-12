//
//  KeyChainDetailViewController.m
//  Key_chain
//
//  Created by Brandon Chen on 2/15/14.
//  Copyright (c) 2014 Brandon Chen. All rights reserved.
//

#import "KeyChainDetailViewController.h"
#import "Conn_params_ViewController.h"

@interface KeyChainDetailViewController ()

@end

@implementation KeyChainDetailViewController

@synthesize keychain;
@synthesize repeatingTimer;
@synthesize map;
@synthesize locationManager;
@synthesize actView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.repeatingTimer invalidate];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
	// Do any additional setup after loading the view.

    self.name_label.text = keychain.configProfile.name;//@"key";//keychain.peripheral.name;
    self.out_of_range_alert_from_ui.on = keychain.configProfile.out_of_range_alert;
    self.disconnection_alert_from_ui.on = keychain.configProfile.disconnection_alert;
    self.alert_threshold_from_ui.selectedSegmentIndex = keychain.configProfile.threshold;
    self.rssi_label.text = [keychain.peripheral.RSSI stringValue];
    self.status_label.text = [keychain connectionState];
    
    [self startRepeatingTimer];
    
 /*   if (!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    [locationManager startUpdatingLocation];*/
    
    map.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startRepeatingTimer{
    
    // Cancel a preexisting timer.
    [self.repeatingTimer invalidate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self selector:@selector(targetMethod:)
                                                    userInfo:[self userInfo] repeats:YES];
    self.repeatingTimer = timer;
}


- (NSDictionary *)userInfo {
    
    return @{ @"StartDate" : [NSDate date] };
}

- (void)targetMethod:(NSTimer*)theTimer {

    self.status_label.text = [keychain connectionState];
    self.rssi_label.text = [keychain.peripheral.RSSI stringValue];

}

- (void)invocationMethod:(NSDate *)date {
    //    NSLog(@"Invocation for timer started on %@", date);
}

-(IBAction) press_findme:(id)sender {
    
    if(keychain.findme_status == NO){
        
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.duration = .5;
        pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pulseAnimation.autoreverses = YES;
        pulseAnimation.repeatCount = FLT_MAX;
        [self.find_me_button.layer addAnimation:pulseAnimation forKey:@"find_me_flash"];
        [self.find_me_button setTitle:@"Stop" forState:UIControlStateNormal] ;
        
        [keychain find_key:1];
        keychain.findme_status = YES;
        
    }
    else {
        [self.find_me_button.layer removeAnimationForKey:@"find_me_flash"];
        [self.find_me_button setTitle:@"Find Me" forState:UIControlStateNormal] ;
        [keychain find_key:0];
        keychain.findme_status = NO;
    }
        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (section)
    {
        case 0:
            break;
        case 1:
            switch(row){
                case 3:
                {
                    actView = (UIActivityIndicatorView *)[cell viewWithTag:4];
                    [actView startAnimating];
                    self.keychain.delegate = self;
                    [self.keychain read_connectionParams];
                    break;
                }
                default:
                    break;
            }
            break;
    }
    
    

}

- (void) didReadConnParams {
    [actView stopAnimating];
    [self performSegueWithIdentifier:@"detailToConnParams" sender:self];
}

- (IBAction)out_of_rang_alert_switch:(id)sender {
    keychain.configProfile.out_of_range_alert = self.out_of_range_alert_from_ui.on;
}

- (IBAction)alert_threshold_change:(id)sender {
    keychain.configProfile.threshold = self.alert_threshold_from_ui.selectedSegmentIndex;
}

- (IBAction)disconnection_alert_switch:(id)sender {
    keychain.configProfile.disconnection_alert = self.disconnection_alert_from_ui.on;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    
    [map setRegion:[map regionThatFits:region] animated:YES];
    

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    NSLog(@"Location: %f %f\n",location.coordinate.latitude,location.coordinate.longitude);
    
    keychain.configProfile.location = location;

    
    [self.locationManager stopUpdatingLocation];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"detailToConnParams"]) {
        Conn_params_ViewController* controller = [segue destinationViewController];
        controller.keychain = keychain;
    }
}

@end
