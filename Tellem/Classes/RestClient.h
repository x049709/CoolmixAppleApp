//
//  RestClient.h
//  Tellem
//
//  Created by Ed Bayudan on 1/31/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableURLRequest+BasicAuth.h"

@interface RestClient : NSObject

@property  (strong, nonatomic) UILabel* circleLabel;
@property  (strong, nonatomic) UILabel* nameLabel;
@property  (strong, nonatomic) NSString* circleName;
@property  (strong, nonatomic) NSString* circleType;
@property  (strong, nonatomic) PFObject* pfCircle;
@property  (strong, nonatomic) UIImage* circleImage;
@property  (strong, nonatomic) UIButton* circleButton;

- (void)loginToMix;
- (void)getImageFromMix;
- (void)postToMix;
- (UIImage*)getTestImageFromMix;
- (UIImage*)getImageFromMix: (NSString *) serverURL andServerUser: (NSString*) serverUser andServerPassword: (NSString*) serverPassword andImageFilePath: (NSString *) imageFilePath andImageFileName: (NSString *) imageFileName;

@end