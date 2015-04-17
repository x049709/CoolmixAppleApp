//
//  PAPImageView.h
//  Anypic
//
//  Created by prateek sahrma on 17/12/2014 .14/12.
//

@interface PAPImageView : UIImageView

@property (nonatomic, strong) UIImage *placeholderImage;

- (void) setFile:(PFFile *)file;

@end
