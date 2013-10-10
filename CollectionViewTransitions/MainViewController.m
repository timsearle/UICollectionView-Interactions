//
//  MainViewController.m
//  CollectionViewTransitions
//
//  Created by Tim Searle on 10/10/2013.
//  Copyright (c) 2013 Tim Searle. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) UICollectionViewFlowLayout *standardFlowLayout;
@property (nonatomic,strong) UICollectionViewFlowLayout *tileFlowLayout;
@property (nonatomic,strong) UICollectionViewFlowLayout *mosaicFlowLayout;

@property (nonatomic,assign) CGFloat lastScale;
@property (nonatomic,assign) BOOL isZooming;
@property (nonatomic,assign) BOOL transitioning;

- (void)didReceivePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer;

@end

@implementation MainViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Style
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    // UICollectionView
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    [self.collectionView registerClass:[UICollectionViewCell class]
                                                     forCellWithReuseIdentifier:@"Cell"];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinch:)];
    [self.collectionView addGestureRecognizer:pinchGestureRecognizer];
    
    self.standardFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.standardFlowLayout setItemSize:CGSizeMake(310.0f, 157.0f)];
    
    self.tileFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.tileFlowLayout setItemSize:CGSizeMake(90.0f, 90.0f)];
    
    self.mosaicFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.mosaicFlowLayout setItemSize:CGSizeMake(50.0f, 50.0f)];
    [self.mosaicFlowLayout setMinimumInteritemSpacing:0.0f];
    
    [self.collectionView setCollectionViewLayout:self.standardFlowLayout];

}

#pragma mark - UICollectionViewDelegate



#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell.layer setBorderWidth:1.0f];
    [cell.layer setBorderColor:[UIColor redColor].CGColor];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - Interactions

- (void)didReceivePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UICollectionViewTransitionLayout *layout;
    
    if ([pinchGestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [pinchGestureRecognizer setScale:1.0f];
        self.lastScale = pinchGestureRecognizer.scale;
    } else if ([pinchGestureRecognizer state] == UIGestureRecognizerStateChanged) {
        if (self.transitioning) {
            layout = (UICollectionViewTransitionLayout *)self.collectionView.collectionViewLayout;
        } else {
            self.isZooming = self.lastScale < [pinchGestureRecognizer scale];
            
            UICollectionViewLayout *layoutToTransitionTo;
            
            if (self.isZooming) {
                if ([self.collectionView.collectionViewLayout isEqual:self.standardFlowLayout]) {
                    return;
                } else if ([self.collectionView.collectionViewLayout isEqual:self.tileFlowLayout]) {
                    layoutToTransitionTo = self.standardFlowLayout;
                } else if ([self.collectionView.collectionViewLayout isEqual:self.mosaicFlowLayout]){
                    layoutToTransitionTo = self.tileFlowLayout;
                }
            } else {
                if ([self.collectionView.collectionViewLayout isEqual:self.standardFlowLayout]) {
                    layoutToTransitionTo = self.tileFlowLayout;
                } else if ([self.collectionView.collectionViewLayout isEqual:self.tileFlowLayout]) {
                    layoutToTransitionTo = self.mosaicFlowLayout;
                } else {
                    return;
                }
            }
            
            layout = [self.collectionView startInteractiveTransitionToCollectionViewLayout:layoutToTransitionTo
                                                                                completion:^(BOOL completed, BOOL finish) {
                                                                                    self.transitioning = NO;
                                                                                }];
            self.transitioning = YES;
        }
        
        if (self.isZooming) {
            if ([pinchGestureRecognizer scale] > self.lastScale && layout.transitionProgress <= 1.0f) {
                layout.transitionProgress = layout.transitionProgress + 0.03f;
                [self.collectionView.collectionViewLayout invalidateLayout];
                self.lastScale = [pinchGestureRecognizer scale];
            } else if ([pinchGestureRecognizer scale] < self.lastScale && layout.transitionProgress >= 0.0f){
                layout.transitionProgress = layout.transitionProgress - 0.03f;
                [self.collectionView.collectionViewLayout invalidateLayout];
                self.lastScale = [pinchGestureRecognizer scale];
            }
        } else {
            if ([pinchGestureRecognizer scale] > self.lastScale && layout.transitionProgress >= 0.0f) {
                layout.transitionProgress = layout.transitionProgress - 0.03f;
                [self.collectionView.collectionViewLayout invalidateLayout];
                self.lastScale = [pinchGestureRecognizer scale];
            } else if ([pinchGestureRecognizer scale] < self.lastScale && layout.transitionProgress <= 1.0f){
                layout.transitionProgress = layout.transitionProgress + 0.03f;
                [self.collectionView.collectionViewLayout invalidateLayout];
                self.lastScale = [pinchGestureRecognizer scale];
            }
        }
    } else if ([pinchGestureRecognizer state] == UIGestureRecognizerStateEnded && self.transitioning) {
        layout = (UICollectionViewTransitionLayout *)self.collectionView.collectionViewLayout;
        if (layout.transitionProgress > 0.6f) {
            [self.collectionView finishInteractiveTransition];
            self.transitioning = NO;
        } else {
            [self.collectionView cancelInteractiveTransition];
            self.transitioning = NO;
        }
    }
    
}


@end
