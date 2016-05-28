//
//  SCDynamicBehaviorManager.m
//  SealChat
//
//  Created by yang on 16/5/9.
//  Copyright © 2016年 Lianxi.com. All rights reserved.
//

#import "SCDynamicBehaviorManager.h"
#import "SCDynamicBehaviorModel.h"

#define DBV_DEFAULT_NUMBER (3)//动画个体数量,默认
#define DBV_INTERVAL_TIME (0.3f)//时间间隔，默认
#define DBV_MIDDLE_SPACE (20.0f)//偏移位置，默认

@interface SCDynamicBehaviorManager ()<SCDynamicBehaviorModelDelegate>

@property (nonatomic, strong) NSMutableArray    *modelContainer;
@property (nonatomic, strong) NSArray           *framesArray;
@property (nonatomic, strong) NSArray           *itemsArray;


@end
@implementation SCDynamicBehaviorManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _modelContainer = [NSMutableArray array];
        _framesArray    = [NSMutableArray array];
    }
    return self;
}
+ (instancetype) defaultManager
{
    @synchronized(self) {
        static SCDynamicBehaviorManager *defaultInstance = nil;
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultInstance = [[self alloc] init];
        });
        return defaultInstance;
    }
}
/**
 * @breaf 创建动画
 *
 * @param view              动画的父视图(范围)
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
                               frames:(NSArray *)framesArray
{
    if (type == nil || type.length == 0) {
        return;
    }
    if (number == 0) {
        number = DBV_DEFAULT_NUMBER;
    }
    if (intervalTime <= 0) {
        intervalTime = DBV_INTERVAL_TIME;
    }
    middleSpace = middleSpace;
    
    //type 动画类型 待定
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [window convertRect:window.bounds toView:view];
    
    //动画视图初始位置
    CGFloat cH = 30.0f;
    CGFloat cW = 30.0f;
    CGFloat cX = window.bounds.size.width / 2.0 - cW / 2.0;
    CGFloat cY = frame.origin.y - 30;
    
    if(framesArray){
        _framesArray = framesArray;
    }

    for (NSInteger i = 0 ; i < number; i++) {
        NSInteger middle = number / 2;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake( cX, cY, cW, cH)];
        [view addSubview:imageView];
        UILabel *label = [[UILabel alloc]initWithFrame:imageView.bounds];
        label.text = type;
        [imageView addSubview:label];
                
        NSArray *items = @[imageView];
        
        NSTimeInterval useIntervalTime = intervalTime + arc4random() % 5 * 0.1 * intervalTime;//出现的时间加随机
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * useIntervalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addBehaviorWithItems:items
                        deviationValue:(i - middle) * middleSpace
                         referenceView:view];
        });

    }
}
//添加动画
- (void)addBehaviorWithItems:(NSArray *)itemsArray
              deviationValue:(CGFloat)deviationValue
               referenceView:(UIView *)referenceView
{
    SCDynamicBehaviorModel *behaviorModel = [SCDynamicBehaviorModel createDynamicBehaviorModelWithItems:itemsArray
                                                                                         deviationValue:deviationValue
                                                                                          referenceView:referenceView];
    behaviorModel.delegate = self;
    [_modelContainer addObject:behaviorModel];
}
#pragma mark - SCDynamicBehaviorModelDelegate
- (void)SCDynamicBehaviorModel:(SCDynamicBehaviorModel *)dynamicBehaviorModel finishedWithItems:(NSArray *)itemsArray
{
    [dynamicBehaviorModel clearAllItems];
    [_modelContainer removeObject:dynamicBehaviorModel];
}
//根据关键词匹配type
+ (NSString *)typeForKeyword:(NSString *)keyword
{
    if (keyword.length) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Keyword_emoji" ofType:@"plist"];
        NSDictionary *emojiDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSString *type = [emojiDict valueForKey:[keyword lowercaseString]];
        return type;
    }
    return nil;
}
//根据台阶stairwayView转换相对于动画父视图的frame字符串
+ (NSString *)frameStringForStairway:(UIView *)stairwayView toReferenceView:(UIView *)refrenceView
{
    if (stairwayView == nil || refrenceView == nil) {
        return nil;
    }
    CGRect frame = [stairwayView convertRect:stairwayView.bounds toView:refrenceView];
    return NSStringFromCGRect(frame);
}
- (void)setFrameArray:(NSArray *)frameArray
{
    @synchronized (self) {
        _framesArray = frameArray;
    }
}
- (NSArray *)framesArray
{
    @synchronized (self) {
        if (_framesArray) {
            return _framesArray;
        }
        return nil;
    }
}


//是否有粒子正在活动
- (BOOL)hasAnyModels{
    return (_modelContainer.count >0);
}

//清空所有的活动粒子
- (void)clearAllModels{
    for(SCDynamicBehaviorModel *model in _modelContainer){
        [model clearAllItems];
    }
    [_modelContainer removeAllObjects];
}


@end
