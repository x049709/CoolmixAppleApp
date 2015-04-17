//
//  HomePhotoDetailsViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 5/15/12.
//  Copyright (c) 2013 Tellem. All rights reserved.
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPBaseTextCell.h"
#import <CoreLocation/CoreLocation.h>
#import "TellemUtility.h"
#import "HomeActivitiesViewController.h"
#import "ZoomViewController.h"

@interface HomePhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, PAPPhotoDetailsHeaderViewDelegate, PAPBaseTextCellDelegate,CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) IBOutlet UIView *texturedBackgroundView;
@property PFObject *pageCircle;
@property NSUInteger pageIndex;
@property NSUInteger photoIndex;
@property NSDictionary *pushPayload;
@property (retain, nonatomic) NSString *objectID;
@property (nonatomic) NSArray *sortedCircleActivities;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end
