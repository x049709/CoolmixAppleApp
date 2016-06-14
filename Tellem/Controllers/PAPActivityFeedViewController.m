//
//  PAPActivityFeedViewController.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPActivityFeedViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPActivityCell.h"
#import "PAPAccountViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPLoadMoreCell.h"
#import "PAPUtility.h"
#import "PAPSettingsButtonItem.h"
#import "AppDelegate.h"
#import "PAPFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "FHSTwitterEngine.h"
#import "TwitterFriendViewController.h"
@interface PAPActivityFeedViewController ()
{
    NSString *str_Temp;
    UIButton * headerBtnTW;
    UIButton * headerBtnIStgm;
    UIButton * headerBtnFB;
    UIImage *SelectImg;
}
//@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@end

@implementation PAPActivityFeedViewController

@synthesize settingsActionSheetDelegate,shouldReloadOnAppear;
@synthesize lastRefresh;
@synthesize blankTimelineView;

#pragma mark - Initialization

- (void)dealloc {
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // The number of objects to show per page
        self.objectsPerPage = 15;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    str_Temp=@"Twitter";
    headerBtnTW.selected=YES;
    [super viewDidLoad];

    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];

    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    blankTimelineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 50.0, 300.0, 140.0)];
    
    UIButton *buttonInvite = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonInvite setBackgroundImage:[UIImage imageNamed:@"ActivityFeed.png"] forState:UIControlStateNormal];
    [buttonInvite setFrame:CGRectMake(55.0f, 145.0f, 190.0f, 45.0f)];
    //[buttonInvite addTarget:self action:@selector(inviteFriendsAction:) forControlEvents:UIControlEventTouchUpInside];
    [blankTimelineView addSubview:buttonInvite];
    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kPAPActivityTypeKey]];

        PFUser *user = (PFUser*)[object objectForKey:kPAPActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kPAPUserDisplayNameKey] && [[user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kPAPUserDisplayNameKey];
        }
        return [PAPActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 20.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    //TwitterFriendViewController *twit_friend = (TwitterFriendViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TwitterFriends"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count)
    {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kPAPActivityPhotoKey])
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:@"Share FriendsTimeline"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel Button"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"Share Facebook",@"Share Twitter", nil];
            
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
            
           [(PFFile*)[[activity objectForKey:kPAPActivityPhotoKey] objectForKey:kPAPPhotoThumbnailKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                     SelectImg= [UIImage imageWithData:data];
                    }
            }];
            PAPPhotoDetailsViewController *detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if ([activity objectForKey:kPAPActivityFromUserKey])
        {
            PAPAccountViewController *detailViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [detailViewController setUser:[activity objectForKey:kPAPActivityFromUserKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else{
            //NSLog(@"shared.!");
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
   UIView* View = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 50.0)];
    headerBtnTW = [[UIButton alloc] initWithFrame:CGRectZero];
    headerBtnTW.opaque = NO;
    headerBtnTW.frame = CGRectMake(106.0, 0.0, 106.0, 50.0);
    //[headerBtnTW setTitle:@"Twitter" forState:UIControlStateNormal];
    [headerBtnTW setImage:[UIImage imageNamed:@"twitter-selected.png"] forState:UIControlStateSelected];
    [headerBtnTW setImage:[UIImage imageNamed:@"tweeter-unselected.png"] forState:UIControlStateNormal];
    [headerBtnTW addTarget:self action:@selector(ActionEventTWButton) forControlEvents:UIControlEventTouchUpInside];
    [View addSubview:headerBtnTW];
    
    headerBtnIStgm = [[UIButton alloc] initWithFrame:CGRectZero];
    headerBtnIStgm.opaque = NO;
    headerBtnIStgm.frame = CGRectMake(212.0, 0.0, 106.0, 50.0);;
    //[headerBtnIStgm setTitle:@"Instagram" forState:UIControlStateNormal];
    [headerBtnIStgm setImage:[UIImage imageNamed:@"instagram-selected.png"] forState:UIControlStateSelected];
    [headerBtnIStgm setImage:[UIImage imageNamed:@"instagram-unselected.png"] forState:UIControlStateNormal];
    [headerBtnIStgm addTarget:self action:@selector(ActionEventInstButton) forControlEvents:UIControlEventTouchUpInside];
    [View addSubview:headerBtnIStgm];
    
    headerBtnFB = [[UIButton alloc] initWithFrame:CGRectZero];
    headerBtnFB.opaque = NO;
    headerBtnFB.frame = CGRectMake(0.0, 0.0, 106.0, 50.0);
    //[headerBtnFB setTitle:@"Facebook" forState:UIControlStateNormal];
    [headerBtnFB setImage:[UIImage imageNamed:@"facebook-selected.png"] forState:UIControlStateSelected];
    [headerBtnFB setImage:[UIImage imageNamed:@"facebook-unselected.png"] forState:UIControlStateNormal];
    [headerBtnFB addTarget:self action:@selector(ActionEventFBButton) forControlEvents:UIControlEventTouchUpInside];
    [View addSubview:headerBtnFB];
    
    if ([str_Temp isEqualToString:@"Twitter"])
    {
        headerBtnTW.selected=YES;
        headerBtnFB.selected=NO;
        headerBtnIStgm.selected=NO;
    }
    if ([str_Temp isEqualToString:@"Instagram"])
    {
        headerBtnTW.selected=NO;
        headerBtnFB.selected=NO;
        headerBtnIStgm.selected=YES;
    }
    if ([str_Temp isEqualToString:@"FB"])
    {
        headerBtnTW.selected=NO;
        headerBtnFB.selected=YES;
        headerBtnIStgm.selected=NO;
    }
    return View;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}
-(void)ActionEventFBButton
{
    //NSLog(@"FB");
    str_Temp=@"FB";
    [self loadObjects];
}
-(void)ActionEventTWButton
{
    //NSLog(@"TW");
    str_Temp=@"Twitter";
    [self loadObjects];
} 
-(void)ActionEventInstButton
{
    //NSLog(@"Inst");
    str_Temp=@"Instagram";
    [self loadObjects];
}

- (PFQuery *)queryForTable {
    
    self.parseClassName = kPAPPhotoClassKey;
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    NSArray *Arr_Following=[queryFollowingCount findObjects];
    NSMutableArray *Arr_temp=[[NSMutableArray alloc]init];
    for (int i=0; i<Arr_Following.count; i++) {
        
        PFObject *activity=[Arr_Following objectAtIndex:i];
        PFUser *tempuser=(PFUser *)[activity valueForKey:@"toUser"];
        PFQuery *qry_user=[PFQuery queryWithClassName:@"_User"];
        [qry_user whereKey:@"objectId" equalTo:tempuser.objectId];
        NSArray *allData=[qry_user findObjects];
        
        PFUser *finaluser=[allData objectAtIndex:i];

        if([[finaluser valueForKey:@"Accounttype"] isEqualToString:str_Temp])
        {
            [Arr_temp addObject:[allData objectAtIndex:0]];
        }
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityFromUserKey containedIn:Arr_temp];
    [query whereKeyExists:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityPhotoKey];
    [query orderByDescending:@"createdAt"];
    return query;
    
    //    PFQuery *friendid_Query=[PFQuery queryWithClassName:@"Activity"];
    //    [friendid_Query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    //    [friendid_Query whereKey:@"type" equalTo:@"follow"];
    //    NSArray *arr_Friends=[friendid_Query findObjects];
    //    // Use cached facebook friend ids
    //
    //
    //    PFQuery *photo_Query=[PFQuery queryWithClassName:@"Activity"];
    //    [photo_Query whereKey:@"fromUser" containedIn:[arr_Friends valueForKey:@"toUser"]];
    //    [photo_Query whereKey:@"type" equalTo:@"comment"];
    //
    //    NSArray *arr_Photos=[photo_Query findObjects];
    //    NSLog(@"friend %@",arr_Photos);
    //
    //dhruvvarde2@g ... dhruvvardegoole+2
    //
    //    NSArray *facebookFriends = [arr_Friends valueForKey:@"toUser"];
    //
    //    // Query for all friends you have on facebook and who are using the app
    //    PFQuery *friendsQuery = [PFUser query];
    //    [friendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookFriends];
    //
    //    // Query for all Parse employees
    //    NSMutableArray *parseEmployees = [[NSMutableArray alloc] initWithArray:kPAPParseEmployeeAccounts];
    //    [parseEmployees removeObject:[[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]];
    //    PFQuery *parseEmployeeQuery = [PFUser query];
    //    [parseEmployeeQuery whereKey:kPAPUserFacebookIDKey containedIn:parseEmployees];
    //.............................................//...............................................................
    
    // Create query
    
    //     self.parseClassName = kPAPPhotoClassKey;
    //
    //    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    //    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    //    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    //    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    //    followingActivitiesQuery.limit = 1000;
    //
    //    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    //    [photosFromFollowedUsersQuery whereKey:kPAPPhotoUserKey matchesKey:kPAPActivityToUserKey inQuery:followingActivitiesQuery];
    //    [photosFromFollowedUsersQuery whereKeyExists:kPAPPhotoPictureKey];
    //
    //
    //    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, nil]];
    //    [query includeKey:kPAPPhotoUserKey];
    //    [query orderByDescending:@"createdAt"];
    //
    //    // A pull-to-refresh should always trigger a network request.
    //    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    //    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
    //        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    //.............................................//.......................................................
    
    
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
    //return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;

        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            [self.tableView addSubview:blankTimelineView];
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        [blankTimelineView removeFromSuperview];
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0)
        {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
        
        [self.tableView reloadData];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";

    PAPActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PAPActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    [cell setActivity:object];

    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }

    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
   }
    return cell;
}

