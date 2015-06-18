//
//  CLayout.h
//  
//
//  Created by crazypoo on 15/6/18.
//
//

#import <UIKit/UIKit.h>

@protocol CLayoutDataSource <UICollectionViewDataSource>

@optional

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol CLayoutDelegateFlowLayout <UICollectionViewDelegateFlowLayout>
@optional

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CLayout : UICollectionViewLayout<UIGestureRecognizerDelegate>
@property (nonatomic, assign) NSInteger margin;
@property (nonatomic, assign) NSInteger oX;
@property (nonatomic, assign) BOOL setUped;
@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;
@property (strong, nonatomic) UIView *currentView;
@property (assign, nonatomic) CGPoint currentViewCenter;
@property (assign, nonatomic) CGPoint panTranslationInCollectionView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) CGFloat scrollingSpeed;
@property (assign, nonatomic) UIEdgeInsets scrollingTriggerEdgeInsets;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;
@property (assign, nonatomic, readonly) id<CLayoutDataSource> dataSource;
@property (assign, nonatomic, readonly) id<CLayoutDelegateFlowLayout> delegate;
- (void)setUpGestureRecognizersOnCollectionView __attribute__((deprecated("Calls to setUpGestureRecognizersOnCollectionView method are not longer needed as setup are done automatically through KVO.")));

@end

