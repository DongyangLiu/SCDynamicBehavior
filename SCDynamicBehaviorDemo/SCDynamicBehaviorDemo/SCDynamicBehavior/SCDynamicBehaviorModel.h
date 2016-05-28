//
//  SCDynamicBehaviorModel.h
//  SealChat
//
//  Created by yang on 16/5/6.
//  Copyright © 2016年 Lianxi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SCDynamicBehaviorModel;
@protocol SCDynamicBehaviorModelDelegate <NSObject>
///动画结束回调
- (void)SCDynamicBehaviorModel:(SCDynamicBehaviorModel *)dynamicBehaviorModel finishedWithItems:(NSArray *)itemsArray;

@end
@interface SCDynamicBehaviorModel : NSObject

@property (nonatomic, weak) id <SCDynamicBehaviorModelDelegate> delegate; 
/**
 * @breaf 创建动画
 * 
 * @param itemsArray        添加动画的视图数组
 * @param deviationValue    偏移位置，默认0
 * @param referenceView     动画的父视图(范围)
 */
+ (instancetype)createDynamicBehaviorModelWithItems:(NSArray *)itemsArray
                                     deviationValue:(CGFloat)deviationValue
                                      referenceView:(UIView *)referenceView;

//去掉所有的粒子
- (void)clearAllItems;
@end
