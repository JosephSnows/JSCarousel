//
//  JSCarousel.h
//  JSCustom
//
//  Created by Jeask on 15/6/22.
//  Copyright (c) 2015年 Jeask. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JSCarousel;

@protocol JSCarouselDelegate <NSObject>

/**
 *    图片的地址 子集为NSString
 */
-(NSArray *)displayURLsInCarousel:(JSCarousel *)carousel;

-(void)carousel:(JSCarousel *)carousel selectedAtIndex:(NSInteger)index;

@end

@interface JSCarousel : UIView

@property (nonatomic,weak) id<JSCarouselDelegate> delegate;

/**
 *   是否自动轮播 默认为是
 */
@property (nonatomic) BOOL automaticallyDisplay;

/**
 *   自动轮播的间隔时间 默认为3秒
 */
@property (nonatomic) NSTimeInterval automaticallySwitchTimeInterval;

/**
 *   是否隐藏指示器 默认为否
 */
@property (nonatomic) BOOL hidePageControl;

/**
 *   当前指示器的颜色
 */
@property (nonatomic,strong) UIColor *currentPageControlIndecatorColor;

/**
 *   其他指示器的颜色
 */
@property (nonatomic,strong) UIColor *restPageControlIndicatorColor;

/**
 *   占位图
 */
@property (nonatomic,strong) UIImage *placeHolderImage;


-(void)reloadData;

@end
