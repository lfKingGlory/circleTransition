//
//  YYLoginTranslation.m
//  YYLoginTranslation
//
//  Created by yy on 2017/7/31.
//  Copyright © 2017年 yy. All rights reserved.
//

#import "YYLoginTranslation.h"
#import "YYLoginViewController.h"
#import "YYFirstViewController.h"
#import "UIView+YYExtension.h"
#import "POP.h"

#define YYScreenW [UIScreen mainScreen].bounds.size.width
#define YYScreenH [UIScreen mainScreen].bounds.size.height

@interface YYLoginTranslation () <CAAnimationDelegate>

//做弧线运动的那个圆
@property (strong, nonatomic)UIView *circularAnimView;
@property (weak, nonatomic) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation YYLoginTranslation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    if (self.doLogin)//登录转场动画
    {
        __block UIView* containerView = [transitionContext containerView];
        YYFirstViewController* toVC = (YYFirstViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        YYLoginViewController* fromVC = (YYLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        [UIView animateWithDuration:0.15 animations:^{
            fromVC.view.backgroundColor = [UIColor whiteColor];
        }completion:^(BOOL finished) {
            [fromVC.view removeFromSuperview];
        }];
        
        //4、logo文字缩小、移动
        [containerView addSubview:fromVC.LoginWord];
        CGFloat proportion = toVC.navWord.yy_width / fromVC.LoginWord.yy_width;
        CGPoint newPosition = [toVC.view convertPoint:toVC.navWord.center fromView:toVC.navView];
        [UIView animateWithDuration:0.4 delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromVC.LoginWord.yy_centerX = newPosition.x;
            fromVC.LoginWord.yy_centerY = newPosition.y;
            fromVC.LoginWord.transform = CGAffineTransformMakeScale(proportion, proportion);
        } completion:^(BOOL finished) {
            
        }];

        //5、圆(登录加载的那个圆)的移动，因为登录页面的那个圆有正在动的sublayer，所以这里新建了个圆来做动画
        UIView *circularAnimView = [[UIView alloc] initWithFrame:fromVC.LoginAnimView.frame];
        self.circularAnimView = circularAnimView;
        circularAnimView.layer.cornerRadius = circularAnimView.yy_width*0.5;
        circularAnimView.layer.masksToBounds = YES;
        circularAnimView.frame = fromVC.LoginAnimView.frame;
        circularAnimView.backgroundColor = fromVC.LoginAnimView.backgroundColor;
        [containerView addSubview:circularAnimView];
        
        CGFloat bntSize = 44;
        fromVC.LoginAnimView.layer.cornerRadius = bntSize*0.5;
        CGFloat originalX = toVC.view.yy_width-bntSize-15;
        CGFloat originalY = toVC.view.yy_height-bntSize-15-49;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, (circularAnimView.yy_x+circularAnimView.yy_width*0.5), (circularAnimView.yy_y+circularAnimView.yy_height*0.5));
        CGPathAddQuadCurveToPoint(path, NULL, YYScreenW*0.9, circularAnimView.yy_y+circularAnimView.yy_height, (originalX+circularAnimView.yy_width*0.5), (originalY+circularAnimView.yy_height*0.5));
        CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animate.delegate = self;
        animate.duration = 0.4;
        animate.beginTime = CACurrentMediaTime()+0.15;
        animate.fillMode = kCAFillModeForwards;
        animate.repeatCount = 0;
        animate.path = path;
        animate.removedOnCompletion = NO;
        CGPathRelease(path);
        [circularAnimView.layer addAnimation:animate forKey:@"circleMoveAnimation"];
        
        //导航栏出现
        UIView *navView = [[UIView alloc] init];
        navView.frame = toVC.navView.frame;
        navView.backgroundColor = toVC.navView.backgroundColor;
        [containerView insertSubview:navView atIndex:1];
        navView.alpha = 0.0;
        [UIView animateWithDuration:0.6 delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            navView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
        
        //背景出现、移动
        UIImageView *backImage = [[UIImageView alloc] init];
        backImage.image = toVC.backImage.image;
        backImage.frame = toVC.backImage.frame;
        [containerView insertSubview:backImage atIndex:1];
        backImage.alpha = 0.0;
        backImage.yy_y += 100;
        
        POPSpringAnimation *backImageMove = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        backImageMove.fromValue = [NSValue valueWithCGRect:CGRectMake(backImage.yy_centerX, backImage.yy_centerY, backImage.yy_width, toVC.backImage.yy_height)];
        backImageMove.toValue = [NSValue valueWithCGRect:CGRectMake(backImage.yy_centerX, backImage.yy_centerY-100, backImage.yy_width, backImage.yy_height)];
        backImageMove.beginTime = CACurrentMediaTime()+0.15+0.2;
        backImageMove.springBounciness = 5.0;
        backImageMove.springSpeed = 10.0;
        [backImage pop_addAnimation:backImageMove forKey:nil];
        
        [UIView animateWithDuration:0.6 delay:0.15+0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            backImage.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self cleanContainerView:containerView];//移除所有子控件
            [containerView addSubview:toVC.view];//将目标控制器的vc添加上去
            [transitionContext completeTransition:YES];//标志转场结束
            containerView = nil;
            [fromVC reloadView];//登录界面重载UI
        }];
    }
    else//退出登录转场动画
    {
        UIView *containerView = [transitionContext containerView];
        YYLoginViewController* toVC = (YYLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        YYFirstViewController* fromVC = (YYFirstViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    
        CGPoint maskCenter = [fromVC.view convertPoint:fromVC.addView.center toView:containerView];
        CGFloat radius = [self calculateDistanceWithPoint:maskCenter otherPoint:CGPointMake(0, 0)];
        
        CGRect r = CGRectMake(maskCenter.x, maskCenter.y, 0.01, 0.01);
        UIBezierPath *path1 = [UIBezierPath bezierPathWithOvalInRect:r];
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(r, -radius, -radius)];
        
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = path2.CGPath;
        fromVC.view.layer.mask = mask;
    
        
        CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskLayerAnimation.fromValue = (__bridge id)(path2.CGPath);
        maskLayerAnimation.toValue = (__bridge id)((path1.CGPath));
        maskLayerAnimation.duration = [self transitionDuration:transitionContext];
        maskLayerAnimation.removedOnCompletion = NO;
        maskLayerAnimation.fillMode = kCAFillModeForwards;
        maskLayerAnimation.delegate = self;
        [mask addAnimation:maskLayerAnimation forKey:@"path"];
        
    }
}

