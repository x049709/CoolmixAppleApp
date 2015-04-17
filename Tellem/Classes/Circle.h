//
//  Circle.h
//  Tellem
//
//  Created by Ed Bayudan on 1/31/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAPUtility.h"

@interface Circle : NSObject

@property  (strong, nonatomic) UILabel* circleLabel;
@property  (strong, nonatomic) UILabel* nameLabel;
@property  (strong, nonatomic) NSString* circleName;
@property  (strong, nonatomic) NSString* circleType;
@property  (strong, nonatomic) PFObject* pfCircle;
@property  (strong, nonatomic) UIImage* circleImage;
@property  (strong, nonatomic) UIButton* circleButton;

- (id)initWithImage: (UIImage*) buttonImage andLabelFrame: (CGRect) cgRect;
- (void) setNewCircleImage: (UIImage*) inCircleImage;
- (void) setNewCircleName:(NSString *)inCircleName;
- (void) setNewCircleImageFromPFFile: (PFFile*) inCirclePFFile;

@end