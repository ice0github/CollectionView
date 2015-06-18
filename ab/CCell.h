//
//  CCell.h
//  
//
//  Created by crazypoo on 15/6/18.
//
//

#import <UIKit/UIKit.h>

@class CCell;

@protocol CCellDelegate
@optional
@end

@interface CCell : UICollectionViewCell
{
}
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) id<CCellDelegate>delegate;
@end
