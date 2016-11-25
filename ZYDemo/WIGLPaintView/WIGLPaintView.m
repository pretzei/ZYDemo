//
//  WIGLPaintView.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/10/10.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "WIGLPaintView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES1/gl.h>
#import "GLProgram.h"
#import "WIGLContext.h"


#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#define Middle_CGPoint(start, end) CGPointMake(start.x + (end.x - start.x) / 2, start.y + (end.y - start.y) / 2)
#define Distance_CGPoints(start, end) sqrt((end.x-start.x)*(end.x-start.x) + (end.y - start.y) * (end.y - start.y))

static NSString * const kWIGLPaintFragmentShaderString = SHADER_STRING (
                                                             
    precision mediump float;

    uniform vec4 SourceColor;
    uniform sampler2D Texture;
    varying vec2 TextureCoordsOut;
     
    void main()
    {
        // mask will be only used to calculate texture pixel
        vec4 mask = texture2D(Texture, TextureCoordsOut);
        
        // texture pixel need the alpha value
        float grey = dot(mask.rgb, vec3(0.3,0.6,0.1));
        
        // color for one texture pixel    
        gl_FragColor = vec4(SourceColor.rgb, grey);
        
    }
                                                                 
);

static NSString * const kWIGLPaintVertexShaderString = SHADER_STRING(

    attribute vec4 Position; // output vPosition from the input vec4 position info

    attribute vec2 TextureCoords;

    varying vec2 TextureCoordsOut;

    void main(void)
    {
        gl_Position = Position;
        TextureCoordsOut = TextureCoords;
    }
                                                              
);

static NSString * const kWIGLDrawVertexShaderString = SHADER_STRING (
                                                                 
attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsOut;

void main(void)
{
    gl_Position = Position;
    TextureCoordsOut = TextureCoords;
}
                                                                 
);

static NSString * const kWIGLDrawFragmentShaderString = SHADER_STRING(
                                                              
precision mediump float;
uniform vec4 SourceColor;
uniform sampler2D Texture;
varying vec2 TextureCoordsOut;

void main()
{
    vec4 mask = texture2D(Texture, TextureCoordsOut);
    gl_FragColor = vec4(mask.rgb, 1.0);
}

                                                              
);

typedef NS_ENUM(NSInteger, touchType) {
    touchesBegan = 0,
    touchesMoved,
    touchesEnded,
};

@interface WIGLPaintView () {
    CGSize _boundsSizeAtFrameBufferEpoch;
}

@property (nonatomic) CAEAGLLayer *eaglLayer;

@property (nonatomic) GLuint frameBuffer; // 帧缓冲区
@property (nonatomic) GLuint colorRenderBuffer; // 渲染缓冲区

@property (nonatomic) GLuint positionSlot; // Position参数
@property (nonatomic) GLuint colorSlot; // uniform类型的SourceColor参数
@property (nonatomic) GLint textureSlot;
@property (nonatomic) GLint textureCoordsSlot;

@property (nonatomic) GLuint glName;

@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) NSMutableArray *points;

@property (nonatomic) CGSize displaySize;


@end

@implementation WIGLPaintView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image {
    if (self = [super initWithFrame:frame]) {
        _backgroundImage = image;
        [self setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    
    return [[[self class] alloc] initWithFrame:CGRectZero image:image];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, _boundsSizeAtFrameBufferEpoch) &&
        !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        [self destroyDisplayFramebuffer];
        [self createDisplayFrameBuffer];
        [self clearRenderView];
    }
}

- (void)dealloc {
    [self destroyDisplayFramebuffer];
}

#pragma mark setup

- (void)setup {

    [self setupPoints];
    [self setupLayer];
    //[self setupDepthBuffer];

    [self createDisplayFrameBuffer];
}

- (void)setupPoints {
    _points = [[NSMutableArray alloc] init];
    _previousPoint = CGPointZero;
}

