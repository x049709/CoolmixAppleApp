//
//  HeatMapViewController.m
//  HeatMapExample
//
//  Created by Ryan Olson on 12-03-04.
//  Copyright (c) 2012 Ryan Olson. 
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "HeatMapViewController.h"
#import "parseCSV.h"
#import "PAPSettingsButtonItem.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "TellemUtility.h"
#import "SelectCirclesViewController.h"

enum segmentedControlIndicies {
    kSegmentStandard = 0,
    kSegmentSatellite = 1,
    kSegmentHybrid = 2,
    kSegmentTerrain = 3
};

@interface HeatMapViewController()
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property HeatMap *heatMap;
@property CLLocationManager *locationManager;


- (NSDictionary *)heatMapData;

@end

@implementation HeatMapViewController
@synthesize mapView,circleLabel,sortedCircles,pageCircle,selectedCircle,heatMap,mapStyleSegmentedControl,locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"MAPS";
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    self.mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontNormal size:12.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    self.selectedCircle = [[Circle alloc] initWithImage:[UIImage imageNamed:@"lock.png"]  andLabelFrame:CGRectMake(2, 0, self.view.frame.size.width, 40)];
    self.selectedCircle.circleType = kPAPCircleIsNewFromPostView;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCircle:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.selectedCircle.circleLabel addGestureRecognizer:tapGestureRecognizer];
    [self.view addSubview:self.selectedCircle.circleLabel];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    tM.gCurrentTab = 3;
    PFUser *user = [PFUser currentUser];
    self.sortedCircles = [NSArray array];
    self.sortedCircles = [TellemUtility getAllCirclesOfUser:user];
    if (self.sortedCircles.count ==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"You have no circles to map" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self setupCircleLabel];
    [self.view addSubview:self.selectedCircle.circleLabel];
    self.selectedCircle.circleLabel.layer.borderWidth = 0.5;
    self.selectedCircle.circleLabel.layer.borderColor = [UIColor grayColor].CGColor;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.view addSubview:mapView];
    NSDictionary *mapPoints = [self getHeatMapDataForUser];
    if (mapPoints.count >0) {
        self.heatMap = [[HeatMap alloc] initWithData:mapPoints];
        [self.mapView addOverlay:self.heatMap];
        //[self.mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        self.mapView.hidden = NO;
    }
    else
    {
        self.mapView.hidden = YES;
        self.heatMap = [[HeatMap alloc]init];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"The selected circle has no activities. Please choose another." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;

    }
    
    //[self.mapView setVisibleMapRect:[hm boundingMapRect] animated:YES];

}

- (void)setupCircleLabel
{
    if ([self.selectedCircle.circleType isEqual:kPAPCircleIsNewFromPostView])
    {
            //Use first found circle of user
            self.pageCircle = [self.sortedCircles objectAtIndex:0];
            self.selectedCircle.circleType = kPAPCircleIsNotNewFromPostView;
            [self.selectedCircle setNewCircleName:[self.pageCircle valueForKey:kPAPCircleNameKey]];
            PFFile *profilePhoto = [PFFile alloc];
            profilePhoto = [self.pageCircle objectForKey:kPAPCircleProfilePicture];
            NSData *profilePhotoData = [profilePhoto getData];
            UIImage * profileImage = [[UIImage alloc] init];
            profileImage = [UIImage imageWithData:profilePhotoData];
            [self.selectedCircle setNewCircleImage:profileImage];
    }
    else
    {
        //Circle came from SelectCirclesView
    }
    
}

- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile",
                                  @"Settings",@"Log out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)changeCircle: (PFUser*)pfUser {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectCirclesViewController *selectCirclesView = (SelectCirclesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SelectCirclesViewController"];
    selectCirclesView.selectedUser =  pfUser;
    selectCirclesView.selectedCircleFromSender = self.selectedCircle;
    selectCirclesView.delegate=self;
    selectCirclesView.sortedCircles = self.sortedCircles;
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:selectCirclesView animated:YES];
}

-(void)receiveCirclesArrayData:(NSArray *)arrayData;
{
    self.selectedCircle = [arrayData objectAtIndex:0];
    self.pageCircle = [arrayData objectAtIndex:1];
    HeatMap *hm = [[HeatMap alloc] initWithData:[self getHeatMapDataForUser]];
    [self.mapView addOverlay:hm];
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case kSegmentStandard:
            self.mapView.mapType = MKMapTypeStandard;
            break;
            
        case kSegmentSatellite:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        
        case kSegmentHybrid:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
            
        case kSegmentTerrain:
            self.mapView.mapType = 3;
            break;
    }
}

