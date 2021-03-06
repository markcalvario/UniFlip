//
//  CategoryCell.h
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *listingCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listingCollectionViewHeight;
@property (strong, nonatomic) IBOutlet UIButton *viewAllButton;
- (void) populateCategoryCellInHomeWithCategory:(NSString *)category withIndexPath:(NSIndexPath *)indexPath;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *categoryLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *categoryLabelBottomConstraint;




//OTHER SCREEN
@property (strong, nonatomic) IBOutlet UICollectionView *listingsByCategoryCollectionView;



@end

NS_ASSUME_NONNULL_END
