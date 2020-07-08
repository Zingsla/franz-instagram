//
//  DetailsViewController.m
//  franz-instagram
//
//  Created by Jacob Franz on 7/8/20.
//  Copyright © 2020 Jacob Franz. All rights reserved.
//

#import "DetailsViewController.h"
@import Parse;

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postImageView.file = self.post.image;
    [self.postImageView loadInBackground];
    self.usernameLabel.text = self.post.author.username;
    self.captionLabel.text = self.post.caption;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
