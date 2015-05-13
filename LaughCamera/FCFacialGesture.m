//
//  FacialGesture.m
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//

#import "FCFacialGesture.h"

@implementation FCFacialGesture

+(FCFacialGesture *)facialGestureOfType:(FCGestureType)type withTimeStamp:(double)timestamp
{
    FCFacialGesture *newGesture = [FCFacialGesture new];
    
    newGesture.type = type;
    newGesture.timestamp = timestamp;
    
    return newGesture;
}

+(NSString *)gestureTypeToString:(FCGestureType)type
{
    NSString *typString;
    switch (type) {
        case FCGestureTypeSmile:
            typString = @"Smiling";
            break;
        case FCGestureTypeLeftBlink:
            typString = @"Left Blink";
            break;
        case FCGestureTypeRightBlink:
            typString = @"Rigt Blink";
            break;
        case FCGestureTypeNoGesture:
            typString = @"No Gesture";
            break;
        case FCGestureTypeNoFace:
            typString = @"No Face";
            break;
        default:
            typString = @"No Gesture - Default";
            break;
    }
    return typString;
}


@end
