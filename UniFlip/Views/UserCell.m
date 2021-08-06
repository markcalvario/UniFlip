//
//  UserCell.m
//  UniFlip
//
//  Created by mac2492 on 8/5/21.
//

#import "UserCell.h"

@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self styleFollowButton:FALSE];
    [self styleProfilePicture];
}
-(void) styleFollowButton:(BOOL) isFollowing{
    CGFloat widthOfButton = self.followButton.layer.frame.size.height/ 2;
    [[self.followButton layer] setCornerRadius: widthOfButton];
    [self.followButton setClipsToBounds:TRUE];
    if (isFollowing){
        [self.followButton setBackgroundColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1]];
        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
    }
    else{
        [self.followButton setBackgroundColor:[UIColor whiteColor]];
        [self.followButton setTitleColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1] forState:UIControlStateNormal];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton.layer setBorderWidth:2];
        [self.followButton.layer setBorderColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1].CGColor];
    }
}

-(void) styleProfilePicture{
    CGFloat widthOfButton = self.profilePicture.layer.frame.size.height/ 2;
    [[self.profilePicture layer] setCornerRadius: widthOfButton];
    [self.profilePicture setClipsToBounds:TRUE];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
