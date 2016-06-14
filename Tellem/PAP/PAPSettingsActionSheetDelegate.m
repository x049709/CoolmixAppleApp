//
//  PAPSettingsActionSheetDelegate.m
//  Tellem
//
//  Created by Ed Bayudan on 17/12/2014 .9/12.
//

#import "PAPSettingsActionSheetDelegate.h"
#import "AppDelegate.h"
#import "SharingView.h"
#import "PAPFindFriendsViewController.h"
#import "UserProfileController.h"
#import "PAPAccountViewController.h"

// ActionSheet button indexes
typedef enum
{
	kPAPSettingsProfile = 0,
    kPAPSettingsSharing,
	kPAPSettingsLogout,
    kPAPSettingsNumberOfButtons
} kPAPSettingsActionSheetButtons;
 
@implementation PAPSettingsActionSheetDelegate

@synthesize navController;

#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        navController = navigationController;
    }

    return self;
}

- (id)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!self.navController)
    {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kPAPSettingsActionSheetButtons)buttonIndex)
    {
        case kPAPSettingsProfile:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UserProfileController *userDetails = (UserProfileController *)[storyboard instantiateViewControllerWithIdentifier:@"UserProfileController"];
            userDetails.userProfile = [[User alloc] initWithPFUser:[PFUser currentUser]];
            navController.navigationBar.tintColor=[UIColor whiteColor];
            [navController pushViewController:userDetails animated:YES];
            break;
        }
            
            case kPAPSettingsSharing:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SharingView *sharingView = (SharingView *)[storyboard instantiateViewControllerWithIdentifier:@"SharingViewController"];
            navController.navigationBar.tintColor=[UIColor whiteColor];
            [navController pushViewController:sharingView animated:YES];
            break;
        }
        case kPAPSettingsLogout:
        {
            // Log out user and present the login view controller
            Defaults=[NSUserDefaults standardUserDefaults];
            str_Accesstoken=nil;
            [Defaults setObject:nil forKey:@"InstaGramToken"];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            
            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray* instagramCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://instagram.com/"]];
            for (NSHTTPCookie* cookie in instagramCookies)
               [cookies deleteCookie:cookie];
//TODO FOR V4
//            [[FBSession activeSession] closeAndClearTokenInformation];
//            NSArray* fbCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
//            for (NSHTTPCookie* cookie in fbCookies)
//                [cookies deleteCookie:cookie];
        }
            break;
        default:
            break;
    }
}

@end
