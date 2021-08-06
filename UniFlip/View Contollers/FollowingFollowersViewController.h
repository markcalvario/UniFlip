//
//  FollowingFollowersViewController.h
//  UniFlip
//
//  Created by mac2492 on 8/4/21.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface FollowingFollowersViewController : UIViewController
@property (strong, nonatomic) User *userOfProfileToView;
@property (nonatomic) BOOL isInitialiallyViewingFollowers;

@end

NS_ASSUME_NONNULL_END
