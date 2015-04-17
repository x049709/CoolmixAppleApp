//
//  PAPPhotoTimelineViewController.h
//  Tellem
//
//  Created by TheOneTech28 on 11/04/14.
//  Copyright (c) 2014 TheOneTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPPhotoHeaderView.h"
@interface PAPPhotoTimelineViewController : PFQueryTableViewController<PAPPhotoHeaderViewDelegate>
- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;
@end