#pragma mark - PAPActivityCellDelegate Methods


- (void)cell:(PAPActivityCell *)cellView didTapActivityButton:(PFObject *)activity {    
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kPAPActivityPhotoKey];
    
    // Push single photo view controller
    PAPPhotoDetailsViewController *photoViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)user {    
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kPAPActivityTypeLike]) {
        return NSLocalizedString(@"liked your photo", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeFollow]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeComment]) {
        return NSLocalizedString(@"commented on your photo", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeJoined]) {
        return NSLocalizedString(@"joined Anypic", nil);
    } else {
        return nil;
    }
}

#pragma mark - ()

- (void)settingsButtonAction:(id)sender {
    settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"My Profile", nil), NSLocalizedString(@"Find Friends", nil), NSLocalizedString(@"Log Out", nil), nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

//- (void)inviteFriendsAction:(id)sender {
//    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
//    [self.navigationController pushViewController:detailViewController animated:YES];
//}
- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    [self loadObjects];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
//            [self PostImageFacebook];
            break;
        case 1:
            [self getObjectTwitter];
            break;
        default:
            break;
    }
}
#pragma FacebookPost

//-(void)PostImageFacebook{
//    
//    if (!FBSession.activeSession.isOpen) {
//        // if the session is closed, then we open it here, and establish a handler for state changes
//        [FBSession openActiveSessionWithReadPermissions:nil
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session,
//                                                          FBSessionState state,
//                                                          NSError *error) {
//                                          if (error) {
//                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tellem"
//                                                                                                  message:error.localizedDescription
//                                                                                                 delegate:nil
//                                                                                        cancelButtonTitle:@"OK"
//                                                                                        otherButtonTitles:nil];
//                                              [alertView show];
//                                          } else if (session.isOpen) {
//                                              
//                                              ApplicationDelegate.session=session;
//                                              [self PostImageFacebook];
//                                          }
//                                      }];
//        return;
//    }
//    
//    if (self.friendPickerController == nil)
//    {
//        // Create friend picker, and get data loaded into it.
//        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
//        self.friendPickerController.title = @"Pick Friends";
//        self.friendPickerController.delegate = self;
//    }
//    [self.friendPickerController loadData];
//    [self.friendPickerController clearSelection];
//    [self presentViewController:self.friendPickerController animated:YES completion:nil];
//}
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    [self getObjectFacebook];
    [[sender presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    //NSLog(@"Canceled");
    // Dismiss the friend picker
    [[sender presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
-(void)getObjectFacebook{
    
//    if (ApplicationDelegate.session.isOpen)
//    {
//        for (NSDictionary<FBGraphUser> *user in self.friendPickerController.selection) {
//            
//            if (ApplicationDelegate.session.isOpen)
//            {
//                NSMutableDictionary  *postVariablesDictionary = [[NSMutableDictionary alloc] init];
//                [postVariablesDictionary setObject:SelectImg forKey:@"source"];
//                //[postVariablesDictionary setObject:UIImagePNGRepresentation(self.image)  forKey:@"source"];
//                [postVariablesDictionary setObject:@"my image" forKey:@"message"];
//                [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/photos",user.objectID] parameters:postVariablesDictionary HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {}];
//            }
//        }
//    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)getObjectTwitter{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    TwitterFriendViewController *twit_friend = (TwitterFriendViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TwitterFriends"];
    twit_friend.Img= SelectImg;
    [self.navigationController presentViewController:twit_friend animated:YES completion:nil];
}
@end
