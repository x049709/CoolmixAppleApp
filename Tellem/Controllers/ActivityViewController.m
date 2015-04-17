//
//  ActivityViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 07/04/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "ActivityViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "AppDelegate.h"
@interface ActivityViewController ()
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@end

@implementation ActivityViewController

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
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"ACTIVITIES";
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
}
- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile",
                                  @"Settings",@"Log out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (PFQuery *)queryForTable
{
    /*
    
        PFQuery *friendid_Query=[PFQuery queryWithClassName:@"Activity"];
        [friendid_Query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [friendid_Query whereKey:@"type" equalTo:@"follow"];
        NSArray *arr_Friends=[friendid_Query findObjects];
        // Use cached facebook friend ids
    
    
        PFQuery *photo_Query=[PFQuery queryWithClassName:@"Activity"];
        [photo_Query whereKey:@"fromUser" containedIn:[arr_Friends valueForKey:@"toUser"]];
        [photo_Query whereKey:@"type" equalTo:@"comment"];
    
        NSArray *arr_Photos=[photo_Query findObjects];
        //NSLog(@"friend %@",arr_Photos);
    
    
        NSArray *facebookFriends = [arr_Friends valueForKey:@"toUser"];
    
        // Query for all friends you have on facebook and who are using the app
        PFQuery *friendsQuery = [PFUser query];
        [friendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookFriends];
    
        // Query for all Parse employees
        NSMutableArray *parseEmployees = [[NSMutableArray alloc] initWithArray:kPAPParseEmployeeAccounts];
        [parseEmployees removeObject:[[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]];
        PFQuery *parseEmployeeQuery = [PFUser query];
        [parseEmployeeQuery whereKey:kPAPUserFacebookIDKey containedIn:parseEmployees];
    */
    self.tableView.separatorColor=[UIColor clearColor];
    self.parseClassName = kPAPPhotoClassKey;
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 1000;
    
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromFollowedUsersQuery whereKeyExists:kPAPPhotoPictureKey];
    
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, nil]];
    [query includeKey:kPAPPhotoUserKey];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    
    
    /*
     This query will result in an error if the schema hasn't been set beforehand. While Parse usually handles this automatically, this is not the case for a compound query such as this one. The error thrown is:
     
     Error: bad special key: __type
     
     To set up your schema, you may post a photo with a caption. This will automatically set up the Photo and Activity classes needed by this query.
     
     You may also use the Data Browser at Parse.com to set up your classes in the following manner.
     
     Create a User class: "User" (if it does not exist)
     
     Create a Custom class: "Activity"
     - Add a column of type pointer to "User", named "fromUser"
     - Add a column of type pointer to "User", named "toUser"
     - Add a string column "type"
     
     Create a Custom class: "Photo"
     - Add a column of type pointer to "User", named "user"
     
     You'll notice that these correspond to each of the fields used by the preceding query.
     */
    
    return query;
    
}

@end
