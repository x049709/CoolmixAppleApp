//
//  HomeViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 11/04/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPPhotoTimelineViewController.h"
@interface HomeViewController :PAPPhotoTimelineViewController
@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@end
