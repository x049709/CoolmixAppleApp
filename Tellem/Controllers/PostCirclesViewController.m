//
//  PostCirclesViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "PostCirclesViewController.h"
#import "CustomCellBackground.h"

@interface PostCirclesViewController () {
    UITextField *addCircleTextField;
}


@end

@implementation PostCirclesViewController

@synthesize callingController, sortedCircleNames, circlesTableView, delegate,selectedCircleFromPostView,circleProfile;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=@"POST TO CIRCLE";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.circlesTableView.frame = CGRectMake(2.0f, 60.0f, self.view.frame.size.width - 4.0f, self.view.frame.size.height);
    [self.circlesTableView setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    [self.circlesTableView.superview setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    
    // START NEW
    /*
    if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
        cell.backgroundView = [[CustomCellBackground alloc] init];
    }
    
    if (![cell.selectedBackgroundView isKindOfClass:[CustomCellBackground class]]) {
        cell.selectedBackgroundView = [[CustomCellBackground alloc] init];
    }
    // END NEW
    */
    if (indexPath.section == 1) {
        cell.textLabel.font  =  [UIFont fontWithName:kFontThin size:14];
        PFObject *selectedCircle = [self.sortedCircleNames objectAtIndex:indexPath.row];
        NSString *cellTextName = [selectedCircle valueForKey:kPAPCircleNameKey];
        cell.textLabel.text  = [@"      " stringByAppendingString:cellTextName];
        TellemButton *selectCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Select"];
        [selectCircleButton addTarget:self action:@selector(selectOrAddCircle:) forControlEvents:UIControlEventTouchUpInside];
        selectCircleButton.tag=indexPath.row;
        [cell addSubview:selectCircleButton];
                
        PFFile *thumbnailPhoto = [selectedCircle objectForKey:kPAPCircleProfileThumbnail];
        PAPProfileImageView *circlePicture = [[PAPProfileImageView alloc] init];
        [circlePicture setFrame:CGRectMake( 4.0f, 10.0f, 25.0f, 25.0f)];
        [circlePicture setFile:thumbnailPhoto];
        [cell addSubview:circlePicture];
    } else {
        addCircleTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 8, 180, 25)];
        addCircleTextField.placeholder = @"Enter new circle name";
        addCircleTextField.font =  [UIFont fontWithName:kFontNormal size:14];
        addCircleTextField.borderStyle  = UITextBorderStyleRoundedRect;
        addCircleTextField.delegate = self;
        [cell addSubview:addCircleTextField];

        TellemButton *addCircleButton=[[TellemButton alloc]initWithFrame:CGRectMake(230, 8, 70, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Create"];
        [addCircleButton addTarget:self action:@selector(selectOrAddCircle:) forControlEvents:UIControlEventTouchUpInside];
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

-(void)selectOrAddCircle:(UIButton *)selectedButton {
    if (selectedButton.tag == -1) {
        //User opted to add a new circle, check if available
        self.selectedCircleFromPostView.circleType = kPAPCircleIsNewFromPostCirclesView;
        [self.selectedCircleFromPostView setNewCircleImage:[UIImage imageNamed:@"lock.png"]];
        NSString *trimmedCircleName = [addCircleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self.selectedCircleFromPostView setNewCircleName:trimmedCircleName];
        if (self.selectedCircleFromPostView.circleName.length == 0)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Circle name cannot be empty" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            return;
        }
        PFUser *user = [PFUser currentUser];
        if ([TellemUtility isCircleNameAvailableForOwner:user andCircleName:self.selectedCircleFromPostView.circleName]) {
            NSMutableArray *resultsArray = [NSMutableArray array];
            [resultsArray addObject:selectedCircleFromPostView];
            [resultsArray addObject:[NSArray array]];
            [self.delegate receiveCirclesArrayData:resultsArray];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSString *alertMsg = [@"The circle \"" stringByAppendingString:[self.selectedCircleFromPostView.circleName stringByAppendingString: @"\" already exists. "]];
            alertMsg = [alertMsg stringByAppendingString: @"Please use a different name"];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
    } else {
        //User picked an existing circle, return with it
        NSString *trimmedCircleName = [[self.sortedCircleNames objectAtIndex:selectedButton.tag] valueForKey:kPAPCircleNameKey];
        [self.selectedCircleFromPostView setNewCircleName:trimmedCircleName];
        self.selectedCircleFromPostView.circleType = kPAPCircleIsNotNewFromPostCirclesView;
        NSMutableArray *resultsArray = [NSMutableArray array];
        [resultsArray addObject:selectedCircleFromPostView];
        [resultsArray addObject:[self.sortedCircleNames objectAtIndex:selectedButton.tag]];
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
