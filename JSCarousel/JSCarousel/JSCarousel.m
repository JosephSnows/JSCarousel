//
//  JSCarousel.m
//  JSCustom
//
//  Created by Jeask on 15/6/22.
//  Copyright (c) 2015年 Jeask. All rights reserved.
//

#import "JSCarousel.h"
#import "UIImageView+WebCache.h"

#define kCarousel_CapacityViews 5
#define kDefault_TransmitTime 3.f

typedef NS_ENUM(NSInteger,scrollPosition) {
    
    scrollPositionLeft = 0,
    scrollPositionStill = 1,
    scrollPositionRight = 2,
};

@interface JSCarousel() <UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *contentView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) NSMutableArray *visibleViews;
@property (nonatomic,strong) NSMutableSet *reuseViews;
@property (nonatomic,strong) NSTimer *myTimer;

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,assign) NSInteger preIndex;
@property (nonatomic,assign) NSInteger nextIndex;

@property (nonatomic,strong) NSArray *imageURLs;

@property (nonatomic) CGFloat preX;
@property (nonatomic) scrollPosition scrollPosition;

@end

@implementation JSCarousel

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.reuseViews = [[NSMutableSet alloc] initWithCapacity:kCarousel_CapacityViews];
    self.visibleViews = [NSMutableArray new];
    _currentIndex = 0;
    _preX = 0;
    _automaticallyDisplay = YES;
    
    _contentView = ({
    
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
        scrollView;
    
    });
    
    _pageControl = ({

        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
        [self addSubview:pageControl];
        pageControl;
    
    });
    
    for (int i = 0; i < kCarousel_CapacityViews; i ++ ) {
        UIImageView *reuseView = [[UIImageView alloc] init];
        reuseView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(targetTaped)];
        [reuseView addGestureRecognizer:tapGesture];
        
        [self.reuseViews addObject:reuseView];
    }
}

-(void)setDelegate:(id<JSCarouselDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if ([self.delegate respondsToSelector:@selector(displayURLsInCarousel:)]) {
            [self reloadData];
        }
    }
}

-(void)reloadData
{
    for (UIImageView *imageView in self.contentView.subviews) {
        [imageView removeFromSuperview];
        
        [_visibleViews removeObject:imageView];
        [_reuseViews addObject:imageView];
        [imageView removeFromSuperview];
    }
    
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    
    [self initConfigration];
    [self updateUI];
    [self updatePageControl];
    [self animationLoop];
}

-(void)initConfigration
{
    if ([self.delegate respondsToSelector:@selector(displayURLsInCarousel:)]) {
        _imageURLs = [self.delegate displayURLsInCarousel:self];
    }
    
    if (_imageURLs.count > 1) {
        _contentView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        _contentView.scrollEnabled = YES;
    }
    else{
        _contentView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        _contentView.scrollEnabled = NO;
    }
}

-(void)updatePageControl
{
    if (self.imageURLs.count <= 1) {
        return;
    }
    
    _pageControl.currentPageIndicatorTintColor = _currentPageControlIndecatorColor ? : [UIColor colorWithWhite:0.9f alpha:1.f];
    _pageControl.pageIndicatorTintColor = _restPageControlIndicatorColor ? : [UIColor colorWithWhite:0.6f alpha:1.f];
    _pageControl.numberOfPages = _imageURLs.count;
    _pageControl.currentPage = 0;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma Gesture Taped

-(void)targetTaped
{
    if ([self.delegate respondsToSelector:@selector(carousel:selectedAtIndex:)]) {
        [self.delegate carousel:self selectedAtIndex:_currentIndex];
    }
}

#pragma Set Methods

-(void)setHidePageControl:(BOOL)hidePageControl
{
    _hidePageControl = hidePageControl;
    _pageControl.hidden = hidePageControl;
}

#pragma mark Run Loop

-(void)animationLoop
{
    if (!_imageURLs && _imageURLs.count <= 1) {
        return;
    }
    
    if (!_automaticallyDisplay) {
        return;
    }
    
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:_automaticallySwitchTimeInterval ? : kDefault_TransmitTime target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
}

-(void)runLoop
{
    [self.contentView scrollRectToVisible:CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height) animated:YES];
}

