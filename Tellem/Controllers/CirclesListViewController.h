//
//  CirclesListViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPUtility.h"
#import "UIImage+ImageEffects.h"
#import "TellemUtility.h"
#import "CirclesPageViewController.h"
#import "CircleDetailsViewController.h"
#import "TellemButton.h"
#import "DataReceiver.h"


@protocol CirclesListSendDataProtocol <NSObject>

@optional
-(void)receiveCirclesArrayData:(NSArray *)arrayData;

@end

@interface CirclesListViewController : UITableViewController  <UITextFieldDelegate,DataReceiver>

@property(nonatomic,assign)id delegate;
@property (strong, atomic) IBOutlet UITableView *circlesTableView;
@property (nonatomic) NSString *selectFBUserid;
@property (nonatomic) NSString *selectFBUserName;
@property (nonatomic) NSString *callingController;
//@property (strong, nonatomic) NSArray *sortedCircleNames;
@property (strong, nonatomic) NSString *circleName;
@property (strong, nonatomic) NSString *circleType;
@property (strong, nonatomic) PFObject *circleProfile;
@property NSDictionary *pushPayload;



@end
