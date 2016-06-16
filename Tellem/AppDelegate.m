 //
//  AppDelegate.m
//  Tellem
//
//  Created by Ed Bayudan on 13/03/14.
//  Copyright (c) 2014 Tellem, LLC All rights reserved.
//


#import "AppDelegate.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPWelcomeViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "PeopleViewController.h"
#import "PostViewController.h"
#import "ActivityViewController.h"
#import "HeatMapViewController.h"
#import "CirclesViewController.h"
#import "CirclesPageViewController.h"
#import "CirclesListViewController.h"
#import "HomeActivitiesViewController.h"
#import "HomeTimelineViewController.h"
#import "AVCamViewController.h"
#import "MagentoViewController.h"
#import "MixHomeViewController.h"
#import "PAPUtility.h"

//NSString *const BFTaskMultipleExceptionsException = @"BFMultipleExceptionsException";

@interface AppDelegate ()
{
    NSMutableData *_data;
    BOOL firstLaunch;
}

@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) HomeViewController *homeViewController;
@property (nonatomic, strong) PeopleViewController *networkViewController;
@property (nonatomic, strong) PostViewController *postViewController;
@property (nonatomic, strong) ActivityViewController *activityViewController;
@property (nonatomic, strong) HeatMapViewController *heatMapViewController;
@property (nonatomic, strong) CirclesPageViewController *circlesPageViewController;
@property (nonatomic, strong) CirclesListViewController *circlesListViewController;
@property (nonatomic, strong) AVCamViewController *postCameraViewController;
@property (nonatomic, strong) HomeTimelineViewController *homeTimelineViewController;
@property (nonatomic, strong) CirclesViewController *circlesViewController;
@property (nonatomic, strong) MagentoViewController *magentoViewController;
@property (nonatomic, strong) MixHomeViewController *mixHomeViewController;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;
@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;
@property NSDictionary *pushPayload;
@property BOOL shouldReauthorize;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;

@end

@implementation AppDelegate

@synthesize window;
@synthesize navController;
@synthesize tabBarController;
@synthesize networkStatus;

@synthesize homeViewController;
@synthesize welcomeViewController;
@synthesize networkViewController;
@synthesize activityViewController;
@synthesize heatMapViewController;
@synthesize circlesViewController;
@synthesize circlesPageViewController;
@synthesize circlesListViewController;
@synthesize postCameraViewController;
@synthesize homeTimelineViewController;
@synthesize magentoViewController;
@synthesize mixHomeViewController;
@synthesize hud,tabIndex,pushPayload;
@synthesize autoFollowTimer;

