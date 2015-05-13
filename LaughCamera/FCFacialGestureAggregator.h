//
//  FacialGestureAggregator.h
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//

#import <Foundation/Foundation.h>
#import "FCFacialGesture.h"

@protocol FCFacialGestureAggregatorDelegate <NSObject>

-(void)didUpdateProgress:(FCFacialGesture *)gesture;

@end

@interface FCFacialGestureAggregator : NSObject

@property (nonatomic, readwrite) float samplesPerSecond;
@property (nonatomic, weak) id<FCFacialGestureAggregatorDelegate> delegate;

-(void)addGesture:(FCGestureType)gestureType;
-(FCGestureType)checkIfRegisteredGesturesAndUpdateProgress;

@end
