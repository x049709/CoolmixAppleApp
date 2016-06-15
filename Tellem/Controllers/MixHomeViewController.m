//
//  MixHomeViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "MixHomeViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PostSharingViewController.h"
#import "PAPLoadMoreCell.h"
#import "UITableView+DragLoad.h"
#import "MixGSRViewController.h"

@interface MixHomeViewController ()
{
    UITextField *addCircleTextField;
}
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic) NSArray *sortedCircleNames;
@property (nonatomic) NSArray *circleUserIds;
@property (nonatomic) NSArray *sortedUserActivities;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property NSUInteger userActivityCount;


@end

@implementation MixHomeViewController
{
    NSMutableArray *menuList;
}
@synthesize sortedCircleNames,circleUserIds,sortedUserActivities,circleTableView,titleText, titleLabel,pageCircle,pushPayload;
@synthesize activityImageView,activityUserId,activityInitialComment,circleAvatar,netWorkTable;
@synthesize posterNameLabel,postTimestampLabel,postLatestCommentsLabel,timeIntervalFormatter,pageIndex, tM;

- (void)viewDidLoad
{
    //MWLogDebug(@"\nMixHomeViewController viewDidLoad started.");
    [super viewDidLoad];
    self.tM = [TellemGlobals globalsManager];    
    menuList = [NSMutableArray arrayWithObjects:@"custom_gift_circle_more.png",  @"gifting_suggestions.png", @"grocery_exchange.png",@"custom_gift_circle_more.png", @"gifting_suggestions_more.png", @"grocery_exchange_more.png", nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    //MWLogDebug(@"\nMixHomeViewController viewWillAppear started.");
    [super viewWillAppear:animated];
    self.tM.gCurrentTab = 0;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.netWorkTable setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"HOME";
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    //Reset tab bar notification
    MokriyaUITabBarController *tabBarController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] tabBarController];
    if (tabBarController.hasNotifications) {
        tabBarController.hasNotifications = NO;
        [tabBarController customizeTabBar:0];
    }
    
    self.titleLabel.frame=CGRectMake(15.0f, 10.0f, self.view.frame.size.width - 30.0f, 50.0f);
    self.titleLabel.layer.cornerRadius = 0.0;
    self.titleLabel.layer.borderWidth = 1.0;
    self.titleLabel.layer.borderColor = [UIColor clearColor].CGColor;
    self.titleLabel.layer.backgroundColor =[UIColor blackColor].CGColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"COOLMIX";
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.titleLabel setFont:[UIFont fontWithName:kFontBold size:40.0f]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

#pragma mark UItableView DataSource Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuList.count;
}

- (void)finishRefresh
{
}

- (void)dragTableDidTriggerRefresh:(UITableView *)tableView
{
    //send refresh request(generally network request) here
    [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:2];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID= @"MixHomeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *imageName = [menuList objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame= CGRectMake(5.0f, 0.0f, self.netWorkTable.frame.size.width - 10.0, 75.0f);
    [cell addSubview:imageView];

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove separator inset
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
    //MWLogDebug(@"\nMixHomeViewController didSelectRowAtIndexPath started.");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coolmix" bundle: nil];
    MixGSRViewController *mixGSRViewController = [sb instantiateViewControllerWithIdentifier:@"MixGSRViewController"];
    
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:mixGSRViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

@end
