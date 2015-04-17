//
//  CircleActivityCell.m
//  Anypic
//
//  Created by Ed Bayudan on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "CircleActivityCell.h"
#import "PAPUtility.h"
#import "PAPPhotoHeaderView.h"

@implementation CircleActivityCell
@synthesize photoButton,headerLabel,usesDefaultPicture;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.imageView.frame = CGRectMake( 02.0f, 02.0f, 316.0f, 40.0f);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 02.0f, 02.0f, 316.0f, 40.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake( 2.0f, 0.0f, 316.0f, 62.0f)];
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake( 10.0f, 0.0f, 316.0f, 62.0f)];
        [headerLabel setFont:[UIFont fontWithName:kFontNormal size:17.0]];
        [headerLabel setTextColor:[UIColor blackColor]];
        [headerView addSubview:headerLabel];
        [self.contentView addSubview:headerView];
        
        [self.contentView bringSubviewToFront:self.imageView];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    //self.imageView.frame = CGRectMake( 20.0f, 0.0f, 280.0f, 280.0f);
    //self.photoButton.frame = CGRectMake( 20.0f, 0.0f, 280.0f, 280.0f);
    self.imageView.frame = CGRectMake( 02.0f, 02.0f, 316.0f, 40.0f);
    self.photoButton.frame = CGRectMake( 0.0f, 02.0f, 316.0f, 40.0f);

}

@end
