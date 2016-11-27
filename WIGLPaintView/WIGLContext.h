//
//  WIGLContext.h
//  ZYDemo
//
//  Created by wilab-pretzei on 16/10/27.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLProgram.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@interface WIGLContext : NSObject

@property(readonly, nonatomic) dispatch_queue_t contextQueue;
@property(readwrite, retain, nonatomic) GLProgram *currentShaderProgram;
@property(readonly, retain, nonatomic) EAGLContext *context;

+ (WIGLContext *)sharedContext;
+ (void)useContext;
- (void)useAsCurrentContext;
+ (void)setActiveShaderProgram:(GLProgram *)shaderProgram;
- (void)setContextShaderProgram:(GLProgram *)shaderProgram;

- (void)presentBufferForDisplay;
- (GLProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;

@end
