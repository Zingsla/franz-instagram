//
//  PostCell.h
//  franz-instagram
//
//  Created by Jacob Franz on 7/7/20.
//  Copyright © 2020 Jacob Franz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *postUsernameLabel;
@property (strong, nonatomic) Post *post;

@end

NS_ASSUME_NONNULL_END
