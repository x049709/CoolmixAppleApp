//
//  ZoomViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 29/02/2015.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *photoToZoom;

@end
