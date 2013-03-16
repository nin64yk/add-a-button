/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */

#import "HardwareController.h"
#include "TestApp.h"

#import <AVFoundation/AVCaptureOutput.h>
#import <CoreVideo/CVPixelBuffer.h>

@implementation HardwareController

@synthesize timestamp;
@synthesize captureSession;
@synthesize glView;
@synthesize pixelBuffer;
@synthesize motionManager;
@synthesize g_scale;
@synthesize restartingCamera;
@synthesize accelerometer_available;
@synthesize device_motion_available;
@synthesize pointcloudApplication;

@synthesize imageView;
@synthesize mapView;

@synthesize messageView;
@synthesize lbl;
@synthesize startButton;
@synthesize load1Button;
@synthesize load2Button;
@synthesize save1Button;
@synthesize save2Button;




- (void)startCamera {
    [self.captureSession startRunning];
	restartingCamera = NO;
}

- (void) restartCamera {
	if (self.restartingCamera)
		return;
	
	restartingCamera = YES;
	
	if ([self.captureSession isRunning])
		[self.captureSession stopRunning];
	
	[self startCamera];
}

-(void)eventHandler:(id)data {
    if ([[data name] isEqualToString:@"AVCaptureSessionRuntimeErrorNotification"]) {
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(restartCamera) userInfo:nil repeats:NO];
    } else if ([[data name] isEqualToString:@"AVCaptureSessionInterruptionEndedNotification"]) {
        [self.captureSession startRunning];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {		
		[self.view setFrame:[[UIScreen mainScreen] bounds]];
    }
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.restartingCamera = NO;
	self.accelerometer_available = NO;
	self.device_motion_available = NO;
	
	[UIApplication sharedApplication].statusBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack; 
		
	CGRect rect = [[UIScreen mainScreen] bounds];
	
	glView = [[GLView alloc] initWithFrame:rect];
	
	[self.glView.window setFrame:rect];
	
	[self.glView setFrame:[[UIScreen mainScreen] applicationFrame]];
    
    // Double the resolution on iPhone 4 and 4s etc.
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        self.g_scale = [UIScreen mainScreen].scale;
    } else {
        self.g_scale = 1.0f;
    }
    
    if ([self.glView respondsToSelector:@selector(setContentScaleFactor:)])
    {
        [self.glView setContentScaleFactor: g_scale];
    }
	
	[glView setDelegate:self];
    glView.multipleTouchEnabled = YES;
	[self setView:glView];
	
	[self initCapture];
	
	motionManager = [[CMMotionManager alloc] init];
	
	if (self.motionManager.accelerometerAvailable) {
		accelerometer_available = true;
		[self.motionManager startAccelerometerUpdates];
	}
	
	if (self.motionManager.deviceMotionAvailable) {
		device_motion_available = true;
		[self.motionManager startDeviceMotionUpdates];
	}
    
    
    // Creating a messageView
    messageView = [[UIView alloc] initWithFrame:rect];
    messageView.opaque = NO;
    messageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    [glView addSubview:messageView];

    // Creating an UILabel
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    lbl.hidden = YES;
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.text = @"";
    [messageView addSubview:lbl];
    
    // Creating a button
    startButton = [[UILabel alloc] initWithFrame:CGRectMake(0, 907, 250, 100)];
    startButton.text = @"start";
    startButton.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:27];
    startButton.textAlignment = UITextAlignmentCenter;
    startButton.backgroundColor = [UIColor grayColor];
    [messageView addSubview:startButton];
    
    save1Button = [[UILabel alloc] initWithFrame:CGRectMake(260, 907, 125, 100)];
    save1Button.text = @"save1";
    save1Button.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:27];
    save1Button.textAlignment = UITextAlignmentCenter;
    save1Button.backgroundColor = [UIColor grayColor];
    [messageView addSubview:save1Button];
    
    save2Button = [[UILabel alloc] initWithFrame:CGRectMake(390, 907, 125, 100)];
    save2Button.text = @"save2";
    save2Button.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:27];
    save2Button.textAlignment = UITextAlignmentCenter;
    save2Button.backgroundColor = [UIColor grayColor];
    [messageView addSubview:save2Button];
    
    load1Button = [[UILabel alloc] initWithFrame:CGRectMake(521, 907, 125, 100)];
    load1Button.text = @"load1";
    load1Button.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:27];
    load1Button.textAlignment = UITextAlignmentCenter;
    load1Button.backgroundColor = [UIColor grayColor];
    [messageView addSubview:load1Button];
    
    load2Button = [[UILabel alloc] initWithFrame:CGRectMake(650, 907, 125, 100)];
    load2Button.text = @"load2";
    load2Button.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:27];
    load2Button.textAlignment = UITextAlignmentCenter;
    load2Button.backgroundColor = [UIColor grayColor];
    [messageView addSubview:load2Button];

    imageView = [[UIView alloc] initWithFrame:rect];
    imageView.opaque = NO;
    imageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    [messageView addSubview:imageView];
    
    mapView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map.jpg"]];
    [mapView setFrame:CGRectMake(0, 0, 768, 907)];
    mapView.hidden = NO;
    [imageView addSubview:mapView];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   	CGPoint pt = [[touches anyObject] locationInView:self.glView];
	if (pointcloudApplication) {
		pointcloudApplication->on_touch_moved(pt.x, pt.y);
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint pt = [[touches anyObject] locationInView:self.glView];
	if (pointcloudApplication) {
		pointcloudApplication->on_touch_ended(pt.x, pt.y);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    
    if ([touch view] == imageView) {
        NSLog(@"\nTouch imageView\n");
        [mapView removeFromSuperview];
    }
    
	CGPoint pt = [[touches anyObject] locationInView:self.glView];
    pt_x = pt.x;
    
    if (pointcloudApplication) {
        pointcloudApplication->on_touch_started(pt.x, pt.y);
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint pt = [[touches anyObject] locationInView:self.glView];
	if (pointcloudApplication) {
		pointcloudApplication->on_touch_cancelled(pt.x, pt.y);
	}	
}


#import <sys/utsname.h>

struct utsname systemInfo;

const char*
machineName()
{
    uname(&systemInfo);
	
    return systemInfo.machine;
}

- (void)startGraphics {
	if (pointcloudApplication)
		pointcloudApplication->on_resume();
}

- (void)stopGraphics {
	if (pointcloudApplication)
		pointcloudApplication->on_pause();
}

- (void)drawView:(GLView*)view {
	CVReturn lockResult = CVPixelBufferLockBaseAddress (self.pixelBuffer, 0);
	if(lockResult == kCVReturnSuccess) {
		if (accelerometer_available) {
			if (!motionManager.accelerometerActive)
				[motionManager startAccelerometerUpdates];
			
			CMAccelerometerData *accelerometerData = motionManager.accelerometerData;
			if (accelerometerData) {
				CMAcceleration acceleration = accelerometerData.acceleration;
				
				pointcloudApplication->on_accelerometer_update(acceleration.y, acceleration.x, acceleration.z, timestamp);
			}
		}
		if (device_motion_available) {
			if (!motionManager.deviceMotionActive)
				[motionManager startDeviceMotionUpdates];
			
			CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
			if (deviceMotion) {
				CMAcceleration device_acceleration = deviceMotion.userAcceleration;
				CMRotationRate device_rotation_rate = deviceMotion.rotationRate;
                CMAcceleration gravity = deviceMotion.gravity;
				
				pointcloudApplication->on_device_motion_update(device_acceleration.y, 
															   device_acceleration.x,
															   device_acceleration.z,
															   device_rotation_rate.y, 
															   device_rotation_rate.x, 
															   device_rotation_rate.z,
                                                               gravity.y,
                                                               gravity.x,
                                                               gravity.z,
                                                               timestamp);
			}
		}
		
		char* ba = (char*)CVPixelBufferGetBaseAddress(self.pixelBuffer);
		pointcloudApplication->render_frame(ba, CVPixelBufferGetDataSize(self.pixelBuffer), timestamp);
		
		CVPixelBufferUnlockBaseAddress (self.pixelBuffer, 0);
        
        pointcloud_state pc_state = pointcloud_get_state();
        
        // ms = messagebox, pc = pointcloud
        glView->ms_x = pointcloudApplication->pc_x;
        glView->ms_y = pointcloudApplication->pc_y;
//        
//        NSString *documentsDir = [NSString stringWithString:[NSHomeDirectory() stringbyappendingComponent:@"documents"]];
//        
//        NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:nil];
//        int fileCount = [list count];
//        
//        if (fileCount  == 0) {
//            NSLog(@"\nNothing\n");
//        } else {
//            NSLog(@"\nIt has map file\n");
//        }
//        

        
        if ((glView->ms_x != -1) || ( 0 <= glView->ms_x && glView->ms_x < pointcloudApplication->context_width) || (0 <= glView->ms_y && glView->ms_y < pointcloudApplication->context_height) ){ //|| pt_x){
            lbl.hidden = NO;
            [lbl setCenter:CGPointMake(glView->ms_x + (lbl.frame.size.width)/2, glView->ms_y - (lbl.frame.size.height)/2)];
            lbl.text = @"Hello, World!";
            
        } else  {
            lbl.hidden = YES;
        }
        if (pc_state == POINTCLOUD_RELOCALIZING /**< Tracking is lost, trying to relocalize. */
            || pc_state == POINTCLOUD_INITIALIZING
            || pc_state == POINTCLOUD_IDLE) {
            lbl.hidden = YES;
        }
        if (hiddenImageView) {
            mapView.hidden = YES;
        }
        
        
		return;
	}
}


-(void)setupView:(GLView*)view {
}


- (void)initCapture {
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		
	captureSession = [[AVCaptureSession alloc] init];
		
	NSArray *arr = [AVCaptureDevice devices];
	
	AVCaptureDevice *device = nil;
	NSError *outError = nil;

    for(int i=0; i<[arr count] && device == nil; i++) {
        AVCaptureDevice *d = [arr objectAtIndex:i];
		if (d.position == AVCaptureDevicePositionBack && [d hasMediaType: AVMediaTypeVideo]) {
			device = d;
		}
    }
	
	if (device == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera found" 
														message:@"You need a device with a back-facing camera to run this app." 
													   delegate:self 
											  cancelButtonTitle:@"Quit"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    	
	AVCaptureFocusMode wantedFocusMode = AVCaptureFocusModeContinuousAutoFocus;
    
	if ([device isFocusModeSupported: wantedFocusMode]) {
		if ([device lockForConfiguration: &outError]) {
			[device setFocusMode: wantedFocusMode];
			[device unlockForConfiguration];
		} else {
			NSLog(@"lockForConfiguration ERROR: %@", outError);
		}
	}
	
    AVCaptureDeviceInput *devInput = [[[AVCaptureDeviceInput alloc] initWithDevice:device error:&outError] autorelease];
    
    if (!devInput) {
        NSLog(@"ERROR: %@",outError);
        return;
    }
        	
	if (device == nil) {
		NSLog(@"Device is nil");
	}
	
	AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    output.alwaysDiscardsLateVideoFrames = YES;
    
    NSMutableDictionary *videoSettings = [[[NSMutableDictionary alloc] init] autorelease];
    
    [videoSettings setValue:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString*) kCVPixelBufferPixelFormatTypeKey];

	[output setVideoSettings:videoSettings];
    
    [output setSampleBufferDelegate:self queue:dispatch_get_current_queue()];
	    
    [self.captureSession addInput:devInput];
        
    [self.captureSession addOutput:output];
    
    double max_fps = 30;
    NSString *deviceName = [NSString stringWithUTF8String:machineName()];
    if ([deviceName isEqualToString:@"iPhone2,1"] || [deviceName isEqualToString:@"iPhone3,1"]) {
        max_fps = 15;//Lower frame rate on iPhone 3GS and iPhone 4 for increased image detection performance
    }
    
    NSLog(@"FPS %f", max_fps);
    
    for(int i = 0; i < [[output connections] count]; i++) {
        AVCaptureConnection *conn = [[output connections] objectAtIndex:i];
        if (conn.supportsVideoMinFrameDuration) {
            conn.videoMinFrameDuration = CMTimeMake(1, max_fps);
        }
        if (conn.supportsVideoMaxFrameDuration) {
            conn.videoMaxFrameDuration = CMTimeMake(1, max_fps);
        }
    }

    [self.captureSession setSessionPreset: AVCaptureSessionPresetMedium];
    
    NSArray *events = [NSArray arrayWithObjects: 
                       AVCaptureSessionRuntimeErrorNotification, 
                       AVCaptureSessionErrorKey, 
                       AVCaptureSessionDidStartRunningNotification, 
                       AVCaptureSessionDidStopRunningNotification, 
                       AVCaptureSessionWasInterruptedNotification, 
                       AVCaptureSessionInterruptionEndedNotification, 
                       nil];
        
    for (id e in events) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(eventHandler:)
         name:e
         object:nil];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startCamera) userInfo:nil repeats:NO];
}


