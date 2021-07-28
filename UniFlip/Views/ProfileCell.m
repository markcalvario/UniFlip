//
//  ProfileCell.m
//  UniFlip
//
//  Created by mac2492 on 7/27/21.
//

#import "ProfileCell.h"

@implementation ProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.profilePic.isAccessibilityElement = YES;
    self.usernameLabel.isAccessibilityElement = YES;
    
    // Initialization code
}
- (void) populateProfileCellInWithUser:(User *)user withIndexPath:(NSIndexPath *)indexPath withSearchText:(NSString *)searchText{
    self.usernameLabel.text = user.username;
    NSRange usernameRange = [user.username rangeOfString:searchText options:NSCaseInsensitiveSearch];
    NSMutableAttributedString *substring = [[NSMutableAttributedString alloc] initWithString:user.username];
    [substring addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:usernameRange];
    self.usernameLabel.attributedText = substring;
    PFFileObject *profilePicFile = user.profilePicture;
    if (!profilePicFile){
        [self.profilePic setImage:[UIImage imageNamed:@"default_profile_pic"]];
    }
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            image ? [self.profilePic setImage:image] : [self.profilePic setImage:[UIImage imageNamed:@"default_profile_pic"]];
        }
    }];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.clipsToBounds = YES;
    
    self.usernameLabel.accessibilityValue = [@"User's username is " stringByAppendingString:user.username];
    self.profilePic.accessibilityValue = [user.username stringByAppendingString:@"'s profile picture"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
