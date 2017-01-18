//
//  TXBYDrawView.h
//  DrawTest
//
//  Created by YandL on 16/7/6.
//  Copyright © 2016年 YandL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXBYDrawView : UIView

/**
 *  默认播放间隔 毫秒(ms)
 */
@property (nonatomic, assign) float breakTime;

- (void)showHistory;

//- (void)clearHistory;

@end
