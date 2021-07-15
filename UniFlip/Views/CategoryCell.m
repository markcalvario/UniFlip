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
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.listingCollectionView.collectionViewLayout;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    CGFloat postsPerRow = 2;
    CGFloat itemWidth = (self.listingCollectionView.frame.size.width - layout.minimumInteritemSpacing * (postsPerRow) )/ postsPerRow;
    CGFloat itemHeight = itemWidth * 1;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
