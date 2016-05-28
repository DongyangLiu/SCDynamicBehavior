//
//  SCDynamicBehaviorManager.h
//  SealChat
//
//  Created by yang on 16/5/9.
//  Copyright © 2016年 Lianxi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SCDynamicBehaviorManager : NSObject

+ (SCDynamicBehaviorManager *) defaultManager;

/**
 * @breaf 创建动画
 *
 * @param view              动画的父视图(范围)(framesArray的相对父视图)
 * @param type              动画类型，nil时无动画
 * @param number            动画个体数量，默认3（使用默认传 0）
 * @param intervalTime      时间间隔，默认0.1f（使用默认传 0）
 * @param middleSpace       偏移位置，默认20.0f（使用默认传 0）
 * @param framesArray       跳动台阶的frame字符串数组（使用默认传 0）
 */
- (void)showDynamicBehaviorViewInView:(UIView *)view
                                 type:(NSString *)type
                               number:(NSInteger)number
                         intervalTime:(NSTimeInterval)intervalTime
                          middleSpace:(CGFloat)middleSpace
                               frames:(NSArray *)framesArray;



//根据关键词匹配type
+ (NSString *)typeForKeyword:(NSString *)keyword;
//根据台阶stairwayView转换相对于动画父视图的frame字符串
+ (NSString *)frameStringForStairway:(UIView *)stairwayView toReferenceView:(UIView *)refrenceView;

- (void)setFrameArray:(NSArray *)frameArray;
- (NSArray *)framesArray;

//是否有粒子正在活动
- (BOOL)hasAnyModels;

//清空所有的活动粒子
- (void)clearAllModels;

@end
