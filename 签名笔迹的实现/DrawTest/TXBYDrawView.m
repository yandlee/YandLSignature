//
//  TXBYDrawView.m
//  DrawTest
//
//  Created by YandL on 16/7/6.
//  Copyright © 2016年 YandL. All rights reserved.
//

#import "TXBYDrawView.h"

@interface TXBYDrawView()
/**
 *  纪录短暂的路径
 */
@property (nonatomic, strong) NSMutableArray *paths;
/**
 *  纪录每次点击开始到结束路径
 */
@property (nonatomic, strong) NSMutableArray *allPaths;
/**
 *  纪录所有的路径
 */
@property (nonatomic, strong) NSMutableArray *historyPaths;
/**
 *  是否是一次新的点击事件
 */
@property (nonatomic, assign) BOOL isNew;
/**
 *  绘制的线条宽度
 */
@property (nonatomic, assign) float lineWidth;
/**
 *  每一次需要绘制的路径
 */
@property (nonatomic, strong) UIBezierPath *linePath;
/**
 *  每次绘制完成生成的图片
 */
@property (nonatomic, strong) UIImage *backgroundImage;
/**
 *  背景图层
 */
@property (nonatomic, strong) UIImageView *backgroundImgView;
/**
 *  计时器
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 *  时间
 */
@property (nonatomic, assign) NSInteger seconds;
/**
 *  结束时间
 */
@property (nonatomic, assign) NSInteger endSecond;
/**
 *  结束时间数组
 */
@property (nonatomic, strong) NSMutableArray *endSecondArr;
/**
 *  纪录每个点的时间
 */
@property (nonatomic, strong) NSMutableArray *timeArr;
/**
 *  纪录每个点的粗细
 */
@property (nonatomic, strong) NSMutableArray *pointWidthArr;

@end

@implementation TXBYDrawView

- (NSMutableArray *)paths {
    if (_paths == nil) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}

- (NSMutableArray *)allPaths {
    if (_allPaths == nil) {
        _allPaths = [NSMutableArray array];
    }
    return _allPaths;
}

- (NSMutableArray *)historyPaths {
    if (_historyPaths == nil) {
        _historyPaths = [NSMutableArray array];
        self.endSecond = 0;
    }
    return _historyPaths;
}

- (NSMutableArray *)endSecondArr {
    if (_endSecondArr == nil) {
        _endSecondArr = [NSMutableArray array];
    }
    return _endSecondArr;
}

- (NSMutableArray *)timeArr {
    if (_timeArr == nil) {
        _timeArr = [NSMutableArray array];
    }
    return _timeArr;
}

- (NSMutableArray *)pointWidthArr {
    if (_pointWidthArr == nil) {
        _pointWidthArr = [NSMutableArray array];
    }
    return _pointWidthArr;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 设置参数
    _seconds = 0;
    _isNew = YES;
    // 创建新起点
    UITouch *touch = [touches anyObject];
    
    CGPoint strat = [touch locationInView:touch.view];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:strat];
    [self.paths addObject:path];
    [self startTime];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // 是否是第一次
    if (self.allPaths.count) {
        CGPoint move = [touch locationInView:touch.view];
        UIBezierPath *curentPath = [self.allPaths lastObject];
        [curentPath addLineToPoint:move];
        [self.allPaths replaceObjectAtIndex:self.allPaths.count - 1 withObject:curentPath];
    }
    else {
        CGPoint move = [touch locationInView:touch.view];
        UIBezierPath *curentPath = [self.paths lastObject];
        [curentPath addLineToPoint:move];
        [self.allPaths addObject:curentPath];
        // 添加第一个点的宽度
        self.lineWidth = (touch.force * 10.0 > 1.0)? touch.force * 10.0: 1.0;
        [self.pointWidthArr addObject:[NSNumber numberWithFloat:self.lineWidth]];
    }
    
    // 添加完成后 创建一个新的起点
    CGPoint strat = [touch locationInView:touch.view];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:strat];
    [self.allPaths addObject:path];
    self.lineWidth = (touch.force * 10.0 > 1.0)? touch.force * 10.0: 1.0;
    [self drawLines];
    [self.pointWidthArr addObject:[NSNumber numberWithFloat:self.lineWidth]];
    [self.timeArr addObject:[NSNumber numberWithInteger:self.seconds + self.endSecond]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.allPaths.count) {
        for (int i = 0; i < self.allPaths.count - 1; i++) {
            UIBezierPath *path = self.allPaths[i];
            [self.historyPaths addObject:path];
        }
        // 额外添加一个空白路径 表示触摸之间的间隔
        UIBezierPath *nilPath = [UIBezierPath bezierPath];
        [self.historyPaths addObject:nilPath];
        NSNumber *lastSecond = [self.timeArr lastObject];
        self.endSecond = [lastSecond integerValue];
        // 添加绘制之间的间隔 0.5s
        [self.timeArr addObject:[NSNumber numberWithInteger:self.seconds + self.breakTime]];
        // 纪录每次停顿的时间
        [self.endSecondArr addObject:[NSNumber numberWithInteger:self.endSecond]];
        // 加0.5s  用于下一次开始之间的停顿
        self.endSecond = self.breakTime + self.endSecond;
        
        // 结束触摸后处理view
        self.allPaths = [NSMutableArray array];
        [self stopTime];
        [self generateImage];
        [self clearView];
        [self showImage];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
}

