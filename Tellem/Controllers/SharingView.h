//
//  SharingView.h
//  Tellem
//
//  Created by Ed Bayudan on 05/04/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSTwitterEngine.h"
#import "UIImage+ImageEffects.h"

@interface SharingView : UIViewController<UIWebViewDelegate,FHSTwitterEngineAccessTokenDelegate>
{
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
}
@property (strong, nonatomic) IBOutlet UILabel *shareLabel;
@property (strong, nonatomic) IBOutlet UILabel *viewLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *settingsScrollView;
@property (strong, nonatomic) IBOutlet UISwitch *user_Facebook_Switch;
@property (strong, nonatomic) IBOutlet UISwitch *user_Twitter_Switch;
@property (strong, nonatomic) IBOutlet UISwitch *user_Instagram_Switch;
@property (strong, nonatomic) UISwitch *user_Contacts_Switch;
@property (strong, nonatomic) IBOutlet UILabel *viewUser_Facebook_Label;
@property (strong, nonatomic) IBOutlet UISwitch *viewUser_Facebook_Switch;
@property (strong, nonatomic) IBOutlet UILabel *viewUser_Twitter_Label;
@property (strong, nonatomic) IBOutlet UISwitch *viewUser_Twitter_Switch;
@property (strong, nonatomic) IBOutlet UILabel *viewUser_Instagram_Label;
@property (strong, nonatomic) IBOutlet UISwitch *viewUser_Instagram_Switch;
@property (strong, nonatomic) UISwitch *viewUser_Contacts_Switch;
@property (strong, nonatomic) IBOutlet UILabel *recTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *recTimeInSecs;
@property (strong, nonatomic) IBOutlet UILabel *sliderMinLabel;
@property (strong, nonatomic) IBOutlet UILabel *sliderMaxLabel;
@property (strong, nonatomic) IBOutlet UIButton *linkEULA;


- (IBAction)Twitter_BtnOn:(id)sender;
- (IBAction)Facebook_BtnOn:(id)sender;
- (IBAction)Instagram_BtnOn:(id)sender;
- (IBAction)viewTwitter_BtnOn:(id)sender;
- (IBAction)viewFacebook_BtnOn:(id)sender;
- (IBAction)viewInstagram_BtnOn:(id)sender;
- (IBAction)recTimeChanged:(id)sender;
- (IBAction)openEULA:(id)sender;



@end
