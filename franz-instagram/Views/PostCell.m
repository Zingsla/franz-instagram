//
//  PostCell.m
//  franz-instagram
//
//  Created by Jacob Franz on 7/7/20.
//  Copyright © 2020 Jacob Franz. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setPost:(Post *)post {
    _post = post;
    self.postImageView.file = post.image;
    [self.postImageView loadInBackground];
    self.postCaptionLabel.text = post.caption;
    self.postUsernameLabel.text = post.author.username;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
