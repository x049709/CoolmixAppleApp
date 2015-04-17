//
//  CoolTableViewController.h
//  CoolTable
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPUtility.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"

@interface CirclesViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *circlesTableView;
@property (nonatomic) NSString *selectFBUserid;
@property (nonatomic) NSString *selectFBUserName;
@property NSUInteger pageIndex;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
