/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreMotion/CoreMotion.h>

#import "GLView.h"

class PointCloudApplication;

@interface HardwareController : UIViewController <GLViewDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate> {
	AVCaptureSession *captureSession;
    GLView *glView;
    
    // To create an UILabel message.
    UIView *messageView;
    UILabel *lbl;
    UILabel *startButton;
    UILabel *load1Button;
    UILabel *load2Button;
    UILabel *save1Button;
    UILabel *save2Button;
    UIView *imageView;
    UIImageView *mapView;
   
    //touch
    CGFloat pt_x;
    
    BOOL hiddenImageView;
    
    CVPixelBufferRef pixelBuffer;
    Float64 timestamp;
	CMMotionManager *motionManager;
	
	PointCloudApplication* pointcloudApplication;
    
	BOOL restartingCamera;
	BOOL accelerometer_available;
	BOOL device_motion_available;
	double g_scale;
}

- (void)startGraphics;

- (void)stopGraphics;

- (void)startCamera;

- (void)restartCamera;

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (void)drawView:(GLView*)view;

- (void)setupView:(GLView*)view;

- (void)realCaptureOutput: (id)pixelData;

- (void)initCapture;

- (void)eventHandler:(id)data;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) GLView *glView;

@property (nonatomic, retain) UIView *imageView;
@property (nonatomic, retain) UIImageView *mapView;

@property (nonatomic, retain) UIView *messageView;
@property (nonatomic, retain) UILabel *lbl;
@property (nonatomic, retain) UILabel *startButton;
@property (nonatomic, retain) UILabel *load1Button;
@property (nonatomic, retain) UILabel *load2Button;
@property (nonatomic, retain) UILabel *save1Button;
@property (nonatomic, retain) UILabel *save2Button;

@property (nonatomic) CVPixelBufferRef pixelBuffer;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic) double g_scale;
@property (nonatomic) Float64 timestamp;
@property (nonatomic) BOOL restartingCamera;
@property (nonatomic) BOOL accelerometer_available;
@property (nonatomic) BOOL device_motion_available;
@property (nonatomic) PointCloudApplication* pointcloudApplication;

@end
