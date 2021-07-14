//
//  OptionCell.m
//  UniFlip
//
//  Created by mac2492 on 7/13/21.
//

#import "OptionCell.h"

@implementation OptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapOption:(id)sender {
    /*[self performSegueWithIdentifier:@"HomeToOtherUser" sender:[self.optionButton currentTitle]];}*/
}

@end
