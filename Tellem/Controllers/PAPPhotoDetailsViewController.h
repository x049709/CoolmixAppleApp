//
//  PAPPhotoDetailViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPBaseTextCell.h"
#import <CoreLocation/CoreLocation.h>
@interface PAPPhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, PAPPhotoDetailsHeaderViewDelegate, PAPBaseTextCellDelegate,CLLocationManagerDelegate>{
CLLocationManager *locationManager;
}

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) IBOutlet UIView *texturedBackgroundView;

- (id)initWithPhoto:(PFObject*)aPhoto;



@end
