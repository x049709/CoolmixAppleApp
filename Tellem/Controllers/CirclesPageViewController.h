//
//  CirclesPageViewController.h
//  PageViewDemo
//
//  Created by Ed Bayudan on 24/11/13.
//  Copyright (c) 2013 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CirclesPageContentController.h"
#import "CircleTimelineViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "AddCirclesViewController.h"

@interface CirclesPageViewController : UIViewController <UIPageViewControllerDataSource,AddCirclesSendDataProtocol>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property int pageIndex;
@property NSDictionary *pushPayload;
@property (nonatomic) NSArray *sortedCircles;

@end
