//
//  PAPProfileImageView.h
//  Anypic
//
//  Created by prateek sahrma on 17/12/2014 .17/12.
//

@class PFImageView;
@interface PAPProfileImageView : UIView

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) PFImageView *profileImageView;

- (void)setFile:(PFFile *)file;

@end
