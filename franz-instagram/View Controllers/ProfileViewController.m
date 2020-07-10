//
//  ProfileViewController.m
//  franz-instagram
//
//  Created by Jacob Franz on 7/9/20.
//  Copyright © 2020 Jacob Franz. All rights reserved.
//

#import "ProfileViewController.h"
#import "DetailsViewController.h"
#import "LoginViewController.h"
#import "Post.h"
#import "PostCell.h"
#import "SceneDelegate.h"
#import <Parse/Parse.h>

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) PFUser *user;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [PFUser currentUser];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self loadProfile];
    [self fetchPosts];
}

- (void)loadProfile {
    self.usernameLabel.text = self.user.username;
    
    PFFileObject *profileImage = self.user[@"profileImage"];
    if (profileImage != nil) {
        self.profileImageView.file = self.user[@"profileImage"];
        [self.profileImageView loadInBackground];
    }
}

- (IBAction)didTapEditImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        NSLog(@"Camera unavailable, using photo library instead.");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *editedImage = [self resizeImage:info[UIImagePickerControllerEditedImage] withSize:CGSizeMake(128, 128)];
    
    self.profileImageView.image = editedImage;
    self.user[@"profileImage"] = [Post getPFFileObjectFromImage:editedImage];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error updating profile image: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully updated profile image!");
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchPosts {
    PFQuery *postQuery = [Post query];
    [postQuery whereKey:@"author" equalTo:self.user];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = [NSMutableArray arrayWithArray:posts];
            NSLog(@"Successfully fetched profile posts from database!");
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"Error fetching profile posts: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapLogout:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error logging out: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully logged out!");
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    cell.post = self.posts[indexPath.row];
    return cell;
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProfileDetailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[indexPath.row];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.post = post;
    }
}

@end
