//
//  CircleActivitiesViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "CircleActivitiesViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PostSharingViewController.h"
#import "PAPLoadMoreCell.h"
#import "UITableView+DragLoad.h"

@interface CircleActivitiesViewController () {
    UITextField *addCircleTextField;
}
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic) NSArray *sortedCircleNames;
@property (nonatomic) NSArray *circleUserIds;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

@end

@implementation CircleActivitiesViewController
{
    
}
@synthesize sortedCircleNames,circleUserIds,sortedCircleActivities,circleTableView,titleText, titleLabel,pageCircle,pushPayload;
@synthesize activityImageView,activityUserId,activityInitialComment,circleAvatar;
@synthesize posterNameLabel,postTimestampLabel,postLatestCommentsLabel,timeIntervalFormatter,pageIndex;

- (void)viewDidLoad
{
    //MWLogDebug(@"\nCircleActivitiesViewController viewDidLoad started.");
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getAllCircleActivities];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    
    //Circle name
    self.titleLabel.text = [@"       " stringByAppendingString: [self titleText]];
    self.titleLabel.font = [UIFont fontWithName:kFontNormal size:17.0];
    self.titleLabel.textColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    PFFile *thumbnailPhoto = [self.pageCircle objectForKey:kPAPCircleProfileThumbnail];
    PAPProfileImageView *circlePicture = [[PAPProfileImageView alloc] init];
    [circlePicture setFrame:CGRectMake( 2.0f, 15.0f, 25.0f, 25.0f)];
    [circlePicture setFile:thumbnailPhoto];
    [titleLabel addSubview:circlePicture];
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

-(void)getAllCircleActivities {
    
    //NSLog (@"TODO Needs to relocate to the AppDelegate somewhere after geting PFUser");
    sortedCircleActivities = [NSArray array];
    sortedCircleActivities = [TellemUtility getAlActivitiesOfCircle:[self pageCircle]];
    if (self.pushPayload.count>0) {
        int rowIndex = [TellemUtility pickIndexOfInitialPostOfPictureFromCircleActivities:sortedCircleActivities andPushPayload:self.pushPayload];
        PFObject *circleActivity = [self.sortedCircleActivities objectAtIndex:rowIndex];
        PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
        if (activityPhoto)
        {
            //will be used by Post when invoked
            TellemGlobals *tM = [TellemGlobals globalsManager];
            tM.gPreferredCircle = self.pageCircle;

            CirclePhotoDetailsViewController *photoDetailsViewController = [[CirclePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
            photoDetailsViewController.sortedCircleActivities = self.sortedCircleActivities;
            photoDetailsViewController.pageCircle = self.pageCircle;
            photoDetailsViewController.pageIndex = self.pageIndex;
            photoDetailsViewController.photoIndex = rowIndex;
            photoDetailsViewController.pushPayload = self.pushPayload;
            photoDetailsViewController.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
            self.pushPayload = Nil;
            self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
            [self.navigationController pushViewController:photoDetailsViewController animated:NO];
        }
    }
    //[self.circleTableView reloadRowsAtIndexPaths:[self.circleTableView  indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    [self.circleTableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     if (self.sortedCircleActivities.count == 0) {
         UIView* View = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 20.0)];
         UILabel *label = [[UILabel alloc] init];
         label.frame = CGRectMake(16, 5, 284, 23);
         label.textColor = [UIColor blackColor];
         label.font = [UIFont fontWithName:kFontNormal size:14];
         label.text = @"No posts for this circle";
         label.backgroundColor = [UIColor clearColor];
         [View addSubview:label];
         return View;
     } else {
        UIView* View = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 1.0)];
        return View;
     }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.sortedCircleActivities.count == 0) {
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
    return sortedCircleActivities.count;
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

    PFObject *circleActivity = [self.sortedCircleActivities objectAtIndex:indexPath.row];
    PFObject *activityUser = [circleActivity objectForKey:kPAPActivityToUserKey];
    NSString *activityContent = [circleActivity objectForKey:kPAPActivityContentKey];
    PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
    PFFile *thumbnailPhoto = [activityPhoto objectForKey:kPAPPhotoThumbnailKey];
    
    
    //Post photo
    PAPProfileImageView *activityPicture = [[PAPProfileImageView alloc] init];
    [activityPicture setFrame:CGRectMake(0,0,80,80)];
    [activityPicture.profileButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    activityPicture.profileButton.tag = indexPath.row;
    [activityPicture setFile:thumbnailPhoto];
    [cell addSubview:activityPicture];
    
    //Poster's name
    self.posterNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(90, 5, 200, 18)];
    self.posterNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.posterNameLabel.font = [UIFont fontWithName:kFontNormal size:16];
    self.posterNameLabel.textColor = [UIColor redColor];
    self.posterNameLabel.text = [activityUser objectForKey:kPAPUserDisplayNameKey];
    [cell addSubview:self.posterNameLabel];

    //Post timestamp
    self.postTimestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(90,25,200,14)];
    [self.postTimestampLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
    self.postTimestampLabel.font = [UIFont fontWithName:kFontNormal size:10];
    NSTimeInterval timeInterval = [[circleActivity updatedAt] timeIntervalSinceNow];
    NSString *timestamp = [TellemUtility timeInHumanReadableFormat:timeInterval];
    self.postTimestampLabel.text = timestamp;
    [cell addSubview:self.postTimestampLabel];

    //Post latest comments
    self.postLatestCommentsLabel=[[UILabel alloc]initWithFrame:CGRectMake(90, 38, 200, 50)];
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
    
    return cell;
}

- (void)didTapOnPhotoAction:(UIButton*) sender {
    PFObject *circleActivity = [self.sortedCircleActivities objectAtIndex:sender.tag];
    PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
    if (activityPhoto)
    {
        //will be used by Post when invoked
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gPreferredCircle = self.pageCircle;

        CirclePhotoDetailsViewController *photoDetailsViewController = [[CirclePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
        photoDetailsViewController.sortedCircleActivities = self.sortedCircleActivities;
        photoDetailsViewController.pageCircle = self.pageCircle;
        photoDetailsViewController.pageIndex = self.pageIndex;
        photoDetailsViewController.photoIndex = sender.tag;
        photoDetailsViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.pushPayload = Nil;
        self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
        [self.navigationController pushViewController:photoDetailsViewController animated:NO];
    }
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

    PFObject *circleActivity = [self.sortedCircleActivities objectAtIndex:indexPath.row];
    PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
    if (activityPhoto)
    {
        //will be used by Post when invoked
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gPreferredCircle = self.pageCircle;

        CirclePhotoDetailsViewController *photoDetailsViewController = [[CirclePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
        photoDetailsViewController.sortedCircleActivities = self.sortedCircleActivities;
        photoDetailsViewController.pageCircle = self.pageCircle;
        photoDetailsViewController.pageIndex = self.pageIndex;
        photoDetailsViewController.photoIndex = indexPath.row;
        photoDetailsViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.pushPayload = Nil;
        self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
        [self.navigationController pushViewController:photoDetailsViewController animated:NO];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

@end
