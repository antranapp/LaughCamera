//
//  FacialGestureDetector.h
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//

#import <Foundation/Foundation.h>
#import "FCFacialGesture.h"

@class UIView;
@class UIImage;

@protocol FCFacialDetectorDelegate <NSObject>

-(void)didRegisterFacialGestureOfType:(FCGestureType)facialGestureType;
@optional
-(void)didUpdateProgress:(float)progress forType:(FCGestureType)facialGestureType;

@end

@interface FCFacialGesturesDetector : NSObject

@property (nonatomic, weak) id<FCFacialDetectorDelegate> delegate;

/**
 *  UIView displaying the camera output, default is nil with no output.
 */
@property (nonatomic, weak) UIView *cameraPreviewView;

-(void)startDetectionWithAVCaptureSession:(AVCaptureSession *)avSession atSampleRate:(float)sampleRate withError:(NSError **)error;
-(void)stopDetection;
-(void)imageFromCamera:(CIImage *)ciImage isUsingFrontCamera:(BOOL)isUsingFrontCamera;

@end
