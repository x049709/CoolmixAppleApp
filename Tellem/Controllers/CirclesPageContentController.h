//
//  CirclesPageContentController.h
//  Tellem
//
//  Created by Ed Bayudan on 24/11/13.
//  Copyright (c) 2013 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPUtility.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "UIImage+ImageEffects.h"

@interface CirclesPageContentController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *circleTableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property (nonatomic) NSString *selectFBUserid;
@property (nonatomic) NSString *selectFBUserName;

@end
