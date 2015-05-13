//
//  FCFacialGestureCameraCapturer.h
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CIImage;
@class UIView;

@protocol FCFacialGestureCameraCapturerDelegate <NSObject>

-(void)imageFromCamera:(CIImage *)ciImage isUsingFrontCamera:(BOOL)isUsingFrontCamera;

@end


@interface FCFacialGestureCameraCapturer : NSObject

@property (nonatomic, weak) id<FCFacialGestureCameraCapturerDelegate> delegate;

-(void)setAVCaptureWithSession:(AVCaptureSession*) avSession atSampleRate:(float)sampleRate withError:(NSError **)error;
-(void)teardownAVCapture;
@end