- (UIImage *)snapshotImageWithView:(UIView *)v {
    UIGraphicsBeginImageContextWithOptions(v.bounds.size, v.opaque, 0);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (CGFloat)calculateDistanceWithPoint:(CGPoint)p1 otherPoint:(CGPoint)p2 {
    return sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2));
}

/** 移除containerView的子控件 */
- (void)cleanContainerView:(UIView *)containerView
{
    int i = [[NSString stringWithFormat:@"%lu",(containerView.subviews.count-1)] intValue];
    for (; i >= 0; i--)
    {
        UIView *subView = containerView.subviews[i];
        [subView removeFromSuperview];
    }
}

/** 核心动画动画代理 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    if ([self.circularAnimView.layer animationForKey:@"circleMoveAnimation"] == anim)
    {
        /** 这里是在做加号按钮内部的白色加号的伸展开的效果 */
        //画线
        CGRect rect = self.circularAnimView.frame;
        CGPoint centerPoint = CGPointMake(rect.size.width*0.5, rect.size.height*0.5);
        
        //贝瑟尔线
        UIBezierPath *path1 = [UIBezierPath bezierPath];
        [path1 moveToPoint:centerPoint];
        [path1 addLineToPoint:CGPointMake(rect.size.width*0.5, rect.size.height*0.25)];
        UIBezierPath *path2 = [UIBezierPath bezierPath];
        [path2 moveToPoint:centerPoint];
        [path2 addLineToPoint:CGPointMake(rect.size.width*0.25, rect.size.height*0.5)];
        UIBezierPath *path3 = [UIBezierPath bezierPath];
        [path3 moveToPoint:centerPoint];
        [path3 addLineToPoint:CGPointMake(rect.size.width*0.5, rect.size.height*0.75)];
        UIBezierPath *path4 = [UIBezierPath bezierPath];
        [path4 moveToPoint:centerPoint];
        [path4 addLineToPoint:CGPointMake(rect.size.width*0.75, rect.size.height*0.5)];
        
        //ShapeLayer
        CAShapeLayer *shape1 = [self makeShapeLayerWithPath:path1 lineWidth:rect.size.width*0.07];
        [self.circularAnimView.layer addSublayer:shape1];
        CAShapeLayer *shape2 = [self makeShapeLayerWithPath:path2 lineWidth:rect.size.width*0.07];
        [self.circularAnimView.layer addSublayer:shape2];
        CAShapeLayer *shape3 = [self makeShapeLayerWithPath:path3 lineWidth:rect.size.width*0.07];
        [self.circularAnimView.layer addSublayer:shape3];
        CAShapeLayer *shape4 = [self makeShapeLayerWithPath:path4 lineWidth:rect.size.width*0.07];
        [self.circularAnimView.layer addSublayer:shape4];
        
        //动画
        CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        checkAnimation.duration = 0.25f;
        checkAnimation.fromValue = @(0.0f);
        checkAnimation.toValue = @(1.0f);
        checkAnimation.delegate = self;
        
        [shape1 addAnimation:checkAnimation forKey:@"checkAnimation"];
        [shape2 addAnimation:checkAnimation forKey:@"checkAnimation"];
        [shape3 addAnimation:checkAnimation forKey:@"checkAnimation"];
        [shape4 addAnimation:checkAnimation forKey:@"checkAnimation"];
    } else {
        [self.transitionContext completeTransition:![self. transitionContext transitionWasCancelled]];
        [[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view removeFromSuperview];
    }
}

- (CAShapeLayer *)makeShapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth
{
    CAShapeLayer *shape=[CAShapeLayer layer];
    shape.lineWidth = lineWidth;
    shape.fillColor = [UIColor clearColor].CGColor;
    shape.strokeColor = [UIColor whiteColor].CGColor;
    shape.lineCap = kCALineCapRound;
    shape.lineJoin = kCALineJoinRound;
    shape.path = path.CGPath;
    
    return shape;
}

@end
