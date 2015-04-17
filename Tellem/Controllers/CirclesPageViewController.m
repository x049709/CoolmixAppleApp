//
//  CirclesPageViewController,m
//  Tellem
//
//  Created by Ed Bayudan on 24/11/13.
//  Copyright (c) 2013 Tellem. All rights reserved.
//

#import "CirclesPageViewController.h"

@interface CirclesPageViewController ()

@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;

@end

@implementation CirclesPageViewController

@synthesize sortedCircles, pageTitles, pageIndex, pushPayload;


- (void)viewDidLoad
{
    [super viewDidLoad];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"POSTS";
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Create the data model
    //[self getAllCircles];
    
    if ([self.sortedCircles count] == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"No circles. First add friends to circles using the People tab" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    } else {
        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        NSString *msgType = [self.pushPayload objectForKey:@"msgtype"];
        if ([msgType isEqualToString:kPAPPushCommentOnPost]) {
            if (self.pushPayload.count>0) {
                self.pageIndex = [TellemUtility pickIndexOfCirclePostedToFromListOfCircles:self.sortedCircles andPushPayload:self.pushPayload];
            }
        } else
            if ([msgType isEqualToString:kPAPPushInviteToCircle]) {
                if (self.pushPayload.count>0) {
                    self.pageIndex = [TellemUtility pickIndexOfCircleInvitedToFromListOfCircles:self.sortedCircles andPushPayload:self.pushPayload];
                }
            }
        CircleTimelineViewController *startingViewController = [self viewControllerAtIndex:self.pageIndex];
        startingViewController.pageIndex = self.pageIndex;
        startingViewController.pushPayload = self.pushPayload;
        self.pushPayload = Nil;
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        // Change the size of page view controller
        //self.pageViewController.view.frame = CGRectMake(2.0f, 2.0f, self.view.frame.size.width - 4.0f, self.view.frame.size.height);
        
        [self addChildViewController:[self pageViewController]];
        [self.view addSubview:[self pageViewController].view];
        [self.pageViewController didMoveToParentViewController:self];
    }
}

/*
- (void)getAllCircles
{
    PFUser *user = [PFUser currentUser];
    if (self.sortedCircles.count == 0) {
        self.sortedCircles = [NSArray array];
        self.sortedCircles = [TellemUtility getAllCirclesOfUser:user];
    }
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile",
                                  @"Settings",@"Log out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)startWalkthrough:(id)sender {
    CircleTimelineViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (CircleTimelineViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.sortedCircles count] == 0) || (index >= [self.sortedCircles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CircleTimelineViewController *pageContentViewController = (CircleTimelineViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CircleTimelineViewController"];

    pageContentViewController.titleText = [self.sortedCircles[index] valueForKey:kPAPCircleNameKey];
    pageContentViewController.pageCircle = self.sortedCircles[index];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    tM.gPreferredCircle = pageContentViewController.pageCircle;
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CirclesPageContentController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CircleTimelineViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

-(void) receiveCirclesData:(NSString *)stringData;
{
    //NSLog(@"receiveCirclesData,%@",stringData);
}

@end