- (NSDictionary *)heatMapDataWithBlock
{
    //Not being used right now
    NSUInteger limit = 1000;
    __block NSUInteger skip = 0;
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query setLimit: limit];
    [query setSkip: skip];
    //[query selectKeys:@[@"latitude", @"longitude"]];
    //NSArray *allActivityPoints = [query findObjects];
    __block NSArray *allActivityPoints = [[NSArray alloc] init];
    __block NSMutableDictionary *toRet;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if (objects) {
             allActivityPoints=[objects valueForKey:@"moodtypes"];
             if (allActivityPoints.count == limit) {
                 // There might be more objects in the table. Update the skip value and execute the query again.
                 skip += limit;
             }
             
             int pointCount = 0;
             for (int i=0; i<allActivityPoints.count; i++)
             {
                 NSString *longitude = [allActivityPoints[i] objectForKey:@"longitude"];
                 NSString *latitude = [allActivityPoints[i] objectForKey:@"latitude"];
                 if ((longitude) && (latitude)) {
                     pointCount++;
                 }
             }
             
             toRet = [[NSMutableDictionary alloc] initWithCapacity:pointCount];
             for (int i=0; i<allActivityPoints.count; i++)
             {
                 NSString *longitude = [allActivityPoints[i] objectForKey:@"longitude"];
                 NSString *latitude = [allActivityPoints[i] objectForKey:@"latitude"];
                 if ((longitude) && (latitude)) {
                     //NSLog(@"longitude and latitude: %f %f", [longitude doubleValue], [latitude doubleValue]);
                     MKMapPoint point = MKMapPointForCoordinate(
                                                                CLLocationCoordinate2DMake([latitude doubleValue],
                                                                                           [longitude doubleValue]));
                     NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
                     [toRet setObject:[NSNumber numberWithInt:1] forKey:pointValue];
                 }
             }
         } else if (allActivityPoints.count == 0){
             // Log details of the failure
             //NSLog(@"HeatMapViewController heatMapData error: no data retrieved");
         }
     }];
    return toRet;
}


- (NSDictionary *)heatMapData
{
    
    NSUInteger limit = 1000;
    NSUInteger skip = 0;
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query setLimit: limit];
    [query setSkip: skip];
    //[query selectKeys:@[@"latitude", @"longitude"]];
    NSArray *allActivityPoints = [query findObjects];
    
    if (allActivityPoints.count == limit) {
        // There might be more objects in the table. Update the skip value and execute the query again.
        skip += limit;
    } else if (allActivityPoints.count == 0){
        // Log details of the failure
        //NSLog(@"HeatMapViewController heatMapData error: no data retrieved");
    }

    int pointCount = 0;
    for (int i=0; i<allActivityPoints.count; i++)
    {
        NSString *longitude = [allActivityPoints[i] objectForKey:@"longitude"];
        NSString *latitude = [allActivityPoints[i] objectForKey:@"latitude"];
        if (longitude && latitude) {
            pointCount++;
        }
    }
    
    NSMutableDictionary *toRet = [[NSMutableDictionary alloc] initWithCapacity:pointCount];
    for (int i=0; i<allActivityPoints.count; i++)
    {
        NSString *longitude = [allActivityPoints[i] objectForKey:@"longitude"];
        NSString *latitude = [allActivityPoints[i] objectForKey:@"latitude"];
        if (longitude && latitude) {
            //NSLog(@"longitude and latitude: %f %f", [longitude doubleValue], [latitude doubleValue]);
            MKMapPoint point = MKMapPointForCoordinate(
                                                       CLLocationCoordinate2DMake([latitude doubleValue],
                                                                                  [longitude doubleValue]));
            NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
            [toRet setObject:[NSNumber numberWithInt:1] forKey:pointValue];
        }
    }
    
    
    return toRet;
}

- (NSDictionary *)getHeatMapDataForUser
{
    //self.selectedCircle = [arrayData objectAtIndex:0];
    NSArray *circleActivities = [NSArray array];
    NSString *circleType = self.selectedCircle.circleType;
    if ([circleType isEqualToString:kPAPCircleSelectedIsAllCircles]) {
        circleActivities = [TellemUtility getAllActivitiesOfUserLightUsingSubquery:[PFUser currentUser]];
    }
    else
    {
        circleActivities = [TellemUtility getAllActivitiesOfCircleLight:self.pageCircle];
    }
    
    int pointCount = 0;
    for (int i=0; i<circleActivities.count; i++)
    {
        NSString *longitude = [circleActivities[i] objectForKey:@"longitude"];
        NSString *latitude = [circleActivities[i] objectForKey:@"latitude"];
        if (longitude && latitude) {
            pointCount++;
        }
    }
    
    NSMutableDictionary *toRet = [[NSMutableDictionary alloc] initWithCapacity:pointCount];
    for (int i=0; i<circleActivities.count; i++)
    {
        NSString *longitude = [circleActivities[i] objectForKey:@"longitude"];
        NSString *latitude = [circleActivities[i] objectForKey:@"latitude"];
        //NSString *circle = [[circleActivities[i] objectForKey:kPAPActivityCircleKey] objectId];
        if (longitude && latitude) {
            //NSLog(@"longitude and latitude: %f %f", [longitude doubleValue], [latitude doubleValue]);
            MKMapPoint point = MKMapPointForCoordinate(CLLocationCoordinate2DMake([latitude doubleValue],[longitude doubleValue]));
            NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
            [toRet setObject:[NSNumber numberWithInt:1] forKey:pointValue];
            //NSLog (@"long: %@, lat: %@, circle: %@", longitude,latitude,circle);
        }
    }
    //NSLog(@"HeatMapViewController %@ circleActivities count: %lu",self.selectedCircle.circleType, (unsigned long)circleActivities.count);
    //NSLog(@"HeatMapViewController toRet count: %lu", (unsigned long)toRet.count);
    
    return toRet;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setMapView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [[HeatMapView alloc] initWithOverlay:overlay];
}

@end
