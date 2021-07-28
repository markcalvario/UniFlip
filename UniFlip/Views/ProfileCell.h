//
//  ProfileCell.h
//  UniFlip
//
//  Created by mac2492 on 7/27/21.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
- (void) populateProfileCellInWithUser:(User *)user withIndexPath:(NSIndexPath *)indexPath withSearchText:(NSString *)searchText;

@end

NS_ASSUME_NONNULL_END
