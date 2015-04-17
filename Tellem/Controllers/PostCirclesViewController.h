//
//  PostCirclesViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPUtility.h"
#import "UIImage+ImageEffects.h"
#import "TellemUtility.h"
#import "PAPProfileImageView.h"
#import "Circle.h"
#import "TellemButton.h"


@protocol PostCirclesSendDataProtocol <NSObject>

@optional
-(void)receiveCirclesArrayData:(NSArray *)arrayData;

@end

@interface PostCirclesViewController : UITableViewController  <UITextFieldDelegate>

@property(nonatomic,assign)id delegate;
@property (strong, nonatomic) IBOutlet UITableView *circlesTableView;
@property (nonatomic) NSString *selectFBUserid;
@property (nonatomic) NSString *selectFBUserName;
@property (nonatomic) NSString *callingController;
@property (strong, nonatomic) NSArray *sortedCircleNames;
@property (strong, nonatomic) Circle *selectedCircleFromPostView;
@property (strong, nonatomic) PFObject *circleProfile;

@end
