//
//  AddCirclesViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "AddCirclesViewController.h"
#import "CustomCellBackground.h"

@interface AddCirclesViewController () {
    UITextField *addCircleTextField;
}

@property (nonatomic) NSArray *sortedCircleNames;
@property (nonatomic, strong) PFFile *profilePictureFile;
@property (nonatomic, strong) PFFile *profileThumbnailFile;


@end

@implementation AddCirclesViewController

@synthesize callingController, sortedCircleNames, circlesTableView, delegate, selectedUser,profilePictureFile,profileThumbnailFile;

- (void)viewDidLoad
{
    [super viewDidLoad];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.navigationItem.title=@"ADD TO CIRCLE";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    
    self.circlesTableView.frame = CGRectMake(2.0f, 60.0f, self.view.frame.size.width - 4.0f, self.view.frame.size.height);
    [self.circlesTableView setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    [self.circlesTableView.superview setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];
    sortedCircleNames = [NSArray array];
    sortedCircleNames = [TellemUtility getAvailableCirclesToJoinWithOwner:user andMemberUser:[self selectedUser]];
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
        return 30.0f;
    }
    return 40.0f;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.callingController isEqualToString:@"PostViewController"]) {
        if (section == 1) {
            return @"Post to your circles";
        } else {
            return @"Post to a new circle";
        }
    } else {
        if (section == 1) {
            return @"Add to your circles";
        } else {
            return @"Add to a new circle";
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    if (section == 1) {
        sectionLabel.frame = CGRectMake(15, 3, 180, 20);
    } else {
        sectionLabel.frame = CGRectMake(15, 8, 180, 20);
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
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    /* START NEW
     if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
     cell.backgroundView = [[CustomCellBackground alloc] init];
     }
     
     if (![cell.selectedBackgroundView isKindOfClass:[CustomCellBackground class]]) {
     cell.selectedBackgroundView = [[CustomCellBackground alloc] init];
     }
     */
    //END NEW
    if (indexPath.section == 1) {
        PFObject *selectedCircle = [self.sortedCircleNames objectAtIndex:indexPath.row];
        cell.textLabel.font  =  [UIFont fontWithName:kFontThin size:14];
        NSString *cellTextName = [selectedCircle valueForKey:kPAPCircleNameKey];
        cell.textLabel.text  = [@"      " stringByAppendingString:cellTextName];
        TellemButton *selectCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Select"];
        [selectCircleButton addTarget:self action:@selector(inviteFBFriendToCircle:) forControlEvents:UIControlEventTouchUpInside];
        selectCircleButton.tag=indexPath.row;
        [cell addSubview:selectCircleButton];
        
        PFFile *thumbnailPhoto = [selectedCircle objectForKey:kPAPCircleProfileThumbnail];
        PAPProfileImageView *circlePicture = [[PAPProfileImageView alloc] init];
        [circlePicture setFrame:CGRectMake( 4.0f, 10.0f, 25.0f, 25.0f)];
        [circlePicture setFile:thumbnailPhoto];
        [cell addSubview:circlePicture];
    } else {
        addCircleTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 8, 180, 25)];
        addCircleTextField.placeholder=@"Enter new circle name";
        addCircleTextField.font =  [UIFont fontWithName:kFontNormal size:14];
        addCircleTextField.borderStyle  = UITextBorderStyleRoundedRect;
        addCircleTextField.delegate = self;
        [cell addSubview:addCircleTextField];
        TellemButton *addCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Create"];
        [addCircleButton addTarget:self action:@selector(inviteFBFriendToCircle:) forControlEvents:UIControlEventTouchUpInside];
        addCircleButton.tag=-1;
        [cell addSubview:addCircleButton];
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
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

-(void)inviteFBFriendToCircle:(UIButton *)selectedButton {
    NSString *userName = [[PFUser currentUser] valueForKey:kPAPUserDisplayNameKey];
    if ([userName isEqual:@"Guest"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Sorry, guests are not allowed to invite" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if ([self.selectedUser isEqual:@"Guest"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Sorry, you cannot invite guests" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSArray *selectedCircle = [NSArray array];
    NSString *selectedCircleName;
    PFUser *user = [PFUser currentUser];
    PFACL *circleACL = [PFACL ACLWithUser:user];
    [circleACL setPublicReadAccess:YES];
    [circleACL setWriteAccess:YES forUser:[self selectedUser]];
    
    if (selectedButton.tag == -1) {
        selectedCircleName = [addCircleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (selectedCircleName.length == 0)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Circle name cannot be empty" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            return;
        }

        if ([TellemUtility isCircleNameAvailableForOwner:user andCircleName:selectedCircleName]) {
            //Create a new circle membership
            PFObject *circle = [PFObject objectWithClassName:kPAPCircleClassKey];
            [circle setObject:user forKey:kPAPCircleOwnerUserIdKey];
            [circle setObject:@"Active" forKey:kPAPCircleStatusKey];
            [circle setObject:selectedCircleName forKey:kPAPCircleNameKey];
            NSMutableArray *memberArray = [NSMutableArray array];
            [memberArray addObject:[user username]];
            [memberArray addObject:[[self selectedUser] username]];
            [circle setObject:memberArray forKey:kPAPCircleMemberUserIdArray];
            
            UIImage *defaultImg=[UIImage imageNamed:@"lock.png"];
            NSData *imageData = UIImageJPEGRepresentation(defaultImg, 0.8f);
            NSData *thumbnailImageData = UIImagePNGRepresentation(defaultImg);
            self.profilePictureFile = [PFFile fileWithData:imageData];
            self.profileThumbnailFile = [PFFile fileWithData:thumbnailImageData];
            [circle setObject:self.profilePictureFile forKey:kPAPCircleProfilePicture];
            [circle setObject:self.profileThumbnailFile forKey:kPAPCircleProfileThumbnail];
            circle.ACL = circleACL;
            [circle save];
            NSMutableArray *receivingUserArray = [NSMutableArray arrayWithObject:[self selectedUser][kPAPUserUserNameKey]];
            NSString *message = [NSString stringWithFormat:@"%@ added you to a circle!", user[kPAPUserDisplayNameKey]];
            NSArray *payLoadOne = [NSArray array];
            NSArray *payLoadTwo = [NSArray array];
            payLoadOne = [NSArray arrayWithObjects:@"circle", kPAPobjectIDKey, circle,nil];
            payLoadTwo = @[@"circle", @"pageIndex", [NSString stringWithFormat:@"%tu", 0]];
            NSArray *payLoad = [NSArray arrayWithObjects:payLoadOne, payLoadTwo,kPAPPushInviteToCircle,nil];
            [TellemUtility sendMessageToManyUsers:receivingUserArray withCircleName:selectedCircleName andSendingUser:user andMessage:message andMessageType:kPAPPushInviteToCircle andPayload:payLoad];
            NSString *strFromInt = [NSString stringWithFormat:@"%lu",(unsigned long)receivingUserArray.count];
            NSString *notifyMsg = [@"Sending notifications to " stringByAppendingString:strFromInt];
            notifyMsg = [notifyMsg stringByAppendingString:@" members"];
            NSString *msgInfo = @"Msg is none";
            [TellemUtility tellemLog:notifyMsg andMsgInfo:[NSArray arrayWithObjects:msgInfo,receivingUserArray,nil]];
            NSString *alertMsg = [[self selectedUser][kPAPUserDisplayNameKey] stringByAppendingString: @" added to \""];
            alertMsg = [alertMsg stringByAppendingString: selectedCircleName];
            alertMsg = [alertMsg stringByAppendingString: @"\""];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            
            [self.delegate receiveCirclesData:selectedCircleName];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSString *alertMsg = [@"The circle \"" stringByAppendingString:[selectedCircleName stringByAppendingString: @"\" already exists. "]];
            alertMsg = [alertMsg stringByAppendingString: @"Please use a different name"];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
    }
    else {
        //Create a new circle membership
        selectedCircle = [self.sortedCircleNames objectAtIndex:selectedButton.tag];
        selectedCircleName = [selectedCircle valueForKey:kPAPCircleNameKey];
        NSString *circleId = [selectedCircle valueForKey:kPAPobjectIDKey];
        PFQuery *query = [PFQuery queryWithClassName:kPAPCircleClassKey];
        PFObject *circle = [query getObjectWithId:circleId];
        NSMutableArray *memberArray = [NSMutableArray array];
        memberArray = [circle valueForKey:kPAPCircleMemberUserIdArray];
        [memberArray addObject:[[self selectedUser] username]];
        [circle setObject:memberArray forKey:kPAPCircleMemberUserIdArray];
        UIImage *defaultImg=[UIImage imageNamed:@"lock.png"];
        NSData *imageData = UIImageJPEGRepresentation(defaultImg, 0.8f);
        NSData *thumbnailImageData = UIImagePNGRepresentation(defaultImg);
        self.profilePictureFile = [PFFile fileWithData:imageData];
        self.profileThumbnailFile = [PFFile fileWithData:thumbnailImageData];
        [circle setObject:self.profilePictureFile forKey:kPAPCircleProfilePicture];
        [circle setObject:self.profileThumbnailFile forKey:kPAPCircleProfileThumbnail];
        circle.ACL = circleACL;
        [circle save];
        NSMutableArray *receivingUserArray = [NSMutableArray arrayWithObject:[self selectedUser][kPAPUserUserNameKey]];
        NSString *message = [NSString stringWithFormat:@"%@ added you to a circle!", user[kPAPUserDisplayNameKey]];
        NSArray *payLoadOne = [NSArray array];
        NSArray *payLoadTwo = [NSArray array];
        payLoadOne = [NSArray arrayWithObjects:@"circle", kPAPobjectIDKey, circle,nil];
        payLoadTwo = @[@"circle", @"pageIndex", [NSString stringWithFormat:@"%tu", 0]];
        NSArray *payLoad = [NSArray arrayWithObjects:payLoadOne, payLoadTwo,kPAPPushInviteToCircle,nil];
        [TellemUtility sendMessageToManyUsers:receivingUserArray withCircleName:selectedCircleName andSendingUser:user andMessage:message andMessageType:kPAPPushInviteToCircle andPayload:payLoad];
        NSString *alertMsg = [[self selectedUser][kPAPUserDisplayNameKey] stringByAppendingString: @" added to \""];
        alertMsg = [alertMsg stringByAppendingString: selectedCircleName];
        alertMsg = [alertMsg stringByAppendingString: @"\""];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        NSString *strFromInt = [NSString stringWithFormat:@"%lu",(unsigned long)receivingUserArray.count];
        NSString *notifyMsg = [@"Sending notifications to " stringByAppendingString:strFromInt];
        notifyMsg = [notifyMsg stringByAppendingString:@" members"];
        NSString *msgInfo = @"Msg is none";
        [TellemUtility tellemLog:notifyMsg andMsgInfo:[NSArray arrayWithObjects:msgInfo,receivingUserArray,nil]];
        [self.delegate receiveCirclesData:selectedCircleName];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}



@end
