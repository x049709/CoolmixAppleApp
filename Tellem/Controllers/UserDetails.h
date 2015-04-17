//
//  UserDetails.h
//  Tellem
//
//  Created by Ed Bayudan on 07/04/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPImageView.h"

@interface UserDetails : UIViewController
{
    IBOutlet UILabel *Label_UserName;
}
@property (weak, nonatomic) IBOutlet PAPImageView *ProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *userDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;


@end