@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;
@synthesize shouldReauthorize;


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //MWLogDebug(@"\nAppDelegate didFinishLaunchingWithOptions: Started.");

    //Tellem in Digital Ocean
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"Utellem";
        configuration.clientKey = @"DummyClientKey";
        configuration.server = @"http://162.243.212.149:1337/parse";
    }]];
    
    [PFFacebookUtils initialize];
    
    // Track app opens.

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (application.applicationIconBadgeNumber != 0)
    {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
 
    // Register for push
    [self registerForPushNotifications:application];

    // Do not allow rotation
    self.allowRotation=NO;

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.welcomeViewController = (PAPWelcomeViewController *)[sb instantiateViewControllerWithIdentifier:@"PAPWelcomeViewController"];
    self.hudd=[[MBProgressHUD alloc]initWithWindow:self.window];
    return YES;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id) annotation {
//    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
//}

//TODO FOR V4
//- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
//    // If the session was opened successfully
//    if (!error && state == FBSessionStateOpen) {
//        //MWLogDebug(@"\nAppDelegate sessionStateChanged: Session opened.");
//        // Show the user the logged-in UI
//        //[self userLoggedIn];
//        return;
//    }
//
//    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
//        //MWLogDebug(@"\nAppDelegate sessionStateChanged: Session closed.");
//        // If the session is closed show the user the logged-out UI
//        //[self userLoggedOut];
//        [FBSession.activeSession closeAndClearTokenInformation];
//    }
//    
//    // Handle errors
//    if (error)
//    {
//        //MWLogDebug(@"\nAppDelegate sessionStateChanged: Oops. Error.");
//        NSString *alertText;
//        NSString *alertTitle;
//        // If the error requires people using an app to make an action outside of the app in order to recover
//        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
//            alertTitle = @"Something went wrong";
//            alertText = [FBErrorUtility userMessageForError:error];
//            //[self showMessage:alertText withTitle:alertTitle];
//        } else {
//            
//            // If the user cancelled login, do nothing
//            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
//                //MWLogDebug(@"\nAppDelegate sessionStateChanged: User cancelled login.");
//                // Handle session closures that happen outside of the app
//            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
//                alertTitle = @"Session Error";
//                alertText = @"Your current session is no longer valid. Please log in again.";
//                //[self showMessage:alertText withTitle:alertTitle];
//                //
//                // Here we will handle all other errors with a generic error message.
//                // We recommend you check our Handling Errors guide for more information
//                // https://developers.facebook.com/docs/ios/errors/
//            } else {
//                // Get more error information from the error
//                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
//                // Show the user an error message
//                alertTitle = @"Something went wrong";
//                alertText = [NSString stringWithFormat:@"Please retry. \n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
//                //[self showMessage:alertText withTitle:alertTitle];
//            }
//        }
//        // Clear this token
//        [FBSession.activeSession closeAndClearTokenInformation];
//        // Show the user the logged-out UI
//        // [self userLoggedOut];
//    }
//}

- (void)registerForPushNotifications:(UIApplication *)application {
    //MWLogDebug(@"\nAppDelegate registerForPushNotifications: Started.");

    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    //MWLogDebug(@"\nAppDelegate didRegisterForRemoteNotificationsWithDeviceToken application: %@", application);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [PFPush storeDeviceToken:deviceToken];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"Global"];
    [currentInstallation saveInBackground];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    MWLogDebug(@"\nAppDelegate didRegisterForRemoteNotificationsWithDeviceToken currentInstallation: %@", currentInstallation);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        //NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        //NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError error: %@", error);
    }
	if ([error code] != 3010) { // 3010 is for the iPhone Simulator
        //MWLogDebug(@"\nAppDelegate didFailToRegisterForRemoteNotificationsWithError: Application failed to register for push notifications: %@", error);
    } else {
        //Show some alert or otherwise handle the failure to register.
        //MWLogDebug(@"\nAppDelegate didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)remoteNotification {
    //[[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    //[PFPush handlePush:userInfo];
    //NSLog(@"didReceiveRemoteNotification remoteNotification: %@", remoteNotification);

    TellemGlobals *tM = [TellemGlobals globalsManager];
    //NSLog(@"tM.gCurrentTab:%lu",(unsigned long)tM.gCurrentTab);
    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }

    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:remoteNotification];
        [self handleRemoteNotificationWhileInactive:remoteNotification];
    } else
    {
        [self handleRemoteNotificationWhileActive:remoteNotification];
    }
}

- (void)alertAcceptInviteActionWithPayLoad: (NSDictionary *)payLoad
{
    self.tabIndex = 4;
    self.pushPayload = payLoad;
    [self presentTabBarController];    
}

- (void)alertViewCommentsActionWithPayLoad: (NSDictionary *)payLoad
{
    self.tabIndex = 0;
    self.pushPayload = payLoad;
    [self presentTabBarController];
}

- (void)alertAcceptAction: (NSDictionary *)payLoad
{
    //NSLog(@"Accept action");
}

- (void)alertDecideLaterActionWithPayLoad: (NSDictionary *)payLoad
{
    [self handleRemoteNotificationWhileInactive:payLoad];
}

- (void)alertIgnoreActionWithPayLoad: (NSDictionary *)payLoad
{
    //NSLog(@"Ignore action");
}

- (void)alertCancelActionWithPayLoad: (NSDictionary *)payLoad
{
    //NSLog(@"Cancel action");
}

- (void)alertPasswordActionWithPayLoad: (NSString *)msg
{
    [self presentLoginViewController];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)handleRemoteNotificationWhileInactive: (NSDictionary *)remoteNotification
{
    //NSLog(@"Accept RemoteNotificationWhileInactive");
    if (![PFUser currentUser]) {
        return;
    }

    NSString *msgType = [remoteNotification objectForKey:@"msgtype"];
    if (![msgType isEqualToString:kPAPPushInviteToCircle])
    {
        return;
    }
    
    PFUser *user = [PFUser currentUser];
    PFACL *userNotificationsACL = [PFACL ACLWithUser:user];
    [userNotificationsACL setPublicReadAccess:YES];
    [userNotificationsACL setWriteAccess:YES forUser:user];
    PFObject *userNotifications = [PFObject objectWithClassName:kPAPUserNotificationsClassKey];
    [userNotifications setObject:user forKey:kPAPUserNotificationsReceivingUserKey];
    [userNotifications setObject:remoteNotification forKey:kPAPUserNotificationsRemoteNotificationKey];
    userNotifications.ACL = userNotificationsACL;
    [userNotifications save];
}