- (void) realCaptureOutput:(id) pixData {
    NSData * data = (NSData *) pixData;
    
    CMSampleBufferRef sampleBuffer = (CMSampleBufferRef) [data bytes];

    timestamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));

    CVImageBufferRef imgBuff = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFRetain(imgBuff);
    CVPixelBufferRef pixBuff = imgBuff;
    
    int w = CVPixelBufferGetWidth(pixBuff);
    int h = CVPixelBufferGetHeight(pixBuff);
	
    if (w == 0 && !restartingCamera) {
        NSLog(@"Bad image data, restarting session...?!");
        [self.captureSession stopRunning];
        restartingCamera = true;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startCamera) userInfo:nil repeats:NO];        
        return;
    }
	
	// Create the application once we get the first camera frame
	if (!pointcloudApplication) {
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString* documentsDirectory = [paths objectAtIndex:0]; // User-accesible file system path 
		NSString *resourcePath = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];

		pointcloudApplication = new TestApp(self.glView.bounds.size.width, 
											self.glView.bounds.size.height, 
											w,
											h,
											POINTCLOUD_BGRA_8888,
											[resourcePath cStringUsingEncoding:[NSString defaultCStringEncoding]], 
											[documentsDirectory cStringUsingEncoding:[NSString defaultCStringEncoding]],
											machineName(),
											g_scale);
	}	

	self.pixelBuffer = pixBuff;
	
    [glView drawView];
	
    self.pixelBuffer = nil;
	
    CFRelease(imgBuff);
}