#pragma mark ScrollView Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x != self.frame.size.width) {
        [self reuseContentUI];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self reuseContentUI];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat gap = scrollView.contentOffset.x - _preX;

    _scrollPosition = (gap > 0) ? scrollPositionRight : scrollPositionLeft;
    
    _preX = scrollView.contentOffset.x;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_myTimer invalidate];
    _myTimer = nil;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self animationLoop];
}

#pragma mark Reuse UI

-(void)updateUI
{
    if (_imageURLs.count == 0) {
        return;
    }
    
    [self computeIndex];
    
    if (self.imageURLs.count == 1) {
        
        UIImageView *visibleView = [self dequeueViewFromReuseSet];
        
        visibleView.frame = self.contentView.bounds;
        
        [visibleView sd_setImageWithURL:[NSURL URLWithString:_imageURLs[0]] placeholderImage:_placeHolderImage];
        
    }
    else if (self.imageURLs.count > 1){
        
        for (int i = 0; i < 3; i ++) {
            UIImageView *visibleView = [self dequeueViewFromReuseSet];
            
            visibleView.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
            
            NSInteger tempIndex = 0;
            if (i == 0) {
                tempIndex = _preIndex;
            }
            else if (i == 1){
                tempIndex = _currentIndex;
            }
            else if (i == 2){
                tempIndex = _nextIndex;
            }
            
            [visibleView sd_setImageWithURL:[NSURL URLWithString:_imageURLs[tempIndex]] placeholderImage:_placeHolderImage];
        }
        
        self.contentView.contentOffset = CGPointMake(self.frame.size.width, 0);
    }
}

-(void)computeIndex
{
    if (_currentIndex == _imageURLs.count) {
        _currentIndex = 0;
    }
    
    if (_currentIndex < 0) {
        _currentIndex = _imageURLs.count - 1;
    }
    
    _preIndex = _currentIndex - 1;
    _nextIndex = _currentIndex + 1;
    
    if (_currentIndex == 0) {
        _preIndex = _imageURLs.count - 1;
    }
    
    if (_currentIndex == _imageURLs.count - 1) {
        _nextIndex = 0;
    }
}

-(void)reuseContentUI
{
    [self reuseImageView];
    
    [self reuseUI];
    
    [self updateUIFrame];
    
    self.pageControl.currentPage = _currentIndex;
    
    [self.contentView setContentOffset:CGPointMake(self.frame.size.width, 0)];
}

-(void)reuseUI
{
    UIImageView *imageView = [_reuseViews anyObject];
    
    [_reuseViews removeObject:imageView];
    
    if (_scrollPosition == scrollPositionRight) {
        
        _currentIndex ++;
        
        [self computeIndex];
        
        [_visibleViews insertObject:imageView atIndex:_visibleViews.count];
        
        imageView.frame = CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height);
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:_imageURLs[_nextIndex]] placeholderImage:_placeHolderImage];
    }
    else{
        
        _currentIndex --;
        
        [self computeIndex];
        
        [_visibleViews insertObject:imageView atIndex:0];
        
        imageView.frame = self.contentView.bounds;
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:_imageURLs[_preIndex]] placeholderImage:_placeHolderImage];
    }
    
    [self.contentView addSubview:imageView];
}

-(void)updateUIFrame
{
    for (int i = 0; i < 3; i ++) {
        UIImageView *imageView = _visibleViews[i];
        imageView.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
    }
}

-(void)reuseImageView
{
    if (_scrollPosition == scrollPositionRight) {
        
        UIImageView *visibleView = [_visibleViews firstObject];
        
        [_visibleViews removeObject:visibleView];
        
        [_reuseViews addObject:visibleView];
        
        [visibleView removeFromSuperview];
        
    }
    else{
        
        UIImageView *visibleView = [_visibleViews lastObject];
        
        [_visibleViews removeObject:visibleView];
        
        [_reuseViews addObject:visibleView];
        
        [visibleView removeFromSuperview];
        
    }
}

-(UIImageView *)dequeueViewFromReuseSet
{
    UIImageView *imageView = [_reuseViews anyObject];
    
    [_reuseViews removeObject:imageView];
    
    [_visibleViews addObject:imageView];
    
    [self.contentView addSubview:imageView];
    
    return imageView;
}

@end