- (void)handleRemoteNotificationWhileActive: (NSDictionary *)remoteNotification
{
    //NSLog(@"Accept RemoteNotificationWhileActive");
    NSArray *userInfo=[[NSArray alloc]init];
    userInfo = [remoteNotification objectForKey:@"aps"];
    NSString *msg = [userInfo valueForKey:@"alert"];
    NSString *msgType = [remoteNotification objectForKey:@"msgtype"];
    
    //UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept",@"Decide later",@"Ignore", nil];
    //[alert show];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tellem" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *viewCircleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"View circle", @"") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action)
        {
            [self alertAcceptInviteActionWithPayLoad:remoteNotification];
        }];
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Accept", @"") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action)
        {
            [self alertAcceptAction:remoteNotification];
        }];
    UIAlertAction *viewCommentsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Accept", @"") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action)
        {
            [self alertViewCommentsActionWithPayLoad:remoteNotification];
        }];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action)
        {
            [self alertIgnoreActionWithPayLoad:remoteNotification];
        }];
    UIAlertAction *decideAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Decide later", @"") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action)
        {
            [self alertDecideLaterActionWithPayLoad:remoteNotification];
        }];
    
    if ([msgType isEqualToString:kPAPPushCommentOnPost]) {
        //Test 'show asterisk on home tab' when notification exists
        //NSLog (@"self.tabIndex,%d", self.tabIndex);
        //NSLog (@"selectedIndex,%lu", (unsigned long)self.tabBarController.selectedIndex);
        self.tabBarController.hasNotifications = YES;
        [self.tabBarController customizeTabBar:self.tabBarController.selectedIndex];
        return;
        //[alertController addAction:viewCommentsAction];
        //[alertController addAction:ignoreAction];
    } else
        if ([msgType isEqualToString:kPAPPushInviteToCircle]) {
            [alertController addAction:viewCircleAction];
            [alertController addAction:dismissAction];
        } else
            if ([msgType isEqualToString:kPAPPushTemporaryPassword]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                [alertController addAction:acceptAction];
                [alertController addAction:dismissAction];
            }
    
    //[self.window setRootViewController:alertController];
    //[self.window.rootViewController presentViewController:alertController animated:YES completion:NULL];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]  presentViewController:alertController animated:YES completion:NULL];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //TODO FOR V4
    //[[FBSession activeSession] handleDidBecomeActive];
    
    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
}

- (void) requestPublishPermissions
{
//TODO FOR V4.0
//    //NSLog(@"PostViewController postOnFaceBook commentText: %@", commentText);
//    ApplicationDelegate.session=[FBSession activeSession];
//    
//    [FBSession setActiveSession:[FBSession activeSession]];
//    
//    NSArray *permissionsNeeded = @[@"publish_actions"];
//    // Request the permissions the user currently has
//    
//    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error)
//        {
//            NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
//            NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
//            
//            // Check if all the permissions we need are present in the user's current permissions
//            // If they are not present add them to the permissions to be requested
//            for (NSString *permission in permissionsNeeded)
//            {
//                if (![currentPermissions objectForKey:permission])
//                {
//                    [requestPermissions addObject:permission];
//                }
//            }
//            // If we have permissions to request
//            if ([requestPermissions count] > 0)
//            {
//                // Ask for the missing permissions
//                [FBSession.activeSession requestNewPublishPermissions:requestPermissions defaultAudience:FBSessionDefaultAudienceFriends
//                                                    completionHandler:^(FBSession *session, NSError *error)
//                 {
//                     if (!error) {
//                         // Permission granted, we can request the user information[self makeRequestToPostObject];
//                     }
//                     else
//                     {
//                         // An error occurred, we need to handle the error
//                         // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//                         NSLog (@"AppDelegate: Error posting picture  to Facebook,%@", error);
//                     }
//                 }];
//            }
//            else
//            {
//                // Permissions are present We can request the user information
//            }
//            
//        } else
//        {
//            // An error occurred, we need to handle the error
//            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//            NSLog (@"AppDelegate: Error posting picture to Facebook,%@", error);
//        }
//    }];
}