- (void)setupLayer {
    
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupRenderBuffer {
    if (!_colorRenderBuffer) {
        glGenRenderbuffers(1, &_colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
        [[[WIGLContext sharedContext] context] renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    }
}

- (void)setupFrameBuffer {
    if (!_frameBuffer) {
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    }
    
    // Add to end of setupFrameBuffer
    //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

//- (void)setupDepthBuffer {
//    glGenRenderbuffers(1, &_depthRenderBuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
//}

- (void)unsetupRenderBuffer {
    if (_colorRenderBuffer) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
}

- (void)unsetupFrameBuffer {
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

#pragma mark 创建和删除buffer环境

- (void)createDisplayFrameBuffer {
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    if ( (backingWidth == 0) || (backingHeight == 0) )
    {
        [self destroyDisplayFramebuffer];
        return;
    }
    
    _displaySize.width = (CGFloat)backingWidth;
    _displaySize.height = (CGFloat)backingHeight;
    glViewport(0, 0, backingWidth, backingHeight);
    
    _boundsSizeAtFrameBufferEpoch = self.bounds.size;
    
}

- (void)destroyDisplayFramebuffer {
    [self unsetupRenderBuffer];
    [self unsetupFrameBuffer];
}

#pragma mark 切换program

- (void)usePaintProgram {
    GLProgram *
    paintProgram = [[WIGLContext sharedContext] programForVertexShaderString:kWIGLPaintVertexShaderString fragmentShaderString:kWIGLPaintFragmentShaderString];
    if (!paintProgram.initialized) {
        [paintProgram addAttribute:@"Position"];
        [paintProgram addAttribute:@"TextureCoords"];
        
        if (![paintProgram link]) {
            NSString *progLog = [paintProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [paintProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [paintProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            paintProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }

    [WIGLContext setActiveShaderProgram:paintProgram];
    _positionSlot = [paintProgram attributeIndex:@"Position"];
    
    // 即将_colorSlot 与 shader中的SourceColor参数绑定起来
    // 采用的是uniform类型
    _colorSlot = [paintProgram uniformIndex:@"SourceColor"];
    
    _textureSlot = [paintProgram uniformIndex:@"Texture"];
    _textureCoordsSlot = [paintProgram attributeIndex:@"TextureCoords"];
    
    glUniform4f(_colorSlot, 1.0f, 0.0f, 0.0f, 1.0f);  //画笔颜色
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_textureCoordsSlot);
    [self preparePaintOpenGLESTexture];
}

- (void)useDrawProgram {
  
    GLProgram *drawProgram = [[WIGLContext sharedContext] programForVertexShaderString:kWIGLDrawVertexShaderString fragmentShaderString:kWIGLDrawFragmentShaderString];
    if (!drawProgram.initialized) {
        [drawProgram addAttribute:@"Position"];
        [drawProgram addAttribute:@"TextureCoords"];
        
        if (![drawProgram link]) {
            NSString *progLog = [drawProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [drawProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [drawProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            drawProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    
    [WIGLContext setActiveShaderProgram:drawProgram];
    
    _positionSlot = [drawProgram attributeIndex:@"Position"];
    // 即将_colorSlot 与 shader中的SourceColor参数绑定起来
    // 采用的是uniform类型
    _colorSlot = [drawProgram uniformIndex:@"SourceColor"];
    
    _textureSlot = [drawProgram uniformIndex:@"Texture"];
    _textureCoordsSlot = [drawProgram attributeIndex:@"TextureCoords"];
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_textureCoordsSlot);
    
    [self prepareDrawImageViaOpenGLES:_backgroundImage];
}

- (void)clearRenderView {
    [self useDrawProgram];
    
    [[WIGLContext sharedContext] presentBufferForDisplay];
    
    [self usePaintProgram];
}

#pragma mark 属性

- (CGSize)displaySize {
    if (CGSizeEqualToSize(_displaySize, CGSizeZero)) {
        return self.bounds.size;
    } else {
        return _displaySize;
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [self clearRenderView];
}

#pragma mark 绘制方法

- (void)drawFrom:(CGPoint)start to:(CGPoint)end touchType:(NSInteger)touchType {
    
    if (CGPointEqualToPoint(start, end) || touchType == touchesBegan) {
        [self drawCGPointViaOpenGLESTexture:end inFrame:CGRectMake(0, 0, self.displaySize.width, self.displaySize.height)];
        return;
    }
    
    NSArray *tmpPoints = [self CGPointsViaBezeierFrom:start to:end];
    
    NSLog(@"_points : %@ %ld", _points, _points.count);
    
    [self drawCGPointsViaOpenGLESTexture:tmpPoints inFrame:CGRectMake(0, 0, self.displaySize.width, self.displaySize.height)];
}

- (void)drawCGPointViaOpenGLESTexture:(CGPoint)point inFrame:(CGRect)rect {
 
    CGFloat lineWidth = 5.0;
    GLfloat vertices[] = {
        -1 + 2 * (point.x - lineWidth) / rect.size.width, 1 - 2 * (point.y + lineWidth) / rect.size.height, 0.0f, // 左下
        -1 + 2 * (point.x + lineWidth) / rect.size.width, 1 - 2 * (point.y + lineWidth) / rect.size.height, 0.0f, // 右下
        -1 + 2 * (point.x - lineWidth) / rect.size.width, 1 - 2 * (point.y - lineWidth) / rect.size.height, 0.0f, // 左上
        -1 + 2 * (point.x + lineWidth) / rect.size.width, 1 - 2 * (point.y - lineWidth) / rect.size.height, 0.0f }; //右上
    
    // Load the vertex data
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    GLfloat texCoords[] = {
        0,0,
        1,0,
        0,1,
        1,1
    };
    glVertexAttribPointer(_textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); // 从0开始绘制4个点, 即两个三角形(012, 123)
   
    [[WIGLContext sharedContext] presentBufferForDisplay];
    
}

- (void)drawCGPointsViaOpenGLESTexture:(NSArray *)points inFrame:(CGRect)rect {
    CGFloat lineWidth = 5.0;
    for (id rawPoint in points) {
        CGPoint point = [rawPoint CGPointValue];
        GLfloat vertices[] = {
            -1 + 2 * (point.x - lineWidth) / rect.size.width, 1 - 2 * (point.y + lineWidth) / rect.size.height, 0.0f, // 左下
            -1 + 2 * (point.x + lineWidth) / rect.size.width, 1 - 2 * (point.y + lineWidth) / rect.size.height, 0.0f, // 右下
            -1 + 2 * (point.x - lineWidth) / rect.size.width, 1 - 2 * (point.y - lineWidth) / rect.size.height, 0.0f, // 左上
            -1 + 2 * (point.x + lineWidth) / rect.size.width, 1 - 2 * (point.y - lineWidth) / rect.size.height, 0.0f }; //右上
        
        const GLubyte indices[] = {
            0, 1, 2, // 三角形0
            1, 2, 3  // 三角形1
        };
        
        //之前将_positionSlot与shader中的Position绑定起来, 这里将顶点数据vertices与_positionSlot绑定起来
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
        
        GLfloat texCoords[] = {
            0,0,
            1,0,
            0,1,
            1,1
        };
        glVertexAttribPointer(_textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
        
        //通过index来绘制vertex,
        //参数1表示图元类型, 参数2表示索引数据的个数(不一定是要绘制的vertex的个数), 参数3表示索引数据格式(必须是GL_UNSIGNED_BYTE等).
        //参数4表示存放索引的数组(使用VBO:索引数据在VBO中的偏移量;不使用VBO:指向CPU内存中的索引数据数组).
        //相比glDrawArrays, 其优势在于:
        //通过index指定了要绘制的6个的vertex(用index对应),而1,2(index)重复了,所以实际只绘制0,1,2,3(index)对应的四个vertex
        
        glDrawElements(GL_TRIANGLE_STRIP, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
    }
    [[WIGLContext sharedContext] presentBufferForDisplay];
}

#pragma mark prepare渲染模型

- (void)prepareDrawImageViaOpenGLES:(UIImage *)image {


    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glDeleteTextures(1, &_glName);
    glGenTextures(1, &_glName);
    glBindTexture(GL_TEXTURE_2D, _glName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    [self prepareImageDataAndTexture:image];
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, _glName);
    glUniform1i(_textureSlot, 5);
    
    glBlendFunc(GL_ONE, GL_ZERO);
    
    GLfloat vertices[] = {
        -1, -1, 0,   //左下
        1,  -1, 0,   //右下
        -1, 1,  0,   //左上
        1,  1,  0 }; //右上
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    GLfloat texCoords[] = {
        0, 0,//左下
        1, 0,//右下
        0, 1,//左上
        1, 1,//右上
    };
    glVertexAttribPointer(_textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)preparePaintOpenGLESTexture {
    
    // 添加纹理贴图以消除锯齿
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND); // 混合模式
    
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glDeleteTextures(1, &_glName);  //删除之前的的texture，之前没有这一步内存爆炸，imageData会一只存在gl里不释放
    glGenTextures(1, &_glName);
    glBindTexture(GL_TEXTURE_2D, _glName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    // 贴图与原图不一样大, 这里采用简单的线性插值来调整图像
    // 纹理需要被缩小到适合多边形的尺寸
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    // 纹理需要被放大到适合多边形的尺寸
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    [self prepareImageDataAndTexture:[UIImage imageNamed:@"Particle"]];
    
    // 画笔1050, 与glBlendFunc(GL_SRC_ALPHA, GL_ONE);配合. 且脚本中使用mask.rgb
    // [self prepareImageDataAndTexture:[UIImage imageNamed:@"dm-1050-1"]];
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, _glName);
    
    glUniform1i(_textureSlot, 5);
    
    // 参数1: 源颜色, 即将要拿去加入混合的颜色. 纹理原图.
    // 参数2: 目标颜色, 即做处理之前的原来颜色. 原来颜色.
    //    glBlendFunc(GL_ZERO, GL_ZERO);                        // 黑色矩形. SRC为0, DST为0
    //    glBlendFunc(GL_ZERO, GL_ONE);                         // 目标颜色不受texture影响
    
    //    glBlendFunc(GL_ONE, GL_ZERO);                         // 纹理原图
    //    glBlendFunc(GL_ONE, GL_ONE);                          // 白色圆(不带黑色部分). 直接相加.
    //    glBlendFunc(GL_ONE, GL_ONE_MINUS_DST_ALPHA);          // 纹理原图
    
    //    glBlendFunc(GL_SRC_COLOR, GL_ZERO);                   // 纹理原图
    //    glBlendFunc(GL_SRC_COLOR, GL_ONE);                    // 白色圆(不带黑色部分).
    
    //    glBlendFunc(GL_DST_COLOR, GL_ZERO);                   // 黑框矩形, 中间白色圆变为透明.源颜色
    //    glBlendFunc(GL_DST_COLOR, GL_ONE);                    // 部分透明的白色圆, 目标白色则纯白圆, 目标深色则透明圆.
    
    //    glBlendFunc(GL_SRC_ALPHA, GL_ZERO);                   // 纹理原图, 渐变部分消失, 白色圆偏小
    //    glBlendFunc(GL_SRC_ALPHA, GL_ONE);                    // 白色圆(不带黑色部分). 常用于表达光亮效果.
    
    //    glBlendFunc(GL_DST_ALPHA, GL_ZERO);                   // 纹理原图, 渐变部分消失, 白色圆偏小
    //    glBlendFunc(GL_DST_ALPHA, GL_ONE);                    // 白色圆
    //    glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);    // 纹理原图
    
    //    glBlendFunc(GL_ONE_MINUS_SRC_COLOR, GL_ZERO);         // 黑色矩形, 圆周边缘类似半透明灰白
    //    glBlendFunc(GL_ONE_MINUS_SRC_COLOR, GL_ONE);          // 白色圆圈, 中间透明
    
    //    glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_ZERO);         // 黑色矩形, 圆周边缘类似半透明灰白
    //    glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_ONE);          // 白色圆圈, 中间透明
    
    //    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_ZERO);         // 纹理原图
    //    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_ONE);          // 目标颜色不受texture影响
    
    //    glBlendFunc(GL_SRC_ALPHA_SATURATE, GL_ZERO);          // 黑色矩形, 圆周边缘类似半透明灰白
    
    // 源颜色全取,目标颜色:若该像素的源颜色透明度为1(白色),则不取该目标颜色;若源颜色透明度为0(黑色),则全取目标颜色;若介于之间,则根据透明度来取目标颜色值. 所以黑色的圆周边缘也不存在了. 类似锐化?
    //    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    // 白色圆(圆周边缘还有点黑色部分). 通过透明度来混合. 源颜色*自身的alpha值, 目标颜色*(1-源颜色的alpha值). 常用于在物体前面绘制物体.
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // 画笔1050采用此mode.
    // 但使用Radial.png则在黑色边缘部分会叠加, 导致画笔成黑色.
    // glBlendFunc(GL_SRC_ALPHA, GL_ONE);
}

// 加载image, 使用CoreGraphics将位图以RGBA格式存放.将UIImage图像数据转化成OpenGL ES接受的数据.
- (void)prepareImageDataAndTexture:(UIImage *)image {
    
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef ctx = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(ctx, rect);
    CGContextDrawImage(ctx, rect, cgImageRef);
    
    // 将图像数据传递给OpenGL ES
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    CGContextRelease(ctx);
    
    free(imageData);
}

- (NSArray *)CGPointsViaBezeierFrom:(CGPoint)start to:(CGPoint)end {
    NSMutableArray *tmpPoints = [NSMutableArray array];
    CGPoint p1, p2, p3;
    if (_points.count > 2) {
        p1 = Middle_CGPoint([_points[_points.count - 3] CGPointValue], start);
        p2 = start;
        p3 = Middle_CGPoint(start, end);
    } else {
        p1 = start;
        p3 = Middle_CGPoint(start, end);
        p2 = Middle_CGPoint(start, p3);
    }
    
    CGFloat tValue = 0.5 / Distance_CGPoints(p1, p3);
    if (tValue > 0.5) {
        tValue = 0.5;
    }
    for (CGFloat t=0; t<1; t+=tValue) {
        CGFloat x = (1 - t) * (1 - t) * p1.x + 2 * t * (1 - t) * p2.x + t * t * p3.x;
        CGFloat y = (1 - t) * (1 - t) * p1.y + 2 * t * (1 - t) * p2.y + t * t * p3.y;
        [tmpPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    return tmpPoints;
}


#pragma mark - screen touch operations

- (void)handleTouchBegan:(UITouch *)touch {
    CGPoint p = [touch locationInView:self];
    if (CGPointEqualToPoint(_previousPoint, CGPointZero)) {
        _previousPoint = p;
    }
    [_points addObject:[NSValue valueWithCGPoint:p]];
    [self drawFrom:_previousPoint to:p touchType:touchesBegan];
}

- (void)handleTouchMove:(UITouch *)touch {
    CGPoint p = [touch locationInView:self];
    [_points addObject:[NSValue valueWithCGPoint:p]];
    [self drawFrom:_previousPoint to:p touchType:touchesMoved];
    _previousPoint = p;
}

- (void)handleTouchEnd:(UITouch *)touch {
    CGPoint p = [touch locationInView:self];
    [_points addObject:[NSValue valueWithCGPoint:p]];
    [self drawFrom:_previousPoint to:p touchType:touchesEnded];
    _previousPoint = p;
    _previousPoint = CGPointZero;
    [_points removeAllObjects];
}

@end
