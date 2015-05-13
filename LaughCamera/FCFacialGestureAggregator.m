//
//  FCFacialGestureAggregator.m
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//

#import <QuartzCore/QuartzCore.h>
#import "FCFacialGestureAggregator.h"

@interface FCFacialGestureAggregator()

@property (nonatomic, strong) NSMutableArray *smilesArray, *leftBlinksArray, *rightBlinksArray;

@property (nonatomic, strong) NSTimer *simileGesturesCounterInvalidatorTimer, *leftBlinkGesturesCounterInvalidatorTimer, *rightBlinkGesturesCounterInvalidatorTimer;

@property (atomic, readwrite) BOOL isSearchingForGesture;

@end

@implementation FCFacialGestureAggregator

const static int kNumberOfRecordsToStore = 30;
const static float kTimeNeedsToSmile = 1.0f ;
const static float kTimeNeedsToWink = 1.0f;
const static float kMaxTimeBetweenConsecutiveGesturesMutiplier = 2.0f;

#pragma mark - API

-(void)addGesture:(FCGestureType)gestureType
{
    FCFacialGesture *gesture = [FCFacialGesture facialGestureOfType:gestureType withTimeStamp:CACurrentMediaTime()];
    
    [self addObjectToArray:[self getArrayBasedOnGestureType:gestureType]
                    object:gesture
     withMaxRecordsToStore:kNumberOfRecordsToStore];
    
    //reset no gesture timer
    NSTimer *timer = [self getTimerBasedOnGestureType:gestureType];
    [timer invalidate];
    NSTimeInterval interval = (float)self.samplesPerSecond * (float)kMaxTimeBetweenConsecutiveGesturesMutiplier;
    timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                             target:self selector:@selector(noGesturesCameAfterAWhile:)
                                           userInfo:gesture
                                            repeats:NO];
    [self assignTimer:timer toGestureType:gestureType];
}

-(FCGestureType)checkIfRegisteredGesturesAndUpdateProgress
{
    FCGestureType gestureToReturn = FCGestureTypeNoGesture;
    
    if ([self updateProgressAndCheckIfRegisteredGesture:FCGestureTypeSmile neededTimeForGesture:kTimeNeedsToSmile])
        gestureToReturn = FCGestureTypeSmile;
    
    if ([self updateProgressAndCheckIfRegisteredGesture:FCGestureTypeLeftBlink neededTimeForGesture:kTimeNeedsToWink])
        gestureToReturn = FCGestureTypeLeftBlink;
    
    if ([self updateProgressAndCheckIfRegisteredGesture:FCGestureTypeRightBlink neededTimeForGesture:kTimeNeedsToWink])
        gestureToReturn = FCGestureTypeRightBlink;
    
    return gestureToReturn;
}

#pragma mark - Inits

-(id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.smilesArray = [[NSMutableArray alloc] initWithCapacity:kNumberOfRecordsToStore];
    self.leftBlinksArray = [[NSMutableArray alloc] initWithCapacity:kNumberOfRecordsToStore];
    self.rightBlinksArray = [[NSMutableArray alloc] initWithCapacity:kNumberOfRecordsToStore];
    
    return self;
}

#pragma mark - Timer CallsBacks

-(void)noGesturesCameAfterAWhile:(NSTimer *)timer
{
    FCFacialGesture *gesture = (FCFacialGesture *)timer.userInfo;
    [[self getArrayBasedOnGestureType:gesture.type] removeAllObjects];
    [self updateProgress:0 forGestureType:gesture.type];
}

#pragma mark - Private

-(BOOL)updateProgressAndCheckIfRegisteredGesture:(FCGestureType)type neededTimeForGesture:(NSTimeInterval)neededTimeForGesture
{
    NSArray *gestures = [self getArrayBasedOnGestureType:type];
    
    if (!gestures || gestures.count == 0)
        return NO;
    
    double lastTimestamp = 0;
    double timeRangeCounter = 0;
    for (FCFacialGesture *gesture in gestures)
    {
        if (lastTimestamp == 0)//first round
        {
            lastTimestamp = gesture.timestamp;
            continue;
        }
        double timeSinceLastGesture = gesture.timestamp - lastTimestamp;
        if (timeSinceLastGesture > (float)((float)self.samplesPerSecond * (float)4.0f))
            return NO;
        timeRangeCounter += timeSinceLastGesture;
        lastTimestamp = gesture.timestamp;
    }
    
    float progress = timeRangeCounter / neededTimeForGesture;
    [self updateProgress:progress forGestureType:type];
    return neededTimeForGesture < timeRangeCounter; //we have been gesturing for at least timeRange
}

-(void)updateProgress:(float)progress forGestureType:(FCGestureType)gestureType
{
    FCFacialGesture *facialGesutre = [FCFacialGesture facialGestureOfType:gestureType withTimeStamp:0];
    facialGesutre.precentForFullGesture = progress;
    [self.delegate didUpdateProgress:facialGesutre];
}

-(NSMutableArray *)getArrayBasedOnGestureType:(FCGestureType)gestureType
{
    NSMutableArray *array;
    if (gestureType == FCGestureTypeSmile)
    {
        array = self.smilesArray;
    }
    else if (gestureType == FCGestureTypeLeftBlink)
    {
        array = self.leftBlinksArray;
    }
    else if (gestureType == FCGestureTypeRightBlink)
    {
        array = self.rightBlinksArray;
    }
    return array;
}

-(NSTimer *)getTimerBasedOnGestureType:(FCGestureType)gestureType
{
    NSTimer *timer;
    if (gestureType == FCGestureTypeSmile)
    {
        timer = self.simileGesturesCounterInvalidatorTimer;
    }
    else if (gestureType == FCGestureTypeLeftBlink)
    {
        timer = self.leftBlinkGesturesCounterInvalidatorTimer;
    }
    else if (gestureType == FCGestureTypeRightBlink)
    {
        timer = self.rightBlinkGesturesCounterInvalidatorTimer;
    }
    return timer;
}

-(void)assignTimer:(NSTimer *)timer toGestureType:(FCGestureType)gestureType
{
    if (gestureType == FCGestureTypeSmile)
    {
        self.simileGesturesCounterInvalidatorTimer = timer;
    }
    else if (gestureType == FCGestureTypeLeftBlink)
    {
        self.leftBlinkGesturesCounterInvalidatorTimer = timer;
    }
    else if (gestureType == FCGestureTypeRightBlink)
    {
        self.rightBlinkGesturesCounterInvalidatorTimer = timer;;
    }
}

-(void)addObjectToArray:(NSMutableArray *)array object:(id)object withMaxRecordsToStore:(NSInteger)maxRecordsToStore
{
    if (array.count + 1 == maxRecordsToStore)
    {
        [array removeObjectAtIndex:0];
    }
    [array addObject:object];
}

@end
