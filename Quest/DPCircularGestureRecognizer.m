//
//  DPCircularGestureRecognizer.m
//
//  Created by Daniel Phillips on 20/08/2012.

#import "DPCircularGestureRecognizer.h"

@interface DPCircularGestureRecognizer (DPPrivate)
- (BOOL)validatePoint:(CGPoint)newPoint;
@end

@implementation DPCircularGestureRecognizer
@synthesize circleStart = _circleStart;
@synthesize lastPoint = _lastPoint;
@synthesize newPoint = _newPoint;
@synthesize maxRadiusSize = _maxRadiusSize;
@synthesize minRadiusSize = _minRadiusSize;
@synthesize velocity = _velocity;
@synthesize latestUpdate = _latestUpdate;
@synthesize circleCentre = _circleCentre;
@synthesize holePortion = _holePortion;

@synthesize circlesCompleted;
@synthesize circleCompletionProgress;

- (void)reset{
    [super reset];
    _circleStart        = CGPointZero;
    _circleCentre       = CGPointZero;
    _minRadiusSize      = 0.0f;
    _maxRadiusSize      = 1000.0f;
    _latestUpdate       = 0.0f;
    _holePortion        = 0.0f;
    if (self.state == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (void)setHolePortion:(CGFloat)holePortion{
    if(holePortion >= 0.0 && holePortion < 1.0f){
        _holePortion = holePortion;
    }else{
        [NSException raise:@"DPCircularGestureRecognizer" format:@"The value for property holePortion must be between 0.0 and less then 1.0"];
    }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event{
    
    // Fail when more than 1 finger detected.
    if (touches.count > 1) {
        [self setState:UIGestureRecognizerStateFailed];
    }
    
    [super touchesBegan:touches withEvent:event];
    UITouch * touch     = [touches anyObject];
    _latestUpdate       = touch.timestamp;
    _circleStart        = [touch locationInView:self.view];
    _newPoint           = _circleStart;
    
    // what is the min and max radius ?
    // we want a circle from the closest edge until 1/3 to the centre
    _maxRadiusSize = MIN(self.view.bounds.size.width, self.view.bounds.size.height) / 2;
    _minRadiusSize = self.maxRadiusSize * _holePortion;
    
    _circleCentre = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    if(![self validatePoint:self.circleStart]){
        NSLog(@"validation failed");
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if ([self state] == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateBegan];
    } else {
        [self setState:UIGestureRecognizerStateChanged];
    }
    
    UITouch * touch = [touches anyObject];
    _lastPoint  = [touch previousLocationInView:self.view];
    _newPoint   = [touch locationInView:self.view];
    
    // get points on grid with center as reference.
    CGPoint translatedOld = CGPointMake((self.lastPoint.x - _circleCentre.x), (self.lastPoint.y - _circleCentre.y));
    CGPoint translatedNew = CGPointMake((self.newPoint.x - _circleCentre.x), (self.newPoint.y - _circleCentre.y));
    
    
    CGFloat newestPoint         = atan2(translatedNew.y, translatedNew.x);
    CGFloat previousPoint       = atan2(translatedOld.y, translatedOld.x);
    
    // At this point we would like to calculate the velocity of the
    // users finger.
    // we know the two angles but if they occur either side of the origin of
    // the radian then the math will calculate that the difference is
    // almost the total circle which is wrong.
    // we must check for one angle being very small and the other very large
    // if it is then compensate to get the correct differential angle.
    
    CGFloat helfCircle = M_PI;
    
    CGFloat smallValueCap = (helfCircle / 2) * -1.0;
    CGFloat largeValueCap = (helfCircle / 2);
    
    if((newestPoint < smallValueCap && previousPoint > largeValueCap)
       || (newestPoint > largeValueCap && previousPoint < smallValueCap)){
        // Example possible values (new ===> previous)
        //  3.064366 ===> -3.135779
        // -3.135495 ===> 3.135495
        float angle1 = helfCircle - fabs(newestPoint);
        float angle2 = helfCircle - fabs(previousPoint);
        float diff = angle1 + angle2;
        
        // if the new point is small then we was going clockwise so,
        // angle should be positive, else negative
        _rotation = newestPoint < smallValueCap ? fabs(diff) : fabs(diff) * -1.0;
        
    }else{
        _rotation = newestPoint - previousPoint;
    }
    
    
    if (_rotation>0.0) {
        //rotating clockwise
        NSLog(@"rotating CW");
    } else {
        //rotating clockwise
        NSLog(@"rotating counter CW");
    }
    
    NSLog(@"rotation: %f",_rotation);
    
    NSTimeInterval difference = (touch.timestamp - self.latestUpdate);
    
    // ( 1 second divide angle ) / time difference
    _velocity = (1.0f * _rotation) / difference;
    
    _latestUpdate = touch.timestamp;
    
    
    if(![self validatePoint:self.newPoint]){
        [self setState:UIGestureRecognizerStateEnded];
    }else{
        // if we are inside the circle. check we're still in our direction.
        
        if (self.state == UIGestureRecognizerStatePossible) {
            [self setState:UIGestureRecognizerStateChanged];
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded: %@",event);
    [super touchesEnded:touches withEvent:event];
    
    if ([self state] == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateEnded");
        [self setState:UIGestureRecognizerStateEnded];
    } else {
        NSLog(@"UIGestureRecognizerStateFailed");
        [self setState:UIGestureRecognizerStateFailed];
    }
    
    [self reset];
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled: %@",event);
    [self touchesCancelled:touches withEvent:event];
    [self reset];
}

- (BOOL)validatePoint:(CGPoint)myPoint{
    // calculate how far from centre we are with Pythagorean
    // √ a2 + b2
    CGFloat a = abs(myPoint.x - (self.view.bounds.size.width/2));
    CGFloat b = abs(myPoint.y - (self.view.bounds.size.height/2));
    CGFloat distanceFromCentre = sqrt(pow(a,2) + pow(b,2));
    
    if((distanceFromCentre > self.minRadiusSize) && (distanceFromCentre < self.maxRadiusSize)){
        return YES;
    }else{
        // not inside doughnut
        return NO;
    }
}

@end
