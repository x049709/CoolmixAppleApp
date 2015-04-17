//
//  CircleTimelineViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "CircleTimelineViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PostSharingViewController.h"
#import "PAPLoadMoreCell.h"
#import "UITableView+DragLoad.h"
#import "DataProvider.h"

@interface CircleTimelineViewController ()<DataProviderDelegate>
{
    UITextField *addCircleTextField;
}

@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic) NSArray *sortedCircleNames;
@property (nonatomic) NSArray *circleUserIds;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property NSUInteger circleActivityCount;;

@end

@implementation CircleTimelineViewController
{
    
}
@synthesize sortedCircleNames,circleUserIds,sortedCircleActivities,circleTableView,titleText, titleLabel,pageCircle,pushPayload;
@synthesize activityImageView,activityUserId,activityInitialComment,circleAvatar;
@synthesize posterNameLabel,postTimestampLabel,postLatestCommentsLabel,timeIntervalFormatter,pageIndex,circleActivityCount;
@synthesize dataProvider = _dataProvider;

- (void)viewDidLoad
{
    //MWLogDebug(@"\nCircleTimelineViewController viewDidLoad started.");
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //NSLog(@"Processing circle:%@", [self titleText]);
    [self getAllCircleActivities];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    tM.gCurrentTab = 4;

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[_circleDataProvider cleanupPagedArray];
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
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.circleActivityCount = [TellemUtility countActivitiesOfCircle:self.pageCircle];
    tM.gActivitiesToShow = MIN(self.circleActivityCount,tM.gMaxActivitiesToShow);
    DataProvider *dataProvider = [DataProvider new];
    //NSLog (@" CircleTimelineViewController about to call setDataProvider");
    [self setDataProvider:dataProvider];

    //sortedCircleActivities = [NSArray array];
    //sortedCircleActivities = [TellemUtility getAlActivitiesOfCircle:[self pageCircle]];
    if (self.pushPayload.count>0) {
        int rowIndex = [TellemUtility pickIndexOfInitialPostOfPictureFromCircleActivities:self.dataProvider.dataObjects andPushPayload:self.pushPayload];
        PFObject *circleActivity = [self.dataProvider.dataObjects objectAtIndex:rowIndex];
        PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
        if (activityPhoto)
        {
            //will be used by Post when invoked
            TellemGlobals *tM = [TellemGlobals globalsManager];
            tM.gPreferredCircle = self.pageCircle;

            CirclePhotoDetailsViewController *photoDetailsViewController = [[CirclePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
            photoDetailsViewController.sortedCircleActivities = self.dataProvider.dataObjects;
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
    [self.netWorkTable reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     if (self.dataProvider.dataObjects.count == 0) {
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
    if (self.dataProvider.dataObjects.count == 0) {
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
    return self.dataProvider.dataObjects.count;
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
    
    UITableViewCell *cell = [UITableViewCell new];

    PFObject *circleActivity = [self.dataProvider.dataObjects objectAtIndex:indexPath.row];
    if ([circleActivity isKindOfClass:[NSNull class]]) {
        return cell;
    }
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
    PFObject *circleActivity = [self.dataProvider.dataObjects objectAtIndex:sender.tag];
    PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
    if (activityPhoto)
    {
        //will be used by Post when invoked
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gPreferredCircle = self.pageCircle;

        CirclePhotoDetailsViewController *photoDetailsViewController = [[CirclePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
        photoDetailsViewController.sortedCircleActivities = self.dataProvider.dataObjects;
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

    PFObject *circleActivity = [self.dataProvider.dataObjects objectAtIndex:indexPath.row];
    PFObject *activityPhoto = [circleActivity objectForKey:kPAPActivityPhotoKey];
    if (activityPhoto)
    {
        //will be used by Post when invoked
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gPreferredCircle = self.pageCircle;

        CirclePhotoDetailsViewController *photoDetailsViewController = [[CirclePhotoDetailsViewController alloc] initWithPhoto:activityPhoto];
        photoDetailsViewController.sortedCircleActivities = self.dataProvider.dataObjects;
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


#pragma mark - Circle data provider
- (void)setDataProvider:(DataProvider *)dataProvider {
    
    if (dataProvider != _dataProvider) {
        _dataProvider = dataProvider;
        _dataProvider.delegate = self;
        _dataProvider.dataLoader = 1;
        _dataProvider.currentCircle = self.pageCircle;
        _dataProvider.shouldLoadAutomatically = YES;
        _dataProvider.automaticPreloadMargin = 5;
        
        if ([self isViewLoaded]) {
            [self.netWorkTable reloadData];
        }
    }
}

#pragma mark - Data controller delegate
- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes {
    
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        if ([self.netWorkTable.indexPathsForVisibleRows containsObject:indexPath]) {
            [indexPathsToReload addObject:indexPath];
        }
    }];
    
    if (indexPathsToReload.count > 0) {
        [self.netWorkTable reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}


@end
