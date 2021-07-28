//
//  CategoryCell.m
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import "CategoryCell.h"

@implementation CategoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.categoryLabel.isAccessibilityElement = YES;
    self.viewAllButton.isAccessibilityElement = YES;
    
}

- (void) populateCategoryCellInHomeWithCategory:(NSString *)category withIndexPath:(NSIndexPath *)indexPath{
    self.categoryLabel.text = category;
    self.categoryLabel.accessibilityLabel = category;
    self.listingCollectionView.tag = indexPath.row;
    self.listingCollectionView.scrollEnabled = NO;
    self.viewAllButton.tag = indexPath.row;
    self.categoryLabel.accessibilityValue = [@"Listing category of " stringByAppendingString:category];
    self.viewAllButton.accessibilityValue = [[@"View all listings under the " stringByAppendingString:category] stringByAppendingString:@" category"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}





@end
