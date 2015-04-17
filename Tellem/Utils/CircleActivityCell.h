//
//  CircleActivityCell.h
//  Tellem
//
//  Created by Ed Bayudan on 5/3/12.
//  Copyright (c) 2013 Tellem. All rights reserved.
//

@class PFImageView;
@interface CircleActivityCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic) UILabel *headerLabel;
@property (nonatomic) BOOL usesDefaultPicture;

@end
