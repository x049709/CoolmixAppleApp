//
//  TellemButton.h
//  UTellem
//
//  Created by Ed Bayudan on 2/13/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TellemButton : UIButton

@property (nonatomic, assign) NSInteger photoIndex;

- (id)initWithFrame:(CGRect)frame withBackgroundColor:(UIColor*)backgroundColor andTitle:(NSString*)text;

@end