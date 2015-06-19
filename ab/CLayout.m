//
//  CLayout.m
//  
//
//  Created by crazypoo on 15/6/18.
//
//

#import "CLayout.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define SIZE 100
#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define COL ((int)(screenWidth / SIZE / 2.0) * 2)

#ifndef CGGEOMETRY_CSUPPORT_H_
CG_INLINE CGPoint
C_CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}
#endif

static NSString * const kCScrollingDirectionKey = @"CScrollingDirection";
static NSString * const kCCollectionViewKeyPath = @"collectionView";

typedef NS_ENUM(NSInteger, CScrollingDirection) {
    CScrollingDirectionUnknown = 0,
    CScrollingDirectionUp,
    CScrollingDirectionDown,
    CScrollingDirectionLeft,
    CScrollingDirectionRight
};

@implementation CADisplayLink (C_userInfo)
- (void) setC_userInfo:(NSDictionary *) C_userInfo {
    objc_setAssociatedObject(self, "C_userInfo", C_userInfo, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *) C_userInfo {
    return objc_getAssociatedObject(self, "C_userInfo");
}
@end

@implementation UICollectionViewCell (CLayout)

- (UIView *)C_snapshotView {
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        return [self snapshotViewAfterScreenUpdates:YES];
    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return [[UIImageView alloc] initWithImage:image];
    }
}

@end

@implementation CLayout

-(CGSize)collectionViewContentSize
{
    float height = (SIZE + self.margin) * ([self.collectionView numberOfItemsInSection:0] / 2);
    return CGSizeMake(screenWidth, height);
}

- (id)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:kCCollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self invalidatesScrollTimer];
    [self removeObserver:self forKeyPath:kCCollectionViewKeyPath];
}

- (id<CLayoutDataSource>)dataSource {
    return (id<CLayoutDataSource>)self.collectionView.dataSource;
}

- (id<CLayoutDelegateFlowLayout>)delegate {
    return (id<CLayoutDelegateFlowLayout>)self.collectionView.delegate;
}

- (void)invalidateLayoutIfNecessary {
    NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:self.currentView.center];
    NSIndexPath *previousIndexPath = self.selectedItemIndexPath;
    
    if ((newIndexPath == nil) || [newIndexPath isEqual:previousIndexPath]) {
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)] &&
        ![self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath canMoveToIndexPath:newIndexPath]) {
        return;
    }
    
    self.selectedItemIndexPath = newIndexPath;
    
    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
        [self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath willMoveToIndexPath:newIndexPath];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.collectionView deleteItemsAtIndexPaths:@[ previousIndexPath ]];
            [strongSelf.collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
        }
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
            [strongSelf.dataSource collectionView:strongSelf.collectionView itemAtIndexPath:previousIndexPath didMoveToIndexPath:newIndexPath];
        }
    }];
}

- (void)invalidatesScrollTimer {
    if (!self.displayLink.paused) {
        [self.displayLink invalidate];
    }
    self.displayLink = nil;
}