/**
 *  绘制图形
 */
- (void)drawLines {
    self.linePath = self.allPaths[self.allPaths.count - 2];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.lineWidth = self.lineWidth;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor blackColor].CGColor;
    layer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    layer.shouldRasterize = YES;
    layer.lineCap = kCALineCapRound;
    layer.path = self.linePath.CGPath;
    [self.layer addSublayer:layer];
}

/**
 *  绘制历史纪录
 */
- (void)showHistory {
    if (self.historyPaths.count) {
        [self.backgroundImgView removeFromSuperview];
        for (NSInteger i = 0; i < self.timeArr.count; i++) {
            NSNumber *time = self.timeArr[i];
            NSNumber *isBreak = [NSNumber numberWithInteger:0];
            for (NSNumber *second in self.endSecondArr) {
                if ([second integerValue] == [time integerValue]) {
                    isBreak = [NSNumber numberWithInteger:1];
                    break;
                }
                else {
                    isBreak = [NSNumber numberWithInteger:0];
                }
            }
            [self performSelector:@selector(drawHistoryLines:) withObject:[NSArray arrayWithObjects:[NSNumber numberWithInteger:i], isBreak, nil] afterDelay:[time doubleValue] / 1000.0];
        }
    }
}

/**
 *  按顺序播放
 */
- (void)drawHistoryLines:(NSArray *)arr {
    NSNumber *index = arr[0];
    NSNumber *lineWidth = self.pointWidthArr[[index integerValue]];
    UIBezierPath *path = self.historyPaths[[index integerValue]];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.lineWidth = [lineWidth floatValue];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor blackColor].CGColor;
    layer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    layer.shouldRasterize = YES;
    layer.lineCap = kCALineCapRound;
    layer.path = path.CGPath;
    [self.layer addSublayer:layer];
    NSNumber *isBreak = arr[1];
    if ([isBreak integerValue] == 1) {
        [self generateImage];
        [self clearView];
        [self showImage];
    }
}

/**
 *  生成图片
 */
- (void)generateImage {
    // 该模式下retina屏幕会显示失真
//    UIGraphicsBeginImageContext(self.frame.size);
    // 解决失真问题
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    self.backgroundImage = image;
}

/**
 *  显示图片
 */
- (void)showImage {
    [self.backgroundImgView removeFromSuperview];
    self.backgroundImgView = [[UIImageView alloc] init];
    self.backgroundImgView.frame = self.bounds;
    self.backgroundImgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backgroundImgView];
    self.backgroundImgView.image = self.backgroundImage;
}

/**
 *  开始时间
 */
- (void)startTime {
    //每隔0.001秒刷新一次
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(runAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/**
 *  停止时间
 */
- (void)stopTime {
    [self.timer invalidate];
    self.timer = nil;
}

/**
 *  时间控制毫秒
 */
- (void)runAction {
    _seconds ++;
}


/**
 *  清空视图
 */
- (void)clearView {
    NSMutableArray *arr = [NSMutableArray array];
    for (CALayer *layer in self.layer.sublayers) {
        [arr addObject:layer];
    }
    for (CALayer *layer in arr) {
        [layer removeFromSuperlayer];
    }
}

@end
