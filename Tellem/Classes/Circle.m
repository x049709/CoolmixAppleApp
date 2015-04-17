//
//  Circle.m
//  Tellem
//
//  Created by Ed Bayudan on 1/31/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "Circle.h"

@implementation Circle
@synthesize circleLabel;
@synthesize nameLabel;
@synthesize circleName;
@synthesize circleType;
@synthesize pfCircle;
@synthesize circleImage;
@synthesize circleButton;


- (id)initWithImage: (UIImage*) buttonImage andLabelFrame: (CGRect) cgRect
{
    self = [super init];
    if (self) {
        self.circleName = @"New circle";
        self.circleType = kPAPCircleIsNewFromPostView;
        self.circleLabel = [[UILabel alloc] initWithFrame:cgRect];
        self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.circleButton setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        self.circleImage = buttonImage;
        [self.circleButton setBackgroundImage:self.circleImage forState:UIControlStateNormal];
        [self.circleLabel addSubview:circleButton];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 42.0f, 0.0f, self.circleLabel.frame.size.width, 40.0f)];
        self.nameLabel.textColor = [UIColor redColor];
        self.nameLabel.text = self.circleName;
        self.nameLabel.font = [UIFont fontWithName:kFontNormal size:17];
        [self.circleLabel addSubview:self.nameLabel];
        self.circleLabel.userInteractionEnabled = YES;        
    }

    return self;
}

- (void) setNewCircleImage: (UIImage*) inCircleImage
{
    self.circleImage = inCircleImage;
    [self.circleButton setBackgroundImage:self.circleImage forState:UIControlStateNormal];
}

- (void) setNewCircleName:(NSString *)inCircleName
{
    self.circleName = inCircleName;
    self.nameLabel.text = self.circleName;    
}

- (void) setNewCircleImageFromPFFile: (PFFile*) inCirclePFFile
{
    NSData *profilePhotoData = [inCirclePFFile getData];
    UIImage *image = [UIImage imageWithData:profilePhotoData];
    self.circleImage = image;
    [self.circleButton setBackgroundImage:self.circleImage forState:UIControlStateNormal];
}


@end
