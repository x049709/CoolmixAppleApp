//
//  UserDetails.m
//  Tellem
//
//  Created by Ed Bayudan on 07/04/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "UserDetails.h"
#import "UIImage+ImageEffects.h"


@interface UserDetails ()

@end

@implementation UserDetails
@synthesize userDetailLabel, profileImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"USER PROFILE";
    
    PFUser *user=[PFUser currentUser];
    //NSLog(@"UserDetails viewDidLoad user: %@",user);
    NSString *accountType = [user valueForKey:@"Accounttype"];
    userDetailLabel.font = [UIFont fontWithName:kFontBold size:18.0];
    Label_UserName.font = [UIFont fontWithName:kFontBold size:15.0];
    if ([accountType  isEqual: @"FB"])
        Label_UserName.text=[[user valueForKey:@"displayName"] stringByAppendingString:@" via Facebook"];
    else if (([accountType  isEqual: @"Twitter"]))
        Label_UserName.text=[[user valueForKey:@"displayName"] stringByAppendingString:@" via Twitter"];
    else if (([accountType  isEqual: @"Instagram"]))
        Label_UserName.text=[[user valueForKey:@"displayName"] stringByAppendingString:@" via Instagram"];
    else
        Label_UserName.text=[user valueForKey:@"displayName"];
    
    PFFile *profileImage = [user valueForKey:@"profilePictureMedium"];
    
    [_ProfilePic setFile:profileImage];
    if (profileImage) {
        [profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [[UIImage imageWithData:data] applyLightEffect];
                self.profileImageView.layer.contents = (id)image.CGImage;
                //self.ProfilePic.backgroundColor= [UIColor colorWithPatternImage:[image applyExtraLightEffect]];
            }
        }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
