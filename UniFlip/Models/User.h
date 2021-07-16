//
//  User.h
//  UniFlip
//
//  Created by mac2492 on 7/15/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : PFUser

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *university;
@property (nonatomic, strong) NSString *biography;
@property (nonatomic) BOOL isReported;
@property (nonatomic, strong) PFFileObject *profilePicture;

@end

NS_ASSUME_NONNULL_END
