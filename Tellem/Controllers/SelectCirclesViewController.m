//
//  SelectCirclesViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "SelectCirclesViewController.h"
#import "CustomCellBackground.h"

@interface SelectCirclesViewController () {
    UITextField *addCircleTextField;
}

@property (nonatomic, strong) PFFile *profilePictureFile;
@property (nonatomic, strong) PFFile *profileThumbnailFile;
@property (atomic, strong) Circle *allCircle;
@property (nonatomic, strong) PFObject *pageCircle;



@end

@implementation SelectCirclesViewController

@synthesize sortedCircles,selectedCircleFromSender,allCircle, pageCircle, circlesTableView, delegate, selectedUser,profilePictureFile,profileThumbnailFile;

- (void)viewDidLoad
{
    [super viewDidLoad];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.navigationItem.title=@"SELECT CIRCLE";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    
    self.circlesTableView.frame = CGRectMake(2.0f, 60.0f, self.view.frame.size.width - 4.0f, self.view.frame.size.height);
    [self.circlesTableView setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    [self.circlesTableView.superview setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    self.allCircle = [[Circle alloc] initWithImage:[UIImage imageNamed:@"allcircles.png"]  andLabelFrame:CGRectMake(0, 0, self.view.frame.size.width - 120, 40)];
    [self.allCircle setNewCircleName:@"All circles"];
    self.allCircle.circleType = kPAPCircleSelectedIsAllCircles;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
        return self.sortedCircles.count;
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
        return @" ";
    } else {
        return @"Select circle to map";
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
    if (indexPath.section == 1) {
        PFObject *selectedCircle = [self.sortedCircles objectAtIndex:indexPath.row];
        cell.textLabel.font  =  [UIFont fontWithName:kFontThin size:14];
        NSString *cellTextName = [selectedCircle valueForKey:kPAPCircleNameKey];
        cell.textLabel.text  = [@"      " stringByAppendingString:cellTextName];
        TellemButton *selectCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Select"];
        [selectCircleButton addTarget:self action:@selector(returnCircleSelected:) forControlEvents:UIControlEventTouchUpInside];
        selectCircleButton.tag=indexPath.row;
        [cell addSubview:selectCircleButton];
        
        PFFile *thumbnailPhoto = [selectedCircle objectForKey:kPAPCircleProfileThumbnail];
        PAPProfileImageView *circlePicture = [[PAPProfileImageView alloc] init];
        [circlePicture setFrame:CGRectMake( 4.0f, 10.0f, 25.0f, 25.0f)];
        [circlePicture setFile:thumbnailPhoto];
        [cell addSubview:circlePicture];
    } else {
        [cell addSubview:self.allCircle.circleLabel];
        cell.textLabel.font  =  [UIFont fontWithName:kFontThin size:14];
        TellemButton *selectCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Select"];
        [selectCircleButton addTarget:self action:@selector(returnCircleSelected:) forControlEvents:UIControlEventTouchUpInside];
        selectCircleButton.tag=-1;
        [cell addSubview:selectCircleButton];
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

-(void)returnCircleSelected:(UIButton *)selectedButton {
    
    if (selectedButton.tag == -1)
    {
        self.selectedCircleFromSender.circleType = kPAPCircleSelectedIsAllCircles;
        NSMutableArray *resultsArray = [NSMutableArray array];
        [self.selectedCircleFromSender setNewCircleName:@"All circles"];
        [self.selectedCircleFromSender setNewCircleImage:[UIImage imageNamed:@"allcircles.png"]];
        [resultsArray addObject:self.selectedCircleFromSender];
        [resultsArray addObject:[NSArray array]];
        [self.delegate receiveCirclesArrayData:resultsArray];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        self.pageCircle = [self.sortedCircles objectAtIndex:selectedButton.tag];
        self.selectedCircleFromSender.circleType = kPAPCircleIsNotNewFromPostCirclesView;
        [self.selectedCircleFromSender setNewCircleName:[self.pageCircle valueForKey:kPAPCircleNameKey]];
        PFFile *profilePhoto = [PFFile alloc];
        profilePhoto = [self.pageCircle objectForKey:kPAPCircleProfilePicture];
        
        NSData *profilePhotoData = [profilePhoto getData];
        UIImage * profileImage = [[UIImage alloc] init];
        profileImage = [UIImage imageWithData:profilePhotoData];
        [self.selectedCircleFromSender setNewCircleImage:profileImage];
        NSMutableArray *resultsArray = [NSMutableArray array];
        [resultsArray addObject:self.selectedCircleFromSender];
        [resultsArray addObject:self.pageCircle];
        [self.delegate receiveCirclesArrayData:resultsArray];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}



@end
