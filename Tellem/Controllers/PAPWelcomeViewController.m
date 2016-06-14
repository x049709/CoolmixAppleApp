//
//  PAPWelcomeViewController.m
//  Anypic
//
//  Created by prateek sahrma on 17/12/20145/10/12.
//

#import "PAPWelcomeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SharingView.h"

@implementation PAPWelcomeViewController


#pragma mark - UIViewController

- (void)loadView
{
    /*
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage imageNamed:@"Default.png"]];
    self.view = backgroundImageView;
    */
}

- (void)viewWillAppear:(BOOL)animated
{
    //MWLogDebug(@"\nPAPWelcomeViewController viewWillAppear: Started.");
    [super viewWillAppear:animated];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Coolmix" bundle:nil];
    LoginViewController *loginViewController = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    //self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:loginViewController animated:YES];
    //[self.navigationController presentViewController:loginViewController animated:NO completion:nil];
}

@end
