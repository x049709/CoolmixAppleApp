//
//  AppDelegate.h
//  Tellem
//
//  Created by Ed Bayudan on 13/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "MokriyaUITabBarController.h"
#import "MBProgressHUD.h"
#import "PAPUtility.h"



#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

/* These variables are unused
extern NSString *const kPAPActivityClassKey;
extern NSString *const kPAPActivityFromUserKey;
extern NSString *const kPAPActivityToUserKey;
extern NSString *const kPAPActivityTypeKey;
*/

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) MokriyaUITabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, readonly) int networkStatus;
@property (strong, nonatomic) FBSession *session;
@property(strong,nonatomic)MBProgressHUD *hudd;
@property int tabIndex;
@property () BOOL allowRotation;


- (BOOL)isParseReachable;
- (void)presentLoginViewController;
- (void)presentLoginViewControllerAnimated:(BOOL)animated;
- (void)presentTabBarController;
- (void)logOut;
- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;
- (NSString *) findUniqueSavePath;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;
- (void)ApplyOnImageView:(UIImageView *)img_vw;

@end
