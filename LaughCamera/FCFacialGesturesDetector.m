//
//  FacialGestureDetector.m
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FCFacialGesturesDetector.h"
#import "FCFacialGesture.h"
#import "UIDevice+ExifOrientation.h"
#import "FCFacialGestureAggregator.h"
#import "FCFacialGestureCameraCapturer.h"

@interface FCFacialGesturesDetector () <FCFacialGestureAggregatorDelegate, FCFacialGestureCameraCapturerDelegate>

@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) FCFacialGestureAggregator *gestureAggregator;
@property (nonatomic, strong) FCFacialGestureCameraCapturer *cameraCapturer;
@end


@implementation FCFacialGesturesDetector

/**
 *  if this value is too low it takes a lot of CPU, if too high the effect is bad cause detection is not happening a lot.
 */
//const float kSamplesPerSecond = 0.3;

- (id)init
{
    self = [super init];
    if (self) {
        self.gestureAggregator = [FCFacialGestureAggregator new];
        self.gestureAggregator.samplesPerSecond = 0.3;
        self.gestureAggregator.delegate = self;
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                               context:nil
                                               options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
        self.cameraCapturer = [FCFacialGestureCameraCapturer new];
        self.cameraCapturer.delegate = self;
    }
    return self;
}

-(void)startDetectionWithAVCaptureSession:(AVCaptureSession *)avSession atSampleRate:(float)sampleRate withError:(NSError **)error
{
    [self.cameraCapturer setAVCaptureWithSession:avSession atSampleRate:sampleRate withError:error];
}

-(void)stopDetection
{
    [self.cameraCapturer teardownAVCapture];
}

#pragma mark - Camera Capturer Delegate

-(void)imageFromCamera:(CIImage *)ciImage isUsingFrontCamera:(BOOL)isUsingFrontCamera
{
    ExifForOrientationType exifOrientation = [[UIDevice currentDevice] exifForCurrentOrientationWithFrontCamera:isUsingFrontCamera];
    
    NSDictionary *detectionOtions = @{ CIDetectorImageOrientation : @(exifOrientation),
                                       CIDetectorSmile : @YES,
                                       CIDetectorEyeBlink : @YES,
                                       CIDetectorAccuracy : CIDetectorAccuracyLow
                                       
                                       };
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                   options:detectionOtions];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self extractFacialGesturesFromFeatures:features];
    });
}

#pragma mark - Aggregator Delegte
-(void)didUpdateProgress:(FCFacialGesture *)gesture
{
    [self.delegate didUpdateProgress:gesture.precentForFullGesture forType:gesture.type];
}

#pragma mark - Private

-(void)extractFacialGesturesFromFeatures:(NSArray *)features
{
    unsigned long featureLength = [features count];
    
    if (featureLength == 0) {
        // No feature found => no face in the camera
        [self.gestureAggregator addGesture:FCGestureTypeNoFace];
    }
    else {
        for ( CIFaceFeature *faceFeature in features )
        {
            if (faceFeature.hasSmile)
            {
                [self.gestureAggregator addGesture:FCGestureTypeSmile];
            }
            if (faceFeature.leftEyeClosed && faceFeature.hasLeftEyePosition)
            {
                [self.gestureAggregator addGesture:FCGestureTypeLeftBlink];
            }
            if (faceFeature.rightEyeClosed && faceFeature.hasRightEyePosition)
            {
                [self.gestureAggregator addGesture:FCGestureTypeRightBlink];
            }
        }
    }
    FCGestureType registeredGestured = [self.gestureAggregator checkIfRegisteredGesturesAndUpdateProgress];
    if (registeredGestured == FCGestureTypeNoGesture)
        return;
    
    [self.delegate didRegisterFacialGestureOfType:registeredGestured];
}
@end

