//
//  SCDynamicBehaviorModel.m
//  SealChat
//
//  Created by yang on 16/5/6.
//  Copyright © 2016年 Lianxi.com. All rights reserved.
//

#import "SCDynamicBehaviorModel.h"
#import <QuartzCore/CALayer.h>
#import "SCDynamicBehaviorManager.h"

@interface SCDynamicBehaviorModel ()<UICollisionBehaviorDelegate,UIDynamicAnimatorDelegate>

@property (nonatomic, strong) NSMutableArray            *itemsArray;//添加动画的视图数组
@property (nonatomic, strong) UIView                    *referenceView;//动画的父视图(范围)
@property (nonatomic, assign) BOOL                      needPush;//是否需要添加推力
@property (nonatomic, assign) CGFloat                   deviationValue;//偏移位置，默认0
@property (nonatomic, assign) CGFloat                   useDeviationValue;//实际使用偏移位置（添加了随机变动）
@property (nonatomic, assign) CGRect                    currentRect;//当前要跳转的frame

@property (nonatomic, strong) UIDynamicAnimator         *animator;//力学行为容器
@property (nonatomic, strong) UIGravityBehavior         *gravity;//重力
@property (nonatomic, strong) UICollisionBehavior       *collision;//碰撞
@property (nonatomic, strong) UIDynamicItemBehavior     *itemBehaviour;//行为限制

@end
@implementation SCDynamicBehaviorModel

- (instancetype)initWithItems:(NSArray *)itemsArray
                       deviationValue:(CGFloat)deviationValue
                referenceView:(UIView *)referenceView
{
    self = [super init];
    if (self) {
        _itemsArray = [NSMutableArray arrayWithArray:itemsArray];
        _referenceView = referenceView;
        _deviationValue = deviationValue;
        [self pointsAnimaton];
    }
    return self;
}

- (void)dealloc
{
    _animator.delegate = nil;
    [self clearAllItems];
}


- (void)clearAllItems{
    for(UIView* view in  _itemsArray){
        [view removeFromSuperview];
        [view.layer removeAllAnimations];
    }
    [_itemsArray removeAllObjects];
}


