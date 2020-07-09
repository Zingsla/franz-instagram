//
//  FeedViewController.m
//  franz-instagram
//
//  Created by Jacob Franz on 7/6/20.
//  Copyright © 2020 Jacob Franz. All rights reserved.
//

#import "FeedViewController.h"
#import "DetailsViewController.h"
#import "InfiniteScrollActivityView.h"
#import "LoginViewController.h"
#import "PostCell.h"
#import "SceneDelegate.h"
#import <Parse/Parse.h>

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) InfiniteScrollActivityView *loadingMoreView;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = YES;
    [self.tableView addSubview:self.loadingMoreView];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
    
    [self fetchPosts];
}

- (void)fetchPosts {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = [NSMutableArray arrayWithArray:posts];
            NSLog(@"Successfully fetched posts from database!");
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"Error fetching posts: %@", error.localizedDescription);
        }
    }];
}

- (void)fetchMorePosts {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.skip = self.posts.count;
    postQuery.limit = 20;
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = [NSMutableArray arrayWithArray:[self.posts arrayByAddingObjectsFromArray:posts]];
            NSLog(@"Successfully fetched more posts from database!");
            [self.tableView reloadData];
            [self.loadingMoreView stopAnimating];
            self.isMoreDataLoading = false;
        } else {
            NSLog(@"Error fetching more posts: %@", error.localizedDescription);
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading) {
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        if (scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = YES;
            
            CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.contentSize.width, InfiniteScrollActivityView.defaultHeight);
            self.loadingMoreView.frame = frame;
            [self.loadingMoreView startAnimating];
            
            [self fetchMorePosts];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FeedDetailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[indexPath.row];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.post = post;
    }
}

@end