#pragma mark - UITabBarControllerDelegate
/*
- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController
{
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
}*/


#pragma mark - PFLoginViewController

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        //self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
        [self.hud show:YES];
        self.hud.labelText = NSLocalizedString(@"Loading...", nil);
        self.hud.dimBackground = YES;
    }
    
    //TODO FOR V4
    //[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    //    if (!error) {
    //        [self facebookRequestDidLoad:result];
    //    }
    //    else {
    //        [self facebookRequestDidFailWithError:error];
    //    }
    //}];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}
#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Coolmix" bundle:nil];
    LoginViewController *loginViewController = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.window.rootViewController presentViewController:loginViewController animated:YES completion:Nil];
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:NO];
}

- (void)presentTabBarController {
    
    PFUser *user = [PFUser currentUser];
    [PFInstallation currentInstallation][@"userId"] = user[kPAPUserUserNameKey];
    [PFInstallation currentInstallation][@"accountType"] = user[kPAPUserAccountType];
    [PFInstallation currentInstallation].channels = @[@"Global"];
    [[PFInstallation currentInstallation] saveInBackground];
    [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
    [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ViewFriends"];
    [user saveInBackground];
    
    self.navController=(UINavigationController *)self.window.rootViewController;
    self.tabBarController = [[MokriyaUITabBarController alloc] init];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coolmix" bundle:nil];
    
    self.mixHomeViewController=(MixHomeViewController *)[sb instantiateViewControllerWithIdentifier:@"MixHomeViewController"];
    self.networkViewController=(PeopleViewController *)[sb instantiateViewControllerWithIdentifier:@"PeopleViewController"];
    self.postCameraViewController=(AVCamViewController *)[sb instantiateViewControllerWithIdentifier:@"AVCamViewController"];
    self.magentoViewController=(MagentoViewController *) [sb instantiateViewControllerWithIdentifier:@"MagentoViewController"];
    self.circlesListViewController=(CirclesListViewController *)[sb instantiateViewControllerWithIdentifier:@"CirclesListViewController"];

    UINavigationController *mixHomeViewNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mixHomeViewController];
    UINavigationController *networkNavigationController=[[UINavigationController alloc]initWithRootViewController:self.networkViewController];
    UINavigationController *postNavigationController = [[UINavigationController alloc] initWithRootViewController:self.postCameraViewController];
    UINavigationController *magentoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.magentoViewController];
    UINavigationController *circlesListNavigationController = [[UINavigationController alloc] initWithRootViewController:self.circlesListViewController];

    self.tabBarController.allViewControllers = [NSMutableArray arrayWithObjects:
        mixHomeViewNavigationController,
        networkNavigationController,
        postNavigationController,
        magentoNavigationController,
        circlesListNavigationController,
        nil];
    
    self.tabBarController.viewControllers = tabBarController.allViewControllers;
    [[self.tabBarController tabBar] setBackgroundImage:[UIImage imageNamed:@"tabBarBackground.png"]];
    [[self.tabBarController tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"backgroundTabBarItemSelected.png"]];
    
    self.tabBarController.tabBarImagesArray = [NSMutableArray arrayWithObjects:
                                               [UIImage imageNamed:@"home-normal.png"],
                                               [UIImage imageNamed:@"network-normal.png"],
                                               [UIImage imageNamed:@"post-normal.png"],
                                               [UIImage imageNamed:@"map-normal.png"],
                                               [UIImage imageNamed:@"activities-normal.png"],
                                               nil];
    
    self.tabBarController.tabBarSelectedStateImagesArray = [NSMutableArray arrayWithObjects:
                                                            [UIImage imageNamed:@"home-hover.png"],
                                                            [UIImage imageNamed:@"network-hover.png"],
                                                            [UIImage imageNamed:@"post-hover.png"],
                                                            [UIImage imageNamed:@"map-hover.png"],
                                                            [UIImage imageNamed:@"activities-hover.png"],
                                                           nil];
    self.tabBarController.tabBarTitlesArray = [NSMutableArray arrayWithObjects:
                                               @"Home",
                                               @"Network",
                                               @"Post",
                                               @"Maps",
                                               @"Circles",
                                               nil];
    if (self.pushPayload) {
        NSString *msgType = [self.pushPayload objectForKey:@"msgtype"];
        if ([msgType isEqualToString:kPAPPushInviteToCircle])
        {
            self.circlesListViewController.pushPayload = self.pushPayload;
        }
        if ([msgType isEqualToString:kPAPPushCommentOnPost])
        {
            self.homeTimelineViewController.pushPayload = self.pushPayload;
        }
        self.pushPayload = Nil;
    }
    
    if (self.tabIndex > 0 && self.tabIndex < 5) {
        [self.tabBarController customizeTabBar:self.tabIndex];
    } else {
        [self.tabBarController customizeTabBar];
    }
    
    //[(UINavigationController *)self.window.rootViewController setViewControllers:@[self.welcomeViewController, self.tabBarController ] animated:YES];
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeSound];
    self.navController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navController pushViewController:self.tabBarController animated:NO];
    
}

