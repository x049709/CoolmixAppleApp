//
//  CirclesPageContentController.m
//  Tellem
//
//  Created by Ed Bayudan on 24/11/13.
//  Copyright (c) 2013 Tellem. All rights reserved.
//

#import "CirclesPageContentController.h"
#import "CustomCellBackground.h"
#import "TellemUtility.h"

@interface CirclesPageContentController () {
    UITextField *addCircleTextField;
}

@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic) NSArray *sortedCircleNames;

@end

@implementation CirclesPageContentController

@synthesize sortedCircleNames, circleTableView, titleText, titleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = [[@" Circle name: \"" stringByAppendingString: [self titleText]] stringByAppendingString:@"\""];
    self.titleLabel.font = [UIFont fontWithName:kFontThin size:22];
    self.titleLabel.textColor = [UIColor redColor];
    self.navigationItem.title=[@"CIRCLES" stringByAppendingString:titleText];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    //[self.circleTableView setBackgroundColor:[UIColor lightGrayColor]];

    PFUser *user = [PFUser currentUser];
    PFQuery *query=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [query whereKey:kPAPCircleOwnerUserIdKey equalTo: user[@"username"]];
    NSArray *userCircles = [NSArray array];
    NSMutableArray *userCircleNames = [NSMutableArray array];
    NSCountedSet *countedCircleNames = [[NSCountedSet alloc] init];
    NSMutableArray *countedCircleNameArray = [NSMutableArray array];
    sortedCircleNames = [NSArray array];
    userCircles = [query findObjects];
    
    if (userCircles) {
        userCircleNames=[userCircles valueForKey:kPAPCircleNameKey];
        countedCircleNames = [NSCountedSet setWithArray:userCircleNames];
        [countedCircleNames enumerateObjectsUsingBlock:^(id circleName, BOOL *stop) {
            [countedCircleNameArray addObject:@{@"circleName": circleName,
                                                @"circleNameCount": @([countedCircleNames countForObject:circleName])}];
            sortedCircleNames = [countedCircleNameArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"circleName" ascending:YES]]];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.titleLabel.text = [@"       " stringByAppendingString:[self titleText]];
    //self.view.frame = CGRectMake(2.0f, 4.0f, self.view.frame.size.width - 4.0f, self.view.frame.size.height);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    [self.view.superview setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    self.titleLabel.textColor = [UIColor redColor];
    self.titleLabel.font = [UIFont fontWithName:kFontNormal size:17];
    self.circleTableView.clipsToBounds=NO;
    self.circleTableView.separatorColor=[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight];
    //self.circleTableView.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);
    //Add circle avatar
    UIButton *circlePicture = [UIButton buttonWithType:UIButtonTypeCustom];
    [circlePicture setFrame:CGRectMake( 2.0f, 4.0f, 30.0f, 30.0f)];
    [circlePicture setBackgroundImage:[UIImage imageNamed:@"private.png"] forState:UIControlStateNormal];
    [self.titleLabel addSubview:circlePicture];
    
}


- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile",
                                  @"Settings",@"Log out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.sortedCircleNames.count;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] init];
    UILabel *sectionLabel = [[UILabel alloc] init];
    //sectionLabel.frame = CGRectMake(15, 5, self.view.frame.size.width, 35);
    sectionLabel.font = [UIFont fontWithName:kFontNormal size:14];
    sectionLabel.textColor = [UIColor redColor];
    //sectionLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    sectionLabel.text = @"";
    [headerView addSubview:sectionLabel];
    return headerView;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString * CellIdentifier = @"CircleCell";
    //UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell * cell = [[UITableViewCell alloc] init];

    /*
    // START NEW
    if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
        cell.backgroundView = [[CustomCellBackground alloc] init];
    }
    
    if (![cell.selectedBackgroundView isKindOfClass:[CustomCellBackground class]]) {
        cell.selectedBackgroundView = [[CustomCellBackground alloc] init];
    }
    // END NEW
    */
    
    cell.textLabel.font  =  [UIFont fontWithName:kFontThin size:14];
    NSString *cellTextName = [[self.sortedCircleNames objectAtIndex:indexPath.row] valueForKey:@"circleName"];
    NSNumber *cellTextPreCount = [[self.sortedCircleNames objectAtIndex:indexPath.row] valueForKey:@"circleNameCount"];
    NSNumber *cellTextCount = [NSNumber numberWithInt:[cellTextPreCount intValue] + 1];
    NSString *cellText = [@"\" " stringByAppendingString:cellTextName];
    cellText = [cellText stringByAppendingString:@"\" ("];
    cellText = [cellText stringByAppendingString:[NSString stringWithFormat:@"%3@", cellTextCount]];
    cellText = [cellText stringByAppendingString:@" members)"];
    cell.textLabel.text  = cellText;
    UIButton *selectCircleButton=[[UIButton alloc]initWithFrame:CGRectMake(235, 10, 80, 20)];
    [selectCircleButton setTitle:@"Select" forState:UIControlStateNormal];
    selectCircleButton.titleLabel.font = [UIFont fontWithName:kFontThin size:14];
    [selectCircleButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [selectCircleButton addTarget:self action:@selector(inviteFBFriendToCircle:) forControlEvents:UIControlEventTouchUpInside];
    selectCircleButton.tag=indexPath.row;
    [cell addSubview:selectCircleButton];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}


-(void)inviteFBFriendToCircle:(UIButton *)selectedButton {
    //NSLog(@"inviteFBFriendToCircle WRONG WAY TO SEND PUSH - INSECURE!");
    NSString *selectedCircleName;
    if (selectedButton.tag == -1) {
        selectedCircleName = addCircleTextField.text;
    } else {
        selectedCircleName = [[self.sortedCircleNames objectAtIndex:selectedButton.tag] valueForKey:@"circleName"];
    }
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" equalTo: [self selectFBUserid]];
    PFUser *user = [PFUser currentUser];
    PFObject *circle = [PFObject objectWithClassName:kPAPCircleClassKey];
    [circle setObject:user[@"username"] forKey:kPAPCircleOwnerUserIdKey];
    [circle setObject:[self selectFBUserid] forKey:kPAPCircleMemberUserIdKey];
    [circle setObject:selectedCircleName forKey:kPAPCircleNameKey];
    [circle setObject:@"Inactive" forKey:kPAPCircleStatusKey];
    PFACL *ACL = [PFACL ACLWithUser:user];
    [ACL setPublicReadAccess:YES];
    PFUser *selectedUser = [TellemUtility getPFUserWithUserId:[self selectFBUserid]];
    [ACL setWriteAccess:YES forUser:selectedUser];
    circle.ACL = ACL;
    [circle save];
    
    
    NSString *message = [NSString stringWithFormat:@"%@ added you to a circle!", user[@"displayName"]];
    NSUInteger limit = 1000;
    PFQuery *query=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [query whereKey:kPAPCircleNameKey equalTo: selectedCircleName];
    [query whereKey:kPAPCircleOwnerUserIdKey equalTo: user[@"username"]];
    [query setLimit: limit];
    NSArray *circleMembers = [[NSArray alloc] init];
    circleMembers = [query findObjects];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:@{
                    @"alert": message,
                    @"badge": @1,
                    @"sound": @"cheering.caf",
                    @"circle": selectedCircleName,
                    @"owner": user[@"username"],
                    @"member": circleMembers
                    }];
    [push sendPushInBackground];
    
    NSString *alertMsg = [[self selectFBUserName] stringByAppendingString: @" added to \""];
    alertMsg = [alertMsg stringByAppendingString: selectedCircleName];
    alertMsg = [alertMsg stringByAppendingString: @"\""];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