- (void)setupCollectionView
{
    [self setUpCollectionViewGesture];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    UICollectionView *collection = self.collectionView;
    if (indexPath.item %5 == 0) {
        float x = (screenWidth-SIZE)/2;
        float y = 70;
        attributes.center = CGPointMake(x+collection.contentOffset.x, (indexPath.item+5)/5*y+indexPath.item/5*100);
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 1) {
        float x = (screenWidth-SIZE)/2;
        float y = 70;
        x = x+SIZE;
        attributes.center = CGPointMake(x + collection.contentOffset.x, (indexPath.item+5)/5*y+indexPath.item/5*100);
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 2) {
        float y = 155;
        attributes.center = CGPointMake(60, (indexPath.item+5)/5*y+indexPath.item/5*+15);
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 3) {
        float y = 155;
        attributes.center = CGPointMake(160, (indexPath.item+5)/5*y+indexPath.item/5*+15);
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 4) {
        float y = 155;
        attributes.center = CGPointMake(260, (indexPath.item+5)/5*y+indexPath.item/5*+15);
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    return attributes;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    if ([arr count] > 0) {
        return arr;
    }
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i = 0 ; i < [self.collectionView numberOfItemsInSection:0 ]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (void)setUpCollectionViewGesture
{
    if (!_setUped) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _longPressGesture.delegate = self;
        _panGesture.delegate = self;
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGesture]; }}
        [self.collectionView addGestureRecognizer:_longPressGesture];
        [self.collectionView addGestureRecognizer:_panGesture];
        _setUped = YES;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            //indexPath
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            //can move
            if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
                if (![self.dataSource collectionView:self.collectionView canMoveItemAtIndexPath:indexPath]) {
                    return;
                }
            }
            //will begin dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:indexPath];
            }
            
            self.selectedItemIndexPath = indexPath;
            
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:self.selectedItemIndexPath];
            }
            
            UICollectionViewCell *collectionViewCell = [self.collectionView cellForItemAtIndexPath:self.selectedItemIndexPath];
            
            self.currentView = [[UIView alloc] initWithFrame:collectionViewCell.frame];
            
            collectionViewCell.highlighted = YES;
            UIView *highlightedImageView = [collectionViewCell C_snapshotView];
            highlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            highlightedImageView.alpha = 1.0f;
            
            collectionViewCell.highlighted = NO;
            UIView *imageView = [collectionViewCell C_snapshotView];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.alpha = 0.0f;
            
            [self.currentView addSubview:imageView];
            [self.currentView addSubview:highlightedImageView];
            [self.collectionView addSubview:self.currentView];
            
            self.currentViewCenter = self.currentView.center;
            
            __weak typeof(self) weakSelf = self;
            [UIView
             animateWithDuration:0.3
             delay:0.0
             options:UIViewAnimationOptionBeginFromCurrentState
             animations:^{
                 __strong typeof(self) strongSelf = weakSelf;
                 if (strongSelf) {
                     strongSelf.currentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                     highlightedImageView.alpha = 0.0f;
                     imageView.alpha = 1.0f;
                 }
             }
             completion:^(BOOL finished) {
                 __strong typeof(self) strongSelf = weakSelf;
                 if (strongSelf) {
                     [highlightedImageView removeFromSuperview];
                     
                     if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
                         [strongSelf.delegate collectionView:strongSelf.collectionView layout:strongSelf didBeginDraggingItemAtIndexPath:strongSelf.selectedItemIndexPath];
                     }
                 }
             }];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            NSIndexPath *currentIndexPath = self.selectedItemIndexPath;
            
            if (currentIndexPath) {
                if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
                    [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:currentIndexPath];
                }
                self.selectedItemIndexPath = nil;
                self.currentViewCenter = CGPointZero;
                UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:currentIndexPath];
                self.longPressGesture.enabled = NO;
                __weak typeof(self) weakSelf = self;
                [UIView
                 animateWithDuration:0.3
                 delay:0.0
                 options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     __strong typeof(self) strongSelf = weakSelf;
                     if (strongSelf) {
                         strongSelf.currentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         strongSelf.currentView.center = layoutAttributes.center;
                     }
                 }
                 completion:^(BOOL finished) {
                     
                     self.longPressGesture.enabled = YES;
                     
                     __strong typeof(self) strongSelf = weakSelf;
                     if (strongSelf) {
                         [strongSelf.currentView removeFromSuperview];
                         strongSelf.currentView = nil;
                         [strongSelf invalidateLayout];
                         
                         if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
                             [strongSelf.delegate collectionView:strongSelf.collectionView layout:strongSelf didEndDraggingItemAtIndexPath:currentIndexPath];
                         }
                     }
                 }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
            self.panTranslationInCollectionView = [pan translationInView:self.collectionView];
            self.currentView.center = C_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
            
            [self invalidateLayoutIfNecessary];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self invalidatesScrollTimer];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.panGesture isEqual:gestureRecognizer]) {
        return (self.selectedItemIndexPath != nil);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.longPressGesture isEqual:gestureRecognizer]) {
        return [self.panGesture isEqual:otherGestureRecognizer];
    }
    
    if ([self.panGesture isEqual:gestureRecognizer]) {
        return [self.longPressGesture isEqual:otherGestureRecognizer];
    }
    
    return NO;
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kCCollectionViewKeyPath]) {
        if (self.collectionView != nil) {
            [self setupCollectionView];
        } else {
            [self invalidatesScrollTimer];
        }
    }
}

#pragma mark - Notifications

- (void)handleApplicationWillResignActive:(NSNotification *)notification {
    self.panGesture.enabled = NO;
    self.panGesture.enabled = YES;
}

#pragma mark - Depreciated methods

#pragma mark Starting from 0.1.0
- (void)setUpGestureRecognizersOnCollectionView {
    // Do nothing...
}


@end
