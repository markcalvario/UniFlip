//
//  UserCell.h
//  UniFlip
//
//  Created by mac2492 on 8/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

@end

NS_ASSUME_NONNULL_END
