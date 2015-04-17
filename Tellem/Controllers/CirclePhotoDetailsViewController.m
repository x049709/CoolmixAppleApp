//
//  CirclePhotoDetailsViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 5/15/12.
//  Copyright (c) 2013 Tellem. All rights reserved.
//

#import "CirclePhotoDetailsViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPActivityCell.h"
#import "PAPPhotoDetailsFooterView.h"
#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPUtility.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PAPCache.h"
#import "UIImage+ImageEffects.h"
#import "CirclesListViewController.h"
#import "TellemUtility.h"

enum ActionSheetTags {
    MainActionSheetTag = 0,
    ConfirmDeleteActionSheetTag = 1
};

@interface CirclePhotoDetailsViewController ()
    {
        NSString *longitudeLabel;
        NSString *latitudeLabel;
    }

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PAPPhotoDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;

@end

static const CGFloat kPAPCellInsetWidth = 2.0f;

@implementation CirclePhotoDetailsViewController

@synthesize commentTextField,sortedCircleActivities;
@synthesize photo, headerView, texturedBackgroundView, pageCircle, pageIndex, pushPayload, photoIndex;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (id)initWithPhoto:(PFObject *)aPhoto {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;
        
        self.photo = aPhoto;
        
        self.likersQueryInProgress = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"DETAILS";
    self.navigationItem.backBarButtonItem.tintColor = [UIColor redColor];
    locationManager = [[CLLocationManager alloc] init];
    // Set table view properties
    self.texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView = texturedBackgroundView;
    
    // Set table header
    self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:[PAPPhotoDetailsHeaderView rectForView] photo:self.photo];
    self.headerView.delegate = self;
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    PAPPhotoDetailsFooterView *footerView = [[PAPPhotoDetailsFooterView alloc] initWithFrame:[PAPPhotoDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    commentTextField.delegate = self;
    self.tableView.tableFooterView = footerView;

    /*
    if (NSClassFromString(@"UIActivityViewController")) {
        // Use UIActivityViewController if it is available (iOS 6 +)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(activityButtonAction:)];
    } else if ([self currentUserOwnsPhoto]) {
        // Else we only want to show an action button if the user owns the photo and has permission to delete it.
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonAction:)];
    }
    */
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.pushPayload = Nil;
    [self.headerView homePhotoDetailsWillDisappear];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getUserLocation];
    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[PAPCache sharedCache] attributesForPhoto:self.photo] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
    
    if (self.objects.count>0) {
        int rowIndex = self.objects.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    } else {
        CGFloat height = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        [self.tableView setContentOffset:CGPointMake(0, height) animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            NSString *commentString = [self.objects[indexPath.row] objectForKey:kPAPActivityContentKey];
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kPAPActivityFromUserKey];
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kPAPUserDisplayNameKey];
            }
            return [PAPActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
        }
    }
    
    // The pagination row
    return 44.0f;
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    NSUInteger actCount = [TellemUtility countActivitiesForCircle: self.pageCircle andPhoto: self.photo];
    NSUInteger limit=0;
    NSUInteger skip=0;;
    if (actCount <= 30)
    {
        limit = 30;
        skip = 0;
    }
    else
    {
        limit = 30;
        skip = actCount - 30;
    }

    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [query whereKey:kPAPActivityCircleKey equalTo:self.pageCircle];
    [query whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeComment,kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [query includeKey:kPAPActivityFromUserKey];
    [query orderByAscending:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    //[query setLimit: limit];
    [query setSkip: skip];


    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";

    // Try to dequeue a cell and create one if necessary
    PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.delegate = self;
    }
    
    [cell setUser:[object objectForKey:kPAPActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kPAPActivityContentKey]];
    [cell setDate:[object createdAt]];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.photo objectForKey:kPAPPhotoUserKey]) {
        PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
        [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
        [comment setObject:[self.photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
        [comment setObject:self.photo forKey:kPAPActivityPhotoKey];
        if (self.pageCircle) {
            [comment setObject:self.pageCircle forKey:kPAPActivityCircleKey];
        }
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
        comment.ACL = ACL;

        [[PAPCache sharedCache] incrementCommentCountForPhoto:self.photo];
        if (latitudeLabel!=nil) {
            [comment setObject:latitudeLabel forKey:@"latitude"];
            [comment setObject:longitudeLabel forKey:@"longitude"];
        }
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];

        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && error.code == kPFErrorObjectNotFound) {
                [[PAPCache sharedCache] decrementCommentCountForPhoto:self.photo];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tellem", nil) message:NSLocalizedString(@"Could not post comment. This photo is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            // [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.photo userInfo:@{@"comments": @(self.objects.count + 1)}];
            [self updateDateOfInitialActivity];
            [self notifyCircleOfPostingwithComment:comment];
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
        
    }

    [textField setText:@""];
    int rowIndex = self.objects.count -1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    return [textField resignFirstResponder];
}

-(void) notifyCircleOfPostingwithComment: (PFObject *) comment {
    PFUser *user = [PFUser currentUser];
    NSArray *circleMembers = [NSArray array];
    circleMembers = [self.pageCircle objectForKey:kPAPCircleMemberUserIdArray];
    NSMutableArray *membersToNotify = [NSMutableArray array];
    
    for(int i=0;i<circleMembers.count;i++)
    {
        NSString *searchUser = [user username];
        NSString *memberUser = [circleMembers  objectAtIndex:i];
        if(![memberUser isEqualToString:searchUser])
        {
            [membersToNotify addObject:memberUser];
        }
    }

    if (membersToNotify.count > 0) {
        //NSString *message = @"";
        NSString *message = [NSString stringWithFormat:@"%@ posted to a circle!", user[@"displayName"]];
        NSArray *payLoadPhoto = [NSArray array];
        NSArray *payLoadPageIndex = [NSArray array];
        payLoadPhoto = [NSArray arrayWithObjects:@"photo", kPAPobjectIDKey, self.photo, self.pageCircle,nil];
        payLoadPageIndex = @[@"circle", @"pageIndex", [NSString stringWithFormat:@"%tu", self.pageIndex]];
        NSArray *payLoad = [NSArray arrayWithObjects:payLoadPhoto, payLoadPageIndex,kPAPPushCommentOnPost,nil];
        [TellemUtility sendMessageToManyUsers:membersToNotify withCircleName:[self.pageCircle valueForKey:kPAPCircleNameKey] andSendingUser:user andMessage:message andMessageType:kPAPPushCommentOnPost andPayload:payLoad];
        NSString *strFromInt = [NSString stringWithFormat:@"%lu",(unsigned long)membersToNotify.count];
        NSString *notifyMsg = [@"Sending notifications to " stringByAppendingString:strFromInt];
        NSString *msgInfo = [@"Msg is \"" stringByAppendingString:[comment valueForKey:kPAPActivityContentKey]];
        msgInfo = [msgInfo stringByAppendingString:@"\" to "];
        notifyMsg = [notifyMsg stringByAppendingString:@" members"];
        [TellemUtility tellemLog:notifyMsg andMsgInfo:[NSArray arrayWithObjects:msgInfo,membersToNotify,nil]];
    }
}

- (void)updateDateOfInitialActivity {
    PFQuery *circleActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [circleActivitiesQuery whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [circleActivitiesQuery whereKey:kPAPActivityTypeKey  containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    PFObject *activity = [circleActivitiesQuery getFirstObject];
    NSTimeInterval rightNow = [NSDate timeIntervalSinceReferenceDate];
    rightNow = ((NSTimeInterval)((long long)(rightNow * 1000)) / 1000);
    NSDate * lastUpdated = [NSDate dateWithTimeIntervalSinceReferenceDate:rightNow];
    [activity setObject:lastUpdated forKey:kPAPActivityLastUpdated];
    [activity save];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            // prompt to delete
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this photo?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, delete photo", nil) otherButtonTitles:nil];
            actionSheet.tag = ConfirmDeleteActionSheetTag;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [self activityButtonAction:actionSheet];
        }
    } else if (actionSheet.tag == ConfirmDeleteActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            [self shouldDeletePhoto];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
}

#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}


#pragma mark - PAPPhotoDetailsHeaderViewDelegate

-(void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

-(void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didSwipePhotoImage:(UISwipeGestureRecognizer *)swipe photo:(PFObject *)newPhoto {
    //Reload page with new photo
    int currentPhotoIndex = [TellemUtility pickIndexOfPhotoFromCircleActivities:self.sortedCircleActivities andPhoto:photo];
    int nextPhotoIndex = currentPhotoIndex;
    if ((swipe.direction == UISwipeGestureRecognizerDirectionLeft) && (currentPhotoIndex < self.sortedCircleActivities.count -1)) {
            nextPhotoIndex = currentPhotoIndex + 1;
    }
    if ((swipe.direction == UISwipeGestureRecognizerDirectionRight) && (currentPhotoIndex > 0)) {
        nextPhotoIndex = currentPhotoIndex - 1;
    }
    //NSLog (@"currentIndex: %d, nextIndex: %d", currentPhotoIndex,nextPhotoIndex);
    PFObject *circleActivity = [self.sortedCircleActivities objectAtIndex:nextPhotoIndex];
    PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
    if (activityPhoto) {
        self.photo = activityPhoto;
        //From viewDidLoad
        // Set table header
        self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:[PAPPhotoDetailsHeaderView rectForView] photo:self.photo];
        self.headerView.delegate = self;
        self.tableView.tableHeaderView = self.headerView;
        // Set table footer
        PAPPhotoDetailsFooterView *footerView = [[PAPPhotoDetailsFooterView alloc] initWithFrame:[PAPPhotoDetailsFooterView rectForView]];
        commentTextField = footerView.commentField;
        commentTextField.delegate = self;
        self.tableView.tableFooterView = footerView;
        //Reload photo objects
        [self loadObjects];
        //Reload page
        [self.tableView reloadData];
        [self.view setNeedsDisplay];
    }
    
    //[self didSwipePhotoImage:swipe];
    
}

-(void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didLongPress:(UIImage *)photoToZoom {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZoomViewController *zoomView = (ZoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ZoomViewController"];
    zoomView.photoToZoom = photoToZoom;
    zoomView.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    //[self.navigationController pushViewController:zoomView animated:YES];
    [self.navigationController presentViewController:zoomView animated:YES completion:nil];
    
}

- (void)actionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = MainActionSheetTag;
    actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete photo", nil)];
    if (NSClassFromString(@"UIActivityViewController")) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share photo", nil)];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)activityButtonAction:(id)sender {
    if (NSClassFromString(@"UIActivityViewController")) {
        // TODO: Need to do something when the photo hasn't finished downloading!
        if ([[self.photo objectForKey:kPAPPhotoPictureKey] isDataAvailable]) {
            [self showShareSheet];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!error) {
                    [self showShareSheet];
                }
            }];
        }
    }
}


#pragma mark - ()

- (void)showShareSheet {
    [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                        
            // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
            if ([[[PFUser currentUser] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]] && [self.objects count] > 0) {
                PFObject *firstActivity = self.objects[0];
                if ([[[firstActivity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]]) {
                    NSString *commentString = [firstActivity objectForKey:kPAPActivityContentKey];
                    [activityItems addObject:commentString];
                }
            }
            
            [activityItems addObject:[UIImage imageWithData:data]];
            [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://anypic.org/#pic/%@", self.photo.objectId]]];
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        }
    }];
}

- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tellem", nil) message:NSLocalizedString(@"Your comment will be posted next time there is an [nternet connection.", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    //Disable this function
    //PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    //[accountViewController setUser:user];
    //self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    //[self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height-kbSize.height) animated:YES];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }

    self.likersQueryInProgress = YES;
    PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            [self.headerView reloadLikeBar];
            return;
        }
        
        NSMutableArray *likers = [NSMutableArray array];
        NSMutableArray *commenters = [NSMutableArray array];
        
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject *activity in objects) {
            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPost] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPostWithDefaultPicture] && [activity objectForKey:kPAPActivityFromUserKey])
            {
                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            }
        
            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
        }
        
        [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        [self.headerView reloadLikeBar];
    }];
}

- (BOOL)currentUserOwnsPhoto {
    return [[[self.photo objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
}

- (void)shouldDeletePhoto {
    // Delete all activites related to this photo
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete photo
        [self.photo deleteEventually];
    }];
   // [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.photo objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getUserLocation{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"CirclePhotoDetailsView Controller. locationManager. Failed to get your location");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        
        longitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        //NSLog(@"long %@ lat %@",longitudeLabel,latitudeLabel);
    }
    [locationManager stopUpdatingLocation];
}


@end
