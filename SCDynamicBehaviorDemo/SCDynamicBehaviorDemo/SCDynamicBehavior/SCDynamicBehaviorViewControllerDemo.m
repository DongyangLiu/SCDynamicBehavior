//
//  SCDynamicBehaviorViewControllerDemo.m
//  SealChat
//
//  Created by yang on 16/5/9.
//  Copyright © 2016年 Lianxi.com. All rights reserved.
//

#import "SCDynamicBehaviorViewControllerDemo.h"
#import "SCDynamicBehaviorManager.h"

@interface SCDynamicBehaviorViewControllerDemo ()
@property (nonatomic, strong) NSMutableArray            *framesArr;
@property (nonatomic, strong) UITextField               *textField;
@end

@implementation SCDynamicBehaviorViewControllerDemo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"行为动画Demo";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_textField) {
        
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 20, 150, 30)];
        _textField.font = [UIFont systemFontOfSize:15];
        _textField.textColor = [UIColor blackColor];
        _textField.placeholder = @"输入关键字";
        _textField.text = @"恭喜";
        _textField.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_textField];
    }
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 64, 60, 30)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
//    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(200, 64, 60, 30)];
//    [button2 setTitle:@"change" forState:UIControlStateNormal];
//    button2.titleLabel.font = [UIFont systemFontOfSize:15];
//    button2.backgroundColor = [UIColor greenColor];
//    [button2 addTarget:self action:@selector(buttonClicked2:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button2];
}
- (void)buttonClicked:(UIButton *)button
{
    if ([_textField canResignFirstResponder]) {
        [_textField resignFirstResponder];
    }
    _framesArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i ++) {
        CGRect frame = CGRectMake((i % 2) * (self.view.frame.size.width - 100), 200 + i * 50, 100, 20);
        [_framesArr addObject:NSStringFromCGRect(frame)];
    }

    [[SCDynamicBehaviorManager defaultManager] showDynamicBehaviorViewInView:self.view
                                                                        type:[SCDynamicBehaviorManager typeForKeyword:_textField.text]
                                                                      number:0
                                                                intervalTime:0
                                                                 middleSpace:0
                                                                      frames:_framesArr];
}
//- (void)buttonClicked2:(UIButton *)button
//{
//    if ([_textField canResignFirstResponder]) {
//        [_textField resignFirstResponder];
//    }
//    _framesArr = [NSMutableArray array];
//    for (NSInteger i = 0; i < 10; i ++) {
//        CGRect frame = CGRectMake((i % 2) * (self.view.frame.size.width - 100), 200 + i * 100, 100, 20);
//        [_framesArr addObject:NSStringFromCGRect(frame)];
//    }
//    
//    [[SCDynamicBehaviorManager defaultManager] setFrameArray:_framesArr];
//}
@end
