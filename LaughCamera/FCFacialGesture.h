//
//  FacialGesture.h
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FCGestureType) {
    FCGestureTypeSmile,
    FCGestureTypeLeftBlink,
    FCGestureTypeRightBlink,
    FCGestureTypeNoGesture,
    FCGestureTypeNoFace
};

@interface FCFacialGesture : NSObject

@property (nonatomic, readwrite) FCGestureType type;
@property (nonatomic, readwrite) double timestamp;
@property (nonatomic, readwrite) float precentForFullGesture;

+(FCFacialGesture *)facialGestureOfType:(FCGestureType)type withTimeStamp:(double)timestamp;

+(NSString *)gestureTypeToString:(FCGestureType)type;

@end
