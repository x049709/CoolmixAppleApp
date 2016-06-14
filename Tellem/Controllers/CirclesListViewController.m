//
//  CirclesListViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "CirclesListViewController.h"
#import "CustomCellBackground.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "DataProvider.h"
#import "TellemButton.h"

@interface CirclesListViewController ()<DataProviderDelegate> {
    UITextField *addCircleTextField;
}

@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) PFFile *profilePictureFile;
@property (nonatomic, strong) PFFile *profileThumbnailFile;
@property NSUInteger circleCount;


@end


@implementation CirclesListViewController

@synthesize callingController, circlesTableView, delegate,circleType,circleName,circleProfile,settingsActionSheetDelegate,pushPayload,profilePictureFile,profileThumbnailFile,circleCount;
@synthesize dataProvider = _dataProvider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.navigationItem.title=@"CIRCLES";
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];

    self.circlesTableView.frame = CGRectMake(2.0f, 60.0f, self.view.frame.size.width - 4.0f, self.view.frame.size.height);
    [self.circlesTableView setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    [self.circlesTableView.superview setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    tM.gCurrentTab = 4;
    [self getAllCirclesOfUser];
    
}

- (void)getAllCirclesOfUser
{
    PFUser *user = [PFUser currentUser];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.circleCount = [TellemUtility countAllCirclesOfUser:user];
    tM.gActivitiesToShow = MIN(self.circleCount,tM.gMaxActivitiesToShow);
    DataProvider *dataProvider = [DataProvider new];
    //NSLog (@" CircleLIstViewController about to call setDataProvider");
    [self setDataProvider:dataProvider];

    //sortedCircleNames = [NSArray array];
    //sortedCircleNames = [TellemUtility getAllCirclesOfUser:user];
    //[self.circlesTableView reloadData];
    if ([self.pushPayload count] != 0) {
        [self routeCirclePostWithPayloads];
    }
}


- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile",@"Settings",@"Log out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.dataProvider.dataObjects.count;
   } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 30.0f;
    }
    return 40.0f;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        if (self.dataProvider.dataObjects.count > 0) {
            return @"Tap circle to view/update";
        } else {
            return @"";
        }
    } else {
        return @"Add a new circle";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    if (section == 1) {
        sectionLabel.frame = CGRectMake(15, 3, 200, 20);
    } else {
        sectionLabel.frame = CGRectMake(15, 8, 200, 20);
    }
    sectionLabel.font = [UIFont fontWithName:kFontThin size:18];
    sectionLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:sectionLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [self.circlesTableView dequeueReusableCellWithIdentifier:@"CircleCell"];
    UITableViewCell *cell = [UITableViewCell new];

    if (indexPath.section == 1) {
        PFObject *selectedCircle = [self.dataProvider.dataObjects objectAtIndex:indexPath.row];
        if ([selectedCircle isKindOfClass:[NSNull class]]) {
            return cell;
        }
        
        cell.textLabel.font  =  [UIFont fontWithName:kFontThin size:14];
        NSString *cellTextName = [selectedCircle valueForKey:kPAPCircleNameKey];
        cell.textLabel.text  = [@"      " stringByAppendingString:cellTextName];
        
        TellemButton *selectCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Posts"];
        [selectCircleButton addTarget:self action:@selector(cellCirclePostsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        selectCircleButton.photoIndex=indexPath.row;
        [cell addSubview:selectCircleButton];
        
        PFFile *thumbnailPhoto = [selectedCircle objectForKey:kPAPCircleProfileThumbnail];
        PAPProfileImageView *circlePicture = [[PAPProfileImageView alloc] init];
        [circlePicture setFrame:CGRectMake( 4.0f, 10.0f, 25.0f, 25.0f)];
        [circlePicture setFile:thumbnailPhoto];
        [cell addSubview:circlePicture];
        
    } else {
        cell = [[UITableViewCell alloc] init];
        addCircleTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 8, 180, 25)];
        addCircleTextField.placeholder = @"Enter new circle name";
        addCircleTextField.font =  [UIFont fontWithName:kFontNormal size:14];
        addCircleTextField.borderStyle  = UITextBorderStyleRoundedRect;
        addCircleTextField.delegate = self;
        [cell addSubview:addCircleTextField];
        TellemButton *addCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Create"];
        [addCircleButton addTarget:self action:@selector(createCircle:) forControlEvents:UIControlEventTouchUpInside];
        addCircleButton.tag=-1;
        [cell addSubview:addCircleButton];
    }
    
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

-(void)createCircle:(UIButton *)selectedButton {
    NSString *selectedCircleName;
    NSString *selectedCircleType;
    if (selectedButton.tag == -1) {
        //User opted to add a new circle, check if available
        selectedCircleType = @"NEW";
        selectedCircleName = [addCircleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (selectedCircleName.length == 0)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Circle name cannot be empty" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            return;
        }
        [addCircleTextField resignFirstResponder];
        PFUser *user = [PFUser currentUser];
        if ([TellemUtility isCircleNameAvailableForOwner:user andCircleName:selectedCircleName]) {
            //Create a new circle membership
            PFACL *ACL = [PFACL ACLWithUser:user];
            PFObject *circle = [PFObject objectWithClassName:kPAPCircleClassKey];
            [circle setObject:user forKey:kPAPCircleOwnerUserIdKey];
            [circle setObject:@"Active" forKey:kPAPCircleStatusKey];
            [circle setObject:selectedCircleName forKey:kPAPCircleNameKey];
            NSMutableArray *memberArray = [NSMutableArray array];
            [memberArray addObject:[user username]];
            [circle setObject:memberArray forKey:kPAPCircleMemberUserIdArray];
            UIImage *defaultImg=[UIImage imageNamed:@"lock.png"];
            NSData *imageData = UIImageJPEGRepresentation(defaultImg, 0.8f);
            NSData *thumbnailImageData = UIImagePNGRepresentation(defaultImg);
            self.profilePictureFile = [PFFile fileWithData:imageData];
            self.profileThumbnailFile = [PFFile fileWithData:thumbnailImageData];
            [circle setObject:self.profilePictureFile forKey:kPAPCircleProfilePicture];
            [circle setObject:self.profileThumbnailFile forKey:kPAPCircleProfileThumbnail];
            circle.ACL = ACL;
            [circle save];
            NSString *alertMsg = [@"Circle \"" stringByAppendingString:[selectedCircleName stringByAppendingString: @"\" created."]];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            [self viewWillAppear:YES];
            [self.circlesTableView reloadData];
            //[self.navigationController popToRootViewControllerAnimated:YES];
            //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSString *alertMsg = [@"The circle \"" stringByAppendingString:[selectedCircleName stringByAppendingString: @"\" already exists. "]];
            alertMsg = [alertMsg stringByAppendingString: @"Please use a different name"];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
    };
}

-(void)cellCirclePostsButtonTouched:(TellemButton *)selectedButton {
    //NSLog (@"selectedButton, %ldl",(long)selectedButton.photoIndex);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CirclesPageViewController *listCirclesView = (CirclesPageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CirclesPageViewController"];
    listCirclesView.pageIndex = selectedButton.photoIndex;
    listCirclesView.sortedCircles = self.dataProvider.dataObjects;
    listCirclesView.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:listCirclesView animated:YES];
}

-(void)routeCirclePostWithPayloads {
    NSString *msgType = [self.pushPayload objectForKey:@"msgtype"];
    //Comments and posts are now handled by HomeTimelineViewController
    /*
    if ([msgType isEqualToString:kPAPPushCommentOnPost])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CirclesPageViewController *listCirclesView = (CirclesPageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CirclesPageViewController"];
        NSArray *payLoad=[NSArray array];
        payLoad = [self.pushPayload objectForKey:@"payload"];
        int pageIndex = [[[payLoad objectAtIndex:1] objectAtIndex:2] intValue];
        listCirclesView.pageIndex = pageIndex;
        listCirclesView.pushPayload = self.pushPayload;
        listCirclesView.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
        [self.navigationController pushViewController:listCirclesView animated:YES];
    }
    */
    
    if ([msgType isEqualToString:kPAPPushInviteToCircle]) {
        NSArray *payLoad=[NSArray array];
        NSArray *circlePostedTo=[NSArray array];
        payLoad = [self.pushPayload objectForKey:@"payload"];
        circlePostedTo = [[payLoad objectAtIndex:0] objectAtIndex:2];
        NSString *circleKey = [circlePostedTo valueForKey:kPAPobjectIDKey];

        PFObject *pageCircle = [TellemUtility getCircleWithObjectId:circleKey];
        //will be used by Post when invoked
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gPreferredCircle = pageCircle;
        
        NSString *cellTextName = [pageCircle valueForKey:kPAPCircleNameKey];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CircleDetailsViewController *circleDetailsView = (CircleDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CircleDetailsViewController"];
        circleDetailsView.titleText = cellTextName;
        circleDetailsView.pageCircle = pageCircle;
        circleDetailsView.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
        [self.navigationController pushViewController:circleDetailsView animated:YES];
    }
    
    self.pushPayload = Nil;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *pageCircle = [self.dataProvider.dataObjects objectAtIndex:indexPath.row];
    //will be used by Post when invoked
    TellemGlobals *tM = [TellemGlobals globalsManager];
    tM.gPreferredCircle = pageCircle;
    
    NSString *cellTextName = [pageCircle valueForKey:kPAPCircleNameKey];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CircleDetailsViewController *circleDetailsView = (CircleDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CircleDetailsViewController"];
    circleDetailsView.pageCircle = pageCircle;
    circleDetailsView.titleText = cellTextName;
    circleDetailsView.pageIndex = indexPath.row;
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:circleDetailsView animated:YES];
}


#pragma mark - Circle data provider
- (void)setDataProvider:(DataProvider *)dataProvider {
    
    if (dataProvider != _dataProvider) {
        TellemGlobals *tM = [TellemGlobals globalsManager];
        tM.gActivitiesPerPage = 10;
        _dataProvider = dataProvider;
        _dataProvider.delegate = self;
        _dataProvider.dataLoader = 3;
        _dataProvider.circleMember = [PFUser currentUser];
        _dataProvider.shouldLoadAutomatically = YES;
        _dataProvider.automaticPreloadMargin = 5;
        
        if ([self isViewLoaded]) {
            [self.circlesTableView reloadData];
        }
    }
}

#pragma mark - Data controller delegate
- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes {
    
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:1];
        
        if ([self.circlesTableView.indexPathsForVisibleRows containsObject:indexPath]) {
            [indexPathsToReload addObject:indexPath];
        }
    }];
    
    if (indexPathsToReload.count > 0) {
        [self.circlesTableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}



@end
