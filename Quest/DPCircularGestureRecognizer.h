//
//  DPCircularGestureRecognizer.h
//
//  Created by Daniel Phillips on 20/08/2012.

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface DPCircularGestureRecognizer : UIGestureRecognizer

@property (nonatomic, readonly) CGPoint circleStart;
@property (nonatomic, readonly) CGPoint circleCentre;
@property (nonatomic, readonly) CGPoint lastPoint;
@property (nonatomic, readonly) CGPoint newPoint;
@property (nonatomic, readonly) CGFloat maxRadiusSize;
@property (nonatomic, readonly) CGFloat minRadiusSize;
@property (nonatomic, readonly) CGFloat velocity;
@property (nonatomic, readonly) NSTimeInterval latestUpdate;
@property (nonatomic, readonly) CGFloat rotation;
// the hole portion will take effect from the beginning of the
// gesture.
@property (nonatomic, assign) CGFloat holePortion;

@property (nonatomic, readonly) CGFloat circleCompletionProgress;
@property (nonatomic, readonly) NSInteger circlesCompleted;

- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
