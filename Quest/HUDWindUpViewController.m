//
//  HUDWindUpViewController.m
//  Quest
//
//  Created by Michael Garrido on 1/9/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import "HUDWindUpViewController.h"
#import "TKToy.h"
#import "TKMasterKey.h"

@interface HUDWindUpViewController ()
{
    CAShapeLayer* radiusLayer;
}

@end

@implementation HUDWindUpViewController

- (void) linkToy:(TKToy *)toyNode andKey:(TKMasterKey *)keyNode
{
    _linkedToy = toyNode;
    _linkedKey = keyNode;
}

- (void) releaseLinkedNodes
{
    _linkedToy = NULL;
    _linkedKey = NULL;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _windUpRadians = 0.0;
    _windUpProgression = 1.0;
    
    _windUpTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 100.0, 60.0)];
    [_windUpTotalLabel setTextColor:[UIColor redColor]];
    [_windUpTotalLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:_windUpTotalLabel];
    
    radiusLayer = [CAShapeLayer layer];
    [radiusLayer setBounds:self.view.bounds];
    [radiusLayer setPosition:self.view.center];
    [radiusLayer setFillColor:[[UIColor clearColor] CGColor]];
    [radiusLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [radiusLayer setLineWidth:3.0f];
    [radiusLayer setLineJoin:kCALineJoinRound];
    [radiusLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],nil]];
    
    [[self.view layer] addSublayer:radiusLayer];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    
    [self setupGestureRecognizers];
    
}

- (void) setupGestureRecognizers
{
    //Add a circular gesture recognizer
    DPCircularGestureRecognizer * circleGesture = [[DPCircularGestureRecognizer alloc] initWithTarget:self action:@selector(handleMovingInCircle:)];
    circleGesture.delegate = self;
    [self.view addGestureRecognizer:circleGesture];
    
    //Add a pinch gesture recognizer
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    //Add a 1touch2taps
    UITapGestureRecognizer* singleTouchDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTouchDoubleTap:)];
    singleTouchDoubleTap.numberOfTapsRequired = 2;
    singleTouchDoubleTap.numberOfTouchesRequired = 1;
    singleTouchDoubleTap.delegate = self;
    [self.view addGestureRecognizer:singleTouchDoubleTap];
    
    //Add a 2touch1tap
    UITapGestureRecognizer* doubleTouchSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTouchSingleTap:)];
    doubleTouchSingleTap.numberOfTapsRequired = 1;
    doubleTouchSingleTap.numberOfTouchesRequired = 2;
    doubleTouchSingleTap.delegate = self;
    [self.view addGestureRecognizer:doubleTouchSingleTap];
    
    //Add long press
    /*
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [longPressGesture setMinimumPressDuration:0.3];
    [self.view addGestureRecognizer:longPressGesture];
    */
    //setup gesture overrides
    //[singleTouchDoubleTap requireGestureRecognizerToFail:longPressGesture];
    //[circleGesture requireGestureRecognizerToFail:longPressGesture];
    [circleGesture requireGestureRecognizerToFail:singleTouchDoubleTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleMovingInCircle:(DPCircularGestureRecognizer *)recognizer {
    NSLog(@"moving in circle!");
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [_linkedToy setActionVectorToPoint:[recognizer locationInView:nil]];
        [self exitAtPoint:CGPointMake(0.0, 0.0)];
    }
    else
    {
    
        [self drawRadiusFromCenter:recognizer.circleCentre ThroughPoint:recognizer.newPoint];
        
        _windUpRadians+=_windUpProgression*recognizer.rotation;
        
        _windUpRotations = _windUpRadians/(2*M_PI);
        
        int maxRotations = [_linkedToy setWindUpRotations:_windUpRotations];
        NSLog(@"max rotations: %i",maxRotations);
        if (maxRotations!=0)
        {
            _windUpRotations = maxRotations;
            _windUpRadians = maxRotations*(2*M_PI);
        }
        
        [_windUpTotalLabel setText:[NSString stringWithFormat:@"%f",_windUpRotations]];
    }
}

- (void) drawRadiusFromCenter: (CGPoint)centerPoint ThroughPoint: (CGPoint)touchPoint
{
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, centerPoint.x, centerPoint.y);
    CGPathAddLineToPoint(path, NULL, touchPoint.x, touchPoint.y);
    
    [radiusLayer setPath:path];
    CGPathRelease(path);
}

- (void) handlePinch:(UIPinchGestureRecognizer *)recognizer {
    NSLog(@"pinch scale: %f",recognizer.scale);
}

- (void) handleSingleTouchDoubleTap: (UIGestureRecognizer *)recognizer
{
    NSLog(@"handleSingleTouchDoubleTap entered");
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"handleSingleTouchDoubleTap ended");
        //[_linkedToy setActionVectorToPoint:[recognizer locationInView:nil]];
    }
   
}

- (void) handleDoubleTouchSingleTap: (UIGestureRecognizer *)recognizer
{
    NSLog(@"handleDoubleTouchSingleTap entered");
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"handleDoubleTouchSingleTap ended");
        
    }
    
}

- (void) handleLongPressGesture: (UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        //[self exitAtPoint:[recognizer locationInView:nil]];
    }
}

- (void) exitAtPoint:(CGPoint) touchPoint
{
    [_linkedKey detachFromToyAtPoint:touchPoint];
    [self releaseLinkedNodes];
    [self.view removeFromSuperview];
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches began at: %@",event);
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches ended at: %@",event);
}
*/
@end
