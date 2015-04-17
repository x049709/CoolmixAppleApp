//
//  HomeActivitiesViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "HomeActivitiesViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PostSharingViewController.h"
#import "PAPLoadMoreCell.h"
#import "UITableView+DragLoad.h"

@interface HomeActivitiesViewController () {
    UITextField *addCircleTextField;
}
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic) NSArray *sortedCircleNames;
@property (nonatomic) NSArray *circleUserIds;
@property (nonatomic) NSArray *sortedUserActivities;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

@end

@implementation HomeActivitiesViewController
{
    
}
@synthesize sortedCircleNames,circleUserIds,sortedUserActivities,circleTableView,titleText, titleLabel,pageCircle,pushPayload;
@synthesize activityImageView,activityUserId,activityInitialComment,circleAvatar,netWorkTable;
@synthesize posterNameLabel,postTimestampLabel,postLatestCommentsLabel,timeIntervalFormatter,pageIndex;

- (void)viewDidLoad
{
    //MWLogDebug(@"\nHomeActivitiesViewControllerviewDidLoad started.");
    [super viewDidLoad];


}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //MWLogDebug(@"\nHomeActivitiesViewController viewWillAppear: Started.");
    TellemGlobals *tM = [TellemGlobals globalsManager];
    [self getAllUserActivities];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    self.titleLabel.text = @"";
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"HOME";
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    [self setWelcomeMessage];
    
    /*
    //NSLog (@"sortedUserActivities");
    for (PFObject * sortedAct in sortedUserActivities) {
        NSDate *lastUpdate = [sortedAct objectForKey:kPAPActivityLastUpdated];
        PFObject *activityPhoto = [sortedAct objectForKey:kPAPActivityPhotoKey];
        //NSLog(@"activityPhoto, %@, %@", [activityPhoto valueForKey:kPAPobjectIDKey], lastUpdate);
    }
    */
    
}

- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheetSetting = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile", @"Settings",@"Log out", nil];
    
    [actionSheetSetting showFromTabBar:self.tabBarController.tabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setWelcomeMessage
{
    if (self.sortedUserActivities.count == 0) {
        
        UIView* tView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [tView setBackgroundColor:[UIColor darkGrayColor]];
        self.view = tView;
        UIView* insideView = [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, tView.bounds.size.width - 10, tView.bounds.size.height - 10)];
        [insideView setBackgroundColor:[UIColor whiteColor]];
        [tView addSubview:insideView];
        
        NSString *text = @"Welcome to Tellem! \nStart sharing stories within your own circles. \nExplore by using the buttons below.";
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(255.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:kFontNormal size:18.0f]} context:nil].size;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake( ([UIScreen mainScreen].bounds.size.width - textSize.width)/2.0f, 160.0f, textSize.width, textSize.height)];
        [textLabel setFont:[UIFont fontWithName:kFontNormal size:18.0f]];
        [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [textLabel setNumberOfLines:0];
        [textLabel setText:text];
        [textLabel setTextColor:[UIColor darkGrayColor]];
        //[textLabel setTextColor:[UIColor colorWithRed:255.0f/255.0f green:206.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [insideView addSubview:textLabel];
    }
}

-(void)getAllUserActivities {
    
    //NSLog (@"TODO Needs to relocate to the AppDelegate somewhere after geting PFUser");
    sortedUserActivities = [NSArray array];
    sortedUserActivities = [TellemUtility getAllActivitiesOfUserUsingSubquery:[PFUser currentUser]];
    [self.netWorkTable reloadData];
    //dispatch_async(dispatch_get_main_queue(), ^{
        //[self.circleTableView reloadRowsAtIndexPaths:[self.circleTableView  indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    //});
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     if (self.sortedUserActivities.count == 0) {
         UIView* tView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width,0)];
         [tView setBackgroundColor:[UIColor darkGrayColor]];
         return tView;
     } else {
         UIView* tView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 20)];
         return tView;
     }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.sortedUserActivities.count == 0) {
        return 20.0;
    } else {
        return 1.0;
    }
}

#pragma mark UItableView DataSource Delegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sortedUserActivities.count;
}

