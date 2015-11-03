//
//  ViewController.m
//  JSCarousel
//
//  Created by 一斌 on 15/11/3.
//  Copyright © 2015年 一斌. All rights reserved.
//

#import "ViewController.h"
#import "JSCarousel.h"

@interface ViewController ()<JSCarouselDelegate>

@property (nonatomic,strong) JSCarousel *myCarousel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myCarousel = [[JSCarousel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    _myCarousel.delegate = self;
    [self.view addSubview:_myCarousel];
    
    _myCarousel.backgroundColor = [UIColor grayColor];
}

-(NSArray *)displayURLsInCarousel:(JSCarousel *)carousel
{
    return @[@"http://v1.qzone.cc/pic/201504/12/21/19/552a70c8881e7824.jpg!600x600.jpg",
             @"http://v1.qzone.cc/pic/201504/12/21/19/552a70cda976e234.jpg!600x600.jpg",
             @"http://v1.qzone.cc/pic/201504/12/21/19/552a70d2ea594342.jpg!600x600.jpg",
             @"http://ossweb-img.qq.com/images/gamevip/act/a201505cf/dmdb.png"];
}


@end
