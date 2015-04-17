//
//  LoginViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 24/03/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MokriyaUITabBarController.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "OAuthConsumer.h"
#import "FHSTwitterEngine.h"
#import "AppDelegate.h"
#import "TellemLoginView.h"
#import "TellemForgotPasswordView.h"
#import "PAPUtility.h"
#import "TellemGlobals.h"

@interface LoginViewController : UIViewController<UIWebViewDelegate,PFLogInViewControllerDelegate,FHSTwitterEngineAccessTokenDelegate, UIScrollViewDelegate>
{
    UIWebView *webView;  //Btn_Instagram
    UIScrollView *scrollView;
    UIActivityIndicatorView *activityIndicator;//Btn_Instagram
    NSMutableArray *instagramUserDetails;//webView shouldStartLoadWithRequest
    NSString *instagramId;//webView shouldStartLoadWithRequest
    NSString *instagramDisplayName;//webView shouldStartLoadWithRequest
    NSMutableArray *instagramImageArray;
    NSMutableArray *instagramFriendsArray;
    NSMutableArray *followedByInstagram;
    NSMutableArray *twitterPictureArray;
    NSString *twitterToken;
    BOOL firstLaunch;
    OAConsumer* consumer;
    OAToken* requestToken;
    OAToken* accessToken;
    NSString *stringInstagram;
    NSString *stringTwitter;
    NSString *oauth_token;
    NSString *oauth_token_secret;
    NSString *user_id;
    NSString *screen_name;
}
@property (nonatomic, retain) NSString *oauth_token;
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *screen_name;
@property (nonatomic, retain) NSString *stringInstagram;
@property (nonatomic,strong) OAToken* accessToken;
@property (nonatomic, retain) NSString *isLogin;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) UIImageView *textfielImg;
@property (weak, nonatomic) UILabel *titleLbl;
@property (strong, nonatomic) UIImageView *titlImg;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSTimer *autoFollowTimer;
@property (nonatomic, strong) MokriyaUITabBarController *tabBarController;
@property (nonatomic, strong) TellemLoginView *tellemLoginView;
@property (nonatomic, strong) TellemForgotPasswordView *resetPasswordView;
@property (strong, nonatomic) IBOutlet UIButton *fbSigninButton;
@property (strong, nonatomic) IBOutlet UIButton *twSigninButton;
@property (strong, nonatomic) IBOutlet UIButton *instSigninButton;
@property (strong, nonatomic) IBOutlet UIButton *tellemSigninButton;


-(IBAction)fbSigninTouched:(id)sender;
-(IBAction)twSigninTouched:(id)sender;
-(IBAction)instButtonTouched:(id)sender;
-(IBAction)tellemSigninTouched:(id)sender;
-(BOOL)isEmailValid:(NSString *)checkString;
-(BOOL)isPasswordValid:(NSString *)checkString;



@end