- (void)finishRefresh
{
}
- (void)dragTableDidTriggerRefresh:(UITableView *)tableView
{
    //send refresh request(generally network request) here
    [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:2];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell=nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    PFObject *userActivity = [self.sortedUserActivities objectAtIndex:indexPath.row];
    PFObject *activityPhoto = [userActivity objectForKey:kPAPActivityPhotoKey];
    PFObject *activityCircle = [userActivity objectForKey:kPAPActivityCircleKey];
    PFUser *activityPoster = [userActivity objectForKey:kPAPActivityToUserKey];
    PFFile *thumbnailPhoto = [activityPhoto objectForKey:kPAPPhotoThumbnailKey];
    //NSLog(@"cellForRowAtIndexPath activityPhoto, %lu, %@", indexPath.row, [activityPhoto valueForKey:kPAPobjectIDKey]);
    
    //Post photo
    PAPProfileImageView *activityPicture = [[PAPProfileImageView alloc] init];
    [activityPicture setFrame:CGRectMake(1,1,80,80)];
    [activityPicture.profileButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    activityPicture.profileButton.tag = indexPath.row;
    [activityPicture setFile:thumbnailPhoto];
    [cell addSubview:activityPicture];
    
    //Poster's name
    self.posterNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(90, 5, 200, 18)];
    self.posterNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.posterNameLabel.font = [UIFont fontWithName:kFontNormal size:16];
    self.posterNameLabel.textColor = [UIColor redColor];
    self.posterNameLabel.text = [activityPoster objectForKey:kPAPUserDisplayNameKey];
    [cell addSubview:self.posterNameLabel];

    //Post timestamp
    self.postTimestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(90,25,200,14)];
    [self.postTimestampLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
    self.postTimestampLabel.font = [UIFont fontWithName:kFontNormal size:12];
    NSTimeInterval timeInterval = [[userActivity objectForKey:kPAPActivityLastUpdated] timeIntervalSinceNow];
    NSString *timestamp = [TellemUtility timeInHumanReadableFormat:timeInterval];
    self.postTimestampLabel.text = timestamp;
    [cell addSubview:self.postTimestampLabel];

    //Circle name
    self.postLatestCommentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 38, 200, 20)];
    [self.postLatestCommentsLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
    self.postLatestCommentsLabel.font = [UIFont fontWithName:kFontThin size:14];
    //NSString *posterName = [activityPoster objectForKey:kPAPUserDisplayNameKey];
    NSString *posterName = [@"@" stringByAppendingString:[activityCircle objectForKey:kPAPCircleNameKey]];
    self.postLatestCommentsLabel.text = posterName;
    [cell addSubview:self.postLatestCommentsLabel];
    
    /*
    //Post latest comments
    self.postLatestCommentsLabel=[[UILabel alloc]initWithFrame:CGRectMake(90, 35, 200, 50)];
    self.postLatestCommentsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.postLatestCommentsLabel.font = [UIFont fontWithName:kFontThin size:14];
    self.postLatestCommentsLabel.text = activityContent;
    self.postLatestCommentsLabel.preferredMaxLayoutWidth = 200;
    self.postLatestCommentsLabel.numberOfLines  = 2;
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(200, 40);
    CGSize expectedLabelSize = [activityContent sizeWithFont:postLatestCommentsLabel.font constrainedToSize:maximumLabelSize lineBreakMode:postLatestCommentsLabel.lineBreakMode];
    CGRect newFrame = postLatestCommentsLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.postLatestCommentsLabel.frame = newFrame;
    [self.postLatestCommentsLabel sizeToFit];
    [self.postLatestCommentsLabel setNeedsDisplay];
    [cell addSubview:self.postLatestCommentsLabel];
    */
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    PFObject *userActivity = [self.sortedUserActivities objectAtIndex:indexPath.row];
    PFObject *activityPhoto = [userActivity objectForKey:kPAPActivityPhotoKey];
    PFObject *activityCircle = [userActivity objectForKey:kPAPActivityCircleKey];
    
    //NSLog (@"didSelectRowAtIndexPath");
    //NSLog(@"activityPhoto,%@", [activityPhoto valueForKey:kPAPobjectIDKey]);
    //NSLog(@"pageIndex,%lu", indexPath.row);
    
    if (activityPhoto)
    {
        //will be used by Post when invoked
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gPreferredCircle = activityCircle;

        HomePhotoDetailsViewController *photoDetailsViewController = [[HomePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
        photoDetailsViewController.sortedCircleActivities = self.sortedUserActivities;
        photoDetailsViewController.pageCircle = activityCircle;
        photoDetailsViewController.pageIndex = self.pageIndex;
        photoDetailsViewController.photoIndex = indexPath.row;
        photoDetailsViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.pushPayload = Nil;
        self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
        [self.navigationController pushViewController:photoDetailsViewController animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 81.0;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void)didTapOnPhotoAction:(UIButton*) sender {
    PFObject *userActivity = [self.sortedUserActivities objectAtIndex:sender.tag];
    PFObject *activityPhoto = [userActivity objectForKey:kPAPActivityPhotoKey];
    PFObject *activityCircle = [userActivity objectForKey:kPAPActivityCircleKey];
    
    //NSLog (@"didTapOnPhotoAction");
    //NSLog(@"activityPhoto,%@", [activityPhoto valueForKey:kPAPobjectIDKey]);
    //NSLog(@"pageIndex,%lu", sender.tag);
    
    if (activityPhoto)
    {
        //will be used by Post when invoked
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gPreferredCircle = activityCircle;

        HomePhotoDetailsViewController *photoDetailsViewController = [[HomePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
        photoDetailsViewController.sortedCircleActivities = self.sortedUserActivities;
        photoDetailsViewController.pageCircle = activityCircle;
        photoDetailsViewController.pageIndex = self.pageIndex;
        photoDetailsViewController.photoIndex = sender.tag;
        photoDetailsViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
        [self.navigationController pushViewController:photoDetailsViewController animated:YES];
    }
}

@end