// Capture delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    if (sampleBuffer == nil) {
        NSLog(@"Received nil sampleBuffer from %@ with connection %@",captureOutput,connection);
        return; 
    }
	
    CFRetain(sampleBuffer);
        
    NSData *data = [[NSData alloc] initWithBytesNoCopy:sampleBuffer length:4 freeWhenDone:NO];

	// Make sure that we handle the camera data in the main thread
	if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(realCaptureOutput:) withObject:data waitUntilDone:true];
    } else {
        [self realCaptureOutput: data];
    }

    [data release];
	
    CFRelease(sampleBuffer);    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"Memory warning received");
}

- (void)viewDidUnload {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation==UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
//	return YES;
	return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
	return UIInterfaceOrientationPortrait;
}

- (void)dealloc {
	[captureSession release];
	[super dealloc];
}

@end

// Forward decl.
static char *getRGBA(UIImage * image);

// Simple interface from C++ layer to read PNG resource files as RGBA
bool read_png_image(const char *filename, char **data, int *width, int *height) {
	NSString* fileNameNS = [NSString stringWithUTF8String:filename];
	UIImage* image = [UIImage imageNamed:fileNameNS];
	if (image) {
		*width = (int)image.size.width;
		*height = (int)image.size.height;
		*data = getRGBA(image);		
		return true;
	}
	else {
		NSLog(@"No such image %@", fileNameNS);
	}
	return false;
}


// Get RGBA data from an UIImage

static char * getRGBA(UIImage * image) {
	size_t width = CGImageGetWidth(image.CGImage);
	size_t height = CGImageGetHeight(image.CGImage);
	size_t bitsPerComponent = 8;
	size_t bytesPerRow = width * 4;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); assert(colorSpace);
	
	void *data = malloc(bytesPerRow * height); assert(data);
	memset(data,0,bytesPerRow * height);
	
	CGContextRef context = CGBitmapContextCreate(data, 
												 width, 
												 height, 
												 bitsPerComponent, 
												 bytesPerRow, 
												 colorSpace, 
												 kCGImageAlphaPremultipliedLast);
	
	assert(context);
	
	CGColorSpaceRelease(colorSpace);
	
	// Draw image on bitmap
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
	
	CGContextRelease(context);
	
	return (char*) data;
}