- (void)logOut {
    //MWLogDebug(@"\nAppDelegate logOut: Logging out.");
    // Clear out Instagram session
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"InstaGramToken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ShareInstaGramToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* instagramCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://instagram.com/"]];
    for (NSHTTPCookie* cookie in instagramCookies)
        [cookies deleteCookie:cookie];
    //NSLog(@"Nothing %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"ShareInstaGramToken"]);

    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
   self.homeViewController = nil;
    
    // Clear out Facebook session
    //TODO FOR V4
    //[[FBSession activeSession] closeAndClearTokenInformation];
    //[[FBSession activeSession] close];
    //[FBSession setActiveSession:nil];
    //NSLog(@"The active facebook session: %@", [[FBSession activeSession] description]);
    
    // Clear out Twitter session
    [[FHSTwitterEngine sharedEngine] logOut];
    
    // Clear out FB user id in currentInstallation
    [PFInstallation currentInstallation][@"userId"] = @"";
    [[PFInstallation currentInstallation] saveInBackground];

    // Present login controllers
    [self.navController popToRootViewControllerAnimated:YES];
    [self presentLoginViewController];
}


#pragma mark - ()

- (void)setupAppearance {
    [[UILabel appearance] setFont:[UIFont fontWithName:kFontThin size:12.0]];
    [UIButton appearance].titleLabel.font = [UIFont fontWithName:kFontThin size:12.0];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor whiteColor],
                                                           UITextAttributeTextShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f],
                                                           UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)]
                                                           }];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.498f green:0.388f blue:0.329f alpha:1.0f]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"backgroundNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor whiteColor],
                                                           } forState:UIControlStateNormal];
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:19.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];

}

- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:ReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostName:@"api.parse.com"];
    [self.hostReach startNotifier];
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    return NO;
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    networkStatus = [curReach currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        MWLogDebug(@"\nAppDelegate reachabilityChanged: Network not reachable.");
    }
}
- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {

}

- (NSString *) findUniqueSavePath {
	NSString *path;
    NSString *imgName;
	do {
		// Iterate until a name does not match an existing file
	    path = [NSString stringWithFormat:@"IMAGE_%f",[[NSDate date] timeIntervalSince1970]];
        path = [NSString stringWithFormat:@"%@.PNG",[path stringByReplacingOccurrencesOfString:@"." withString:@""]];
        imgName = [NSString stringWithFormat:@"%@",[path lastPathComponent]];
	}
    while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
	return imgName;
}

-(void)ApplyOnImageView:(UIImageView *)img_vw; {
    img_vw.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"user.png"]];
    img_vw.contentMode=UIViewContentModeRedraw;
    img_vw.layer.masksToBounds=YES;
    img_vw.layer.cornerRadius=57;
}

-(void)ApplySecondChangeOnIMageview:(UIImageView *)imgvw delegate:(UIViewController *)delegate selector:(SEL)methodname {
    UITapGestureRecognizer *gest=[[UITapGestureRecognizer alloc]initWithTarget:delegate action:methodname];
    gest.numberOfTapsRequired = 1;
    gest.numberOfTouchesRequired = 1;
    [imgvw addGestureRecognizer:gest];
    [imgvw setUserInteractionEnabled:YES];
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.allowRotation)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Depending on the architecture of your app, grab the handler to your controller that contains the webView
    [self.magentoViewController.view setNeedsDisplay];
}

@end
