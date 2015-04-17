//
//  CoolTableViewController.m
//  CoolTable
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "CirclesViewController.h"
#import "CustomCellBackground.h"
#import "TellemUtility.h"

@interface CirclesViewController () {
    UITextField *addCircleTextField;
}

@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (copy) NSMutableArray *thingsLearned;
@property (nonatomic) NSArray *sortedCircleNames;

@end

@implementation CirclesViewController

@synthesize sortedCircleNames, circlesTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = @"Circles";
    self.navigationItem.title=@"CIRCLES";
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    [self.circlesTableView setBackgroundColor:[UIColor lightGrayColor]];

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
    
    //[self.circlesTableView setFrame:CGRectMake(2.0f, 2.0f, self.view.frame.size.width - 4, self.view.frame.size.height)];
    [self.view.superview setFrame:CGRectMake(2.0f, 2.0f, self.view.frame.size.width - 4, self.view.frame.size.height)];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.sortedCircleNames.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40.0f;
    }
    return 35.0f;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Add to your circles";
    } else {
        return @"Add to a new circle";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] init];

    UILabel *sectionLabel = [[UILabel alloc] init];
    if (section == 1) {
        sectionLabel.frame = CGRectMake(15, 5, 180, 35);
        sectionLabel.font = [UIFont fontWithName:kFontNormal size:18];
        sectionLabel.textColor = [UIColor redColor];
        sectionLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        [headerView addSubview:sectionLabel];
    } else {
        UISegmentedControl *circleSegments = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Circle One", @"Circle Two", @"Circle Three", nil]];
        [circleSegments setSegmentedControlStyle:UISegmentedControlStyleBar];
        [circleSegments sizeToFit];
        circleSegments.frame = CGRectMake(10, 2, 300, 30);
        [headerView addSubview:circleSegments];
    }
    
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 40.0f;
    } else {
        return 0.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CircleCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    // START NEW
    if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
        cell.backgroundView = [[CustomCellBackground alloc] init];
    }
    
    if (![cell.selectedBackgroundView isKindOfClass:[CustomCellBackground class]]) {
        cell.selectedBackgroundView = [[CustomCellBackground alloc] init];
    }
    // END NEW
    
 
    if (indexPath.section == 1) {
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

        
    } else {
    }

    // NEW
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

    [self.navigationController popViewControllerAnimated:YES];
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}


@end
