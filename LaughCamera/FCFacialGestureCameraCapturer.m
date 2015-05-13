//
//  FCFacialGestureCameraCapturer.m
//  Pods
//
//  Created by Tran Le on 02/03/15.
//
//

#import "FCFacialGestureCameraCapturer.h"

@interface FCFacialGestureCameraCapturer() <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, readwrite) BOOL isUsingFrontCamera;
@property (nonatomic, readwrite) double lastSampleTimestamp;

@property (nonatomic, readwrite) float sampleRate;

@end

@implementation FCFacialGestureCameraCapturer


-(void)setAVCaptureWithSession:(AVCaptureSession*) avSession atSampleRate:(float)sampleRate withError:(NSError **)error
{
    self.sampleRate = sampleRate;
    self.session = avSession;
    
    // Make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    self.videoDataOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA) };
    // discard if the data output queue is blocked
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    // create a serial dispatch queue used for the sample buffer delegate
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ( [self.session canAddOutput:self.videoDataOutput] ){
        [self.session addOutput:self.videoDataOutput];
    }
    
    // get the output for doing face detection.
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
}

-(AVCaptureDeviceInput *)getCaptureDeviceInput:(NSError **)error;
{
    AVCaptureDevice *device;
    
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
    
    // find the front facing camera
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (d.position == desiredPosition) {
            device = d;
            self.isUsingFrontCamera = YES;
            break;
        }
    }
    // fall back to the default camera.
    if( nil == device )
    {
        self.isUsingFrontCamera = NO;
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // get the input device
    return [AVCaptureDeviceInput deviceInputWithDevice:device error:error];
}

- (void)teardownAVCapture
{
    self.videoDataOutput = nil;
    if (self.videoDataOutputQueue) {
        self.videoDataOutputQueue = nil;
    }
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if ([connection isVideoOrientationSupported]) {
        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }
    
    if (!self.lastSampleTimestamp){
        self.lastSampleTimestamp = CACurrentMediaTime();
    }
    else{
        double now = CACurrentMediaTime();
        double timePassedSinceLastSample = now - self.lastSampleTimestamp;
        
        if (timePassedSinceLastSample < self.sampleRate)
            return;
        self.lastSampleTimestamp = now;
    }
    
    // get the image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                      options:(__bridge NSDictionary *)attachments];
    if (attachments) {
        CFRelease(attachments);
    }
    [self.delegate imageFromCamera:ciImage isUsingFrontCamera:self.isUsingFrontCamera];
}


@end
