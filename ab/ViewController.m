//
//  ViewController.m
//  ab
//
//  Created by crazypoo on 15/6/18.
//  Copyright (c) 2015年 P. All rights reserved.
//

#import "ViewController.h"
#import "CCell.h"
#import "CLayout.h"

static NSString * const reuseIdentifier = @"Cell";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,CLayoutDataSource,CLayoutDelegateFlowLayout>
{
    UICollectionView *myC;
    NSMutableArray *titleArr;
    UIButton *rBtn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    titleArr = [[NSMutableArray array] init];
    for (NSInteger i = 1; i <= 8; i++) {
        NSString *name = [NSString stringWithFormat:@"%ld",i];
        [titleArr addObject:name];
    }
    
    UIButton *lBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    lBtn.frame = CGRectMake(0, 0, 30, 30);
    [lBtn addTarget:self action:@selector(addAct:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:lBtn];
    
    rBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    rBtn.frame = CGRectMake(0, 0, 30, 30);
    rBtn.selected = NO;
    [rBtn addTarget:self action:@selector(killAct:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rBtn];
    
    CLayout *layout = [[CLayout alloc] init];
    
    myC = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    myC.backgroundColor = [UIColor whiteColor];
    myC.dataSource = self;
    myC.delegate = self;
    myC.showsHorizontalScrollIndicator = YES;
    myC.showsVerticalScrollIndicator = YES;
    myC.pagingEnabled = YES;
    myC.scrollEnabled = YES;
    [myC registerClass:[CCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.view addSubview:myC];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return titleArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",titleArr[indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"it>>>>%@",titleArr[indexPath.row]);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    CCell *cell = titleArr[fromIndexPath.item];
    
    [titleArr removeObjectAtIndex:fromIndexPath.item];
    [titleArr insertObject:cell atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {

    return YES;
}

-(void)addAct:(UIButton *)sender
{
    [titleArr insertObject:[NSString stringWithFormat:@"%d",(arc4random() %1000)] atIndex:titleArr.count];
    [myC reloadData];
}

-(void)killAct:(UIButton *)sender
{
#warning 暂时只能随机一个个删除
    if (!titleArr.count) {
        return;
    }
    NSArray *visibleIndexPaths = [myC indexPathsForVisibleItems];
    NSIndexPath *toRemove = [visibleIndexPaths objectAtIndex:(arc4random() % visibleIndexPaths.count)];
    [self removeIndexPath:toRemove];
}

- (void)removeIndexPath:(NSIndexPath *)indexPath {
    if(!titleArr.count || indexPath.row > titleArr.count)
    {
        return;
    }

    [myC performBatchUpdates:^{
        NSInteger index = indexPath.row;
        [titleArr removeObjectAtIndex:index];
        [myC deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:^(BOOL done) {
        [myC reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