+ (instancetype)createDynamicBehaviorModelWithItems:(NSArray *)itemsArray
                                             deviationValue:(CGFloat)deviationValue
                                      referenceView:(UIView *)referenceView
{
    return [[SCDynamicBehaviorModel alloc]initWithItems:itemsArray
                                         deviationValue:deviationValue
                                          referenceView:referenceView];
}
- (void)pointsAnimaton
{
    for (UIImageView *imageView in _itemsArray) {
//        CGRect currentRect = CGRectFromString(_framesArray[_currentIndex]);
        CGRect frontRect = imageView.frame;
        CGRect currentRect = [self realityCurrentRect];
        
        CGFloat cX = 0;
        CGFloat cY = 0;
        
        _useDeviationValue = _deviationValue + arc4random() % 5 * 3;//偏移基础上添加随机值
        
        CGFloat distance = (currentRect.origin.x + currentRect.size.width / 2.0 + _useDeviationValue) - (frontRect.origin.x + frontRect.size.width / 2.0);
        cX += frontRect.origin.x + frontRect.size.width / 2.0 + distance * 0.3;
        cY = frontRect.origin.y - 150;
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];//关键帧动画
        CGMutablePathRef thePath = CGPathCreateMutable();
        bounceAnimation.delegate = self;
        CGPathMoveToPoint(thePath, NULL, frontRect.origin.x + frontRect.size.width / 2.0, imageView.center.y);
        //出界判断
        CGFloat toX = currentRect.origin.x + currentRect.size.width / 2.0 + _useDeviationValue;
        if (toX > currentRect.origin.x + currentRect.size.width) {
            toX = currentRect.origin.x + currentRect.size.width;
        }
        if (toX < currentRect.origin.x) {
            toX = currentRect.origin.x;
        }
        CGPathAddQuadCurveToPoint(thePath, NULL, cX, cY, toX, currentRect.origin.y);
        bounceAnimation.path = thePath;
        bounceAnimation.duration = .6 + ((arc4random() % 3) * 0.04);//动画时间（添加随机性）
        bounceAnimation.fillMode = kCAFillModeForwards;//与removedOnCompletion = NO 共同作用，动画停留在结束位置
        bounceAnimation.removedOnCompletion = NO;//与fillMode = kCAFillModeForwards 共同作用，动画停留在结束位置
        [imageView.layer addAnimation:bounceAnimation forKey:@"move"];
    }
}
- (void)addBehaviour
{
    if (!_animator) {//力学行为容器
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:_referenceView];
        _animator.delegate = self;
    }else{
        [_animator removeAllBehaviors];
    }
    //重力行为
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] initWithItems:_itemsArray];
    }
    
    [_animator addBehavior:_gravity];
    
    CGRect currentRect =  [self realityBehaviourCurrentRect];//CGRectFromString(_framesArray[_currentIndex]);
    //碰撞行为
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc]
                      initWithItems:_itemsArray];
        
        _collision.translatesReferenceBoundsIntoBoundary = NO;//是否与referenceView边界碰撞
        _collision.collisionDelegate = self;
    }

    
    [_collision addBoundaryWithIdentifier:@"barrier" fromPoint:currentRect.origin
                                  toPoint:CGPointMake(currentRect.origin.x + currentRect.size.width, currentRect.origin.y)];
    
    [_animator addBehavior:_collision];
    
    if (!_itemBehaviour) {//行为限制
        _itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:_itemsArray];
        _itemBehaviour.allowsRotation = NO;//是否允许旋转
        _itemBehaviour.elasticity = 0.6;//弹力系数(0.0 ~ 1.0)
        _itemBehaviour.friction = 0.5;//摩擦系数(0.0 ~ 1.0)
    }
    [_animator addBehavior:_itemBehaviour];
    _needPush = YES;
}
#pragma mark - UICollisionBehaviorDelegate
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    if (_needPush) {
        _needPush = NO;        
        //设置推行为
        UIPushBehavior* push = [[UIPushBehavior alloc] initWithItems:_itemsArray mode:UIPushBehaviorModeInstantaneous];
        [push setAngle:-M_PI/2 magnitude:.2f];//angle力的角度,magnitude里的大小
        [_animator addBehavior:push];
    }
}
#pragma mark - UIDynamicAnimatorDelegate
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
//    if (_currentIndex < _framesArray.count - 1) {
//        _currentIndex++;
//        [self pointsAnimaton];
//    }
    CGRect lastFrame = CGRectFromString([self.framesArray lastObject]);
    if (_currentRect.origin.y < lastFrame.origin.y) {//当前Fram不是最后一个
        [self pointsAnimaton];
    }

    else{
        NSLog(@"结束");
        if ([_delegate respondsToSelector:@selector(SCDynamicBehaviorModel:finishedWithItems:)]) {
            [_delegate SCDynamicBehaviorModel:self finishedWithItems:_itemsArray];
        }
    }
}
#pragma mark -  CAKeyframeAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CGRect currentRect = _currentRect;//CGRectFromString(_framesArray[_currentIndex]);
    for (UIImageView *imageView in _itemsArray) {
        [imageView.layer removeAnimationForKey:@"move"];
        //出界判断
        CGFloat toX = currentRect.origin.x + currentRect.size.width / 2.0 + _useDeviationValue;
        if (toX > currentRect.origin.x + currentRect.size.width) {
            toX = currentRect.origin.x + currentRect.size.width;
        }
        if (toX < currentRect.origin.x) {
            toX = currentRect.origin.x;
        }
        imageView.center = CGPointMake(toX, currentRect.origin.y - imageView.frame.size.height / 2.0);
    }
    [self addBehaviour];
}
//抛物线的时候计算当前frame
- (CGRect)realityCurrentRect
{
    for (NSInteger i = 0; i < self.framesArray.count; i++ ) {
        CGRect rect = CGRectFromString(self.framesArray[i]);
        if (rect.origin.y > _currentRect.origin.y) {
            _currentRect = rect;
            break;
        }

    }
    return _currentRect;
}
//力学行为的时候计算当前frame
- (CGRect)realityBehaviourCurrentRect
{
    for (NSInteger i = 0; i < self.framesArray.count; i++ ) {
        CGRect rect = CGRectFromString(self.framesArray[i]);
        if (rect.origin.y >= _currentRect.origin.y) {
            _currentRect = rect;
            break;
        }
        
    }
    return _currentRect;
}
//每次从[SCDynamicBehaviorManager defaultManager]取 保证最新frame数组
- (NSArray *)framesArray
{
    return [[SCDynamicBehaviorManager defaultManager] framesArray];
}


@end
