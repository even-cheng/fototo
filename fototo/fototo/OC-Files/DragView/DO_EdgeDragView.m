//
//  DO_EdgeDragView.m
//  DO_EdgeDragAnimation_Demo
//
//  Created by lanou on 16/7/30.
//  Copyright © 2019年 lanou. All rights reserved.
//

#import "DO_EdgeDragView.h"
#define H self.frame.size.height
#define W self.frame.size.width

@implementation DO_EdgeDragView
CGFloat x;
CGFloat y;

-(instancetype)initWithFrame:(CGRect)frame EdgeType:(EdgeType)edgetype
{
    self = [super initWithFrame:frame];
    if (self) {
        _edgetype = edgetype;
        _movePath = [UIBezierPath bezierPath];
        _originPath = [UIBezierPath bezierPath];
        self.alpha = 0.1;
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)]];
    }
    return self;
}

//根据跟踪触摸获取的movepath刷新shapelayer
-(void)setNeedsDisplayView
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
    }else{
        [_shapeLayer removeFromSuperlayer];
    }
    _shapeLayer.frame = self.bounds;
    _shapeLayer.fillColor = self.color.CGColor;
    _shapeLayer.lineWidth = 1.0f;
    _shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    _shapeLayer.path = _movePath.CGPath;
    [self.layer addSublayer:_shapeLayer];
    self.is_full = NO;
}
//根据跟踪触摸获取movepath/originPath
-(void)configMovePathWith:(CGPoint)point
{
    [_movePath removeAllPoints];
    [_originPath removeAllPoints];
    switch (_edgetype) {
        case top: {
            if (point.x>160) {
                point.x = 160;
            }
            [_movePath moveToPoint:CGPointMake(0, 0)];
            [_movePath addLineToPoint:CGPointMake(W, 0)];
            [_movePath addQuadCurveToPoint:CGPointMake(0, 0) controlPoint:point];
            point.y = 0;
            [_originPath moveToPoint:CGPointMake(0, 0)];
            [_originPath addLineToPoint:CGPointMake(W, 0)];
            [_originPath addQuadCurveToPoint:CGPointMake(0, 0) controlPoint:point];
                            
            break;
        }
        case left: {
            if (point.x>160) {
                point.x = 160;
            }
            [_movePath moveToPoint:CGPointMake(0, 0)];
            [_movePath addLineToPoint:CGPointMake(0, H)];
            [_movePath addQuadCurveToPoint:CGPointMake(0, 0) controlPoint:point];
            point.x = 0;
            [_originPath moveToPoint:CGPointMake(0, 0)];
            [_originPath addLineToPoint:CGPointMake(0, H)];
            [_originPath addQuadCurveToPoint:CGPointMake(0, 0) controlPoint:point];
            break;
        }
        case down: {
            if (point.y < H-160) {
                point.y = H-160;
            }
            [_movePath moveToPoint:CGPointMake(0, H)];
            [_movePath addLineToPoint:CGPointMake(W, H)];
            [_movePath addQuadCurveToPoint:CGPointMake(0, H) controlPoint:point];
            point.y = H;
            [_originPath moveToPoint:CGPointMake(0, H)];
            [_originPath addLineToPoint:CGPointMake(W, H)];
            [_originPath addQuadCurveToPoint:CGPointMake(0, H) controlPoint:point];
            break;
        }
        case right: {
            if (point.x < W-160) {
                point.x = W-160;
            }
            [_movePath moveToPoint:CGPointMake(W, 0)];
            [_movePath addLineToPoint:CGPointMake(W, H)];
            [_movePath addQuadCurveToPoint:CGPointMake(W,0) controlPoint:point];
            point.x = W;
            [_originPath moveToPoint:CGPointMake(W, 0)];
            [_originPath addLineToPoint:CGPointMake(W, H)];
            [_originPath addQuadCurveToPoint:CGPointMake(W,0) controlPoint:point];
            break;
        }
    }
}

- (void)beginPan:(UIPanGestureRecognizer *)pan;{
    [self panAction:pan];
}

- (void)endPan{

    [self animation];
}

- (void)reset;{
    self.alpha = 0.1;
    self.userInteractionEnabled = NO;
    [self configMovePathWith:CGPointZero];
    [self setNeedsDisplayView];
}

- (void)panAction:(UIPanGestureRecognizer *)pan{
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        [self animation];
        self.userInteractionEnabled = NO;
        
    } else if (pan.state == UIGestureRecognizerStateChanged){
        
        CGPoint translation = [pan translationInView:self];
        if (translation.x > 200) {
            pan.state = UIGestureRecognizerStateEnded;

            [_originPath removeAllPoints];
            [_originPath moveToPoint:CGPointMake(0, -H)];
            [_originPath addLineToPoint:CGPointMake(0, H*2)];
            [_originPath addQuadCurveToPoint:CGPointMake(0, -H) controlPoint:CGPointMake(W*3, H*0.5)];
            [self animation];
            
            self.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1;
            }];

        } else if (translation.x > 0) {
           
            self.alpha = 0.1;
            self.userInteractionEnabled = NO;
            CGPoint point = [pan locationInView:self];
            [self configMovePathWith:CGPointMake(translation.x, point.y)];
            [self setNeedsDisplayView];
        }
    }
}

-(void)animation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.5;
    animation.fromValue = (__bridge id _Nullable)(_movePath.CGPath);
    animation.toValue = (__bridge id _Nullable)(_originPath.CGPath);
    animation.delegate = self;
    //动画结束后保持最终状态
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [_shapeLayer addAnimation:animation forKey:nil];
    self.is_full = YES;
//    self.userInteractionEnabled = YES;
}

//- (UIViewController *)getSupreViewController
//{
////此处的self.view指的是：如果你想获取的是控制器所在的父控制器，传入的是你当前控制器的view；如果想获取的是一个view的父控制器，直接传当前view本身就可以了
//    for (UIView* next = [self superview]; next; next = next.superview) {
//        UIResponder* nextResponder = [next nextResponder];
//        if ([nextResponder isKindOfClass:[UIViewController class]]) {
//            return (UIViewController*)nextResponder;
//        }
//    }
//    return nil;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self configMovePathWith:CGPointZero];
    [self setNeedsDisplayView];
    self.userInteractionEnabled = NO;
}

//动画结束后路径靠边
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _movePath.CGPath = _originPath.CGPath;
    [self setNeedsDisplayView];
    [_shapeLayer removeAllAnimations];
    
    if (self.alpha == 1 && self.fullScreenDone) {
        self.fullScreenDone();
    }
}
//外界事件更改path，通过point 注意最后需要point靠边隐藏此view
-(void)setControllpoint:(CGPoint)controllpoint
{
    _controllpoint = controllpoint;
    [self configMovePathWith:controllpoint];
    [self setNeedsDisplayView];
}



@end
