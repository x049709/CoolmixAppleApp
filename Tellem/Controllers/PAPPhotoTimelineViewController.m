//
//  PAPPhotoTimelineViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 11/04/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "PAPPhotoTimelineViewController.h"
#import "PAPUtility.h"
#import "PAPPhotoCell.h"
#import "PAPLoadMoreCell.h"
#import "AppDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "CirclePhotoDetailsViewController.h"
#import "PAPAccountViewController.h"
#import "PAPCache.h"
#import "UIImage+ImageEffects.h"

#define BOOLToNSString(aBOOL)    aBOOL? @"YES" : @"NO"

@interface PAPPhotoTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, assign) NSString *initialComment;
@end

@implementation PAPPhotoTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize initialComment;


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        // The className to query on
        self.parseClassName = kPAPPhotoClassKey;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of objects to show per page
        self.objectsPerPage = 10;
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        self.shouldReloadOnAppear = NO;
    }
    return self;
}
- (void)viewDidLoad {
    //MWLogDebug(@"\nPAPPhotoTimelineViewController viewDidLoad started");
    [super viewDidLoad];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSBackgroundColorAttributeName : [UIColor blackColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"HOME";
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    UIView *tabBarBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    tabBarBackgroundView.backgroundColor = [UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight];

    /* Code to use image effects on profile picture as background color
    PFUser *user = [PFUser currentUser];
    PFFile *profileImage = [user valueForKey:@"profilePictureMedium"];
    //NSLog(@"PAPhotoTimelineViewController viewDidLoad user: %@ \npicture: %@",user, profileImage);
    if (profileImage) {
        [profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [[UIImage imageWithData:data] applyLightEffect];
                tabBarBackgroundView.layer.contents = (id)image.CGImage;
                //tabBarBackgroundView.backgroundColor= [UIColor colorWithPatternImage:[image applyLightEffect]];
            }
        }];
    }
    */
    
    self.tableView.backgroundView = tabBarBackgroundView;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldReloadOnAppear)
    {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}
- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel"destructiveButtonTitle:nil otherButtonTitles:@"My profile",@"Settings",@"Log out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *) getBackgroundImage {
    UIColor *bgColor = [UIColor blueColor];
    return bgColor;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections != 0)
        sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load more section
        return nil;
    }
    PAPPhotoHeaderView *headerView = [self dequeueReusableSectionHeaderView];
    //UIImage *myImage = [UIImage imageNamed:@"header-image.png"];
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    //imageView.frame = CGRectMake(0.0f, 10.0f, self.view.bounds.size.width, 40.0f);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.view.bounds.size.width, 40.0f)];
    [imageView addSubview:headerView];
   
    if (!headerView) {
        headerView = [[PAPPhotoHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 10.0f, self.view.bounds.size.width+0.0f, 40.0f) buttons:PAPPhotoHeaderButtonsDefault];
        headerView.delegate = self;
        [self.reusableSectionHeaderViews addObject:headerView];
    }
    
    PFObject *photo = [self.objects objectAtIndex:section];
    [headerView setPhoto:photo];
    headerView.tag = section;
    [headerView.likeButton setTag:section];
    
    NSDictionary *attributesForPhoto = [[PAPCache sharedCache] attributesForPhoto:photo];
    
    
    if (attributesForPhoto) {
        [headerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:photo]];
        [headerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForPhoto:photo] description] forState:UIControlStateNormal];
        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:photo] description] forState:UIControlStateNormal];
        
        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.200f animations:^{
                headerView.likeButton.alpha = 1.0f;
                headerView.commentButton.alpha = 1.0f;
            }];
        }
    } else {
        headerView.likeButton.alpha = 0.0f;
        headerView.commentButton.alpha = 0.0f;
        
        @synchronized(self) {
            // Check if we can update the cache
            NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:@(section)];
            if (!outstandingSectionHeaderQueryStatus) {
                PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingSectionHeaderQueries removeObjectForKey:@(section)];
                        if (error) {
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
                                //self.initialComment = [activity objectForKey:kPAPActivityContentKey];
                             } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPostWithDefaultPicture] && [activity objectForKey:kPAPActivityFromUserKey]) {
                                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                                //self.initialComment = [activity objectForKey:kPAPActivityContentKey];
                            }
                        
                            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                    isLikedByCurrentUser = YES;
                                }
                            }
                        }
                        
                        [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                        
                        if (headerView.tag != section) {
                            return;
                        }
                        
                        [headerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:photo]];
                        [headerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForPhoto:photo] description] forState:UIControlStateNormal];
                        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:photo] description] forState:UIControlStateNormal];
                        
                        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.200f animations:^{
                                headerView.likeButton.alpha = 1.0f;
                                headerView.commentButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }
        }
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 40.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 10.0f, self.tableView.bounds.size.width, 10.0f)];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 00.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load more Section
        return 40.0f;
    }
    return 388.0f;
 }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load more Cell
        [self loadNextPage];
    }
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    self.tableView.separatorColor=[UIColor clearColor];
    self.parseClassName = kPAPPhotoClassKey;
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 1000;
    
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromFollowedUsersQuery whereKey:kPAPPhotoUserKey matchesKey:kPAPActivityToUserKey inQuery:followingActivitiesQuery];
    [photosFromFollowedUsersQuery whereKeyExists:kPAPPhotoPictureKey];
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromCurrentUserQuery whereKey:kPAPPhotoUserKey equalTo:[PFUser currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:kPAPPhotoPictureKey];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromCurrentUserQuery, nil]];
    [query includeKey:kPAPPhotoUserKey];
    [query orderByDescending:@"createdAt"];
    
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table and then subsequently do a query against the network.
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
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

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.section == self.objects.count)
    {
        // This behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    } else {
        PAPPhotoCell *cell = (PAPPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[PAPPhotoCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        }

        //UIImage *bgImage = [[UIImage imageNamed:@"DetailBackground.png"] applyLightEffect];
        //cell.imageView.backgroundColor= [UIColor colorWithPatternImage:bgImage];
        cell.photoButton.tag = indexPath.section;
        if (object) {
            cell.imageView.file = [object objectForKey:kPAPPhotoPictureKey];
            //NSString *headerText = @"Well, hello there! ";
            //headerText = [headerText stringByAppendingString:object.objectId];
            //[cell.headerLabel setText:headerText];

            PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:object cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                @synchronized(self) {
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPost] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [cell.headerLabel setText:[activity objectForKey:kPAPActivityContentKey]];
                            cell.usesDefaultPicture = NO;
                        } else
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPostWithDefaultPicture] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [cell.headerLabel setText:[activity objectForKey:kPAPActivityContentKey]];
                            cell.usesDefaultPicture = YES;
                            //NSString  *headerText = BOOLToNSString(cell.usesDefaultPicture);
                            //headerText = [headerText stringByAppendingString:[activity objectForKey:kPAPActivityContentKey]];
                            //[cell.headerLabel setText:headerText];
                        }
                     }
                }
            }];
        
            // The InBackground methods are asynchronous, so any code after this will run
            // immediately.  Any code that depends on the query result should be moved
            // inside the completion block above
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([cell.imageView.file isDataAvailable]) {
                
                [cell.imageView loadInBackground];
                [cell.imageView.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        cell.imageView.backgroundColor= [UIColor colorWithPatternImage:[image applyLightEffect]];
                    }
                }];
            }
        }

        /*
        if (cell.usesDefaultPicture) {
            //MWLogDebug(@"\nPAPPhotoTimelineViewController.m cellForRowAtIndexPath: Objectid is %@", object.objectId);
            PAPPhotoCell *emptycell = [[PAPPhotoCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
            emptycell.imageView.backgroundColor = [UIColor darkGrayColor];
            [emptycell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
            emptycell.photoButton.tag = indexPath.section;

            return emptycell;
        };
        */
        
        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell)
    {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.mainView.backgroundColor = [UIColor clearColor];
       
    }
    return cell;
}


#pragma mark - PAPPhotoTimelineViewController

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView {
    for (PAPPhotoHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    return nil;
}

#pragma mark - PAPPhotoHeaderViewDelegate

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo
{
	// Disable the button so users cannot send duplicate requests
    
    [photoHeaderView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [photoHeaderView setLikeStatus:liked];
    
    NSString *originalButtonTitle = button.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[PAPCache sharedCache] incrementLikerCountForPhoto:photo];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[PAPCache sharedCache] decrementLikerCountForPhoto:photo];
    }
    
    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
    
    [button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    
    if (liked) {
        [PAPUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:succeeded];
            
            if (!succeeded) {
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:!succeeded];
            
            if (!succeeded) {
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    }
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    CirclePhotoDetailsViewController *photoDetailsVC = [[CirclePhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}


#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    self.shouldReloadOnAppear = YES;
}

- (void)didTapOnPhotoAction:(UIButton *)sender {
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    if (photo)
    {
        CirclePhotoDetailsViewController *photoDetailsVC = [[CirclePhotoDetailsViewController alloc] initWithPhoto:photo];
        self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}
@end
