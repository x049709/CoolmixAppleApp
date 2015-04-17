//
//  AddCirclesViewController.h
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
#import "TellemButton.h"


@protocol AddCirclesSendDataProtocol <NSObject>

@optional
-(void)receiveCirclesData:(NSString *)stringData;

@end

@interface AddCirclesViewController : UITableViewController  <UITextFieldDelegate>

@property(nonatomic,assign)id delegate;
@property (strong, nonatomic) IBOutlet UITableView *circlesTableView;
@property (nonatomic) PFUser *selectedUser;
@property (nonatomic) NSString *callingController;

@end
