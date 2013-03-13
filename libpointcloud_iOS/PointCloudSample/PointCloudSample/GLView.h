#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@protocol GLViewDelegate
- (void)drawView:(UIView *)theView;
- (void)setupView:(UIView *)theView;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end

@interface GLView : UIView 
{
    
@private

	// The GL context
    EAGLContext *context;
	
	// Buffers
	GLuint framebuffer;
    GLuint renderbuffer;
    GLuint depthbuffer;
    
    // Label
//    UILabel *messagebox;

    id<GLViewDelegate> delegate;
    
    @public
//    // Coordination of massagebox
    float ms_x;
    float ms_y;
//    
//    int count;
    
}

//Label
//- (UILabel *)newLabelWithOffset:(float)offset numberOfLines:(NSUInteger)lines;

@property (assign) id<GLViewDelegate>  delegate;

@property (nonatomic, retain) UILabel *messagebox;  //Label

@property (nonatomic, retain) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) drawView;
@end
