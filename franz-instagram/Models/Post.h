//
//  Post.h
//  franz-instagram
//
//  Created by Jacob Franz on 7/7/20.
//  Copyright © 2020 Jacob Franz. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>

@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) PFUser *author;

@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) PFFileObject *image;
@property (strong, nonatomic) NSNumber *likeCount;
@property (strong, nonatomic) NSNumber *commentCount;

+ (void)postUserImage:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withCompletion:(PFBooleanResultBlock _Nullable)completion;
+ (PFFileObject *)getPFFileObjectFromImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
