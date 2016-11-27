//
//  WIGLContext.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/10/27.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "WIGLContext.h"

@interface WIGLContext ()

@property (strong, nonatomic) NSMutableDictionary *shaderProgramCache;

@end

@implementation WIGLContext

@synthesize context = _context;

- (NSMutableDictionary *)shaderProgramCache {
    if (_shaderProgramCache == nil) {
        _shaderProgramCache = [NSMutableDictionary new];
    }
    return _shaderProgramCache;
}

- (EAGLContext *)context {
    if (_context == nil) {
        _context = [self createContext];
        [EAGLContext setCurrentContext:_context];
        
        // Set up a few global settings for the image processing pipeline
        glDisable(GL_DEPTH_TEST);
    }
    
    return _context;
}

+ (WIGLContext *)sharedContext {
    static dispatch_once_t pred;
    static WIGLContext *sharedContext = nil;
    
    dispatch_once(&pred, ^{
        sharedContext = [[[self class] alloc] init];
    });
    return sharedContext;
}

+ (void)useContext {
    [[[self class] sharedContext] useAsCurrentContext];
}

- (void)useAsCurrentContext {
    EAGLContext *context = [self context];
    if ([EAGLContext currentContext] != context)
    {
        [EAGLContext setCurrentContext:context];
    }
}

+ (void)setActiveShaderProgram:(GLProgram *)shaderProgram {
    WIGLContext *sharedContext = [[self class] sharedContext];
    [sharedContext setContextShaderProgram:shaderProgram];
}

- (void)setContextShaderProgram:(GLProgram *)shaderProgram {
    EAGLContext *context = [self context];
    if ([EAGLContext currentContext] != context) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (self.currentShaderProgram != shaderProgram) {
        self.currentShaderProgram = shaderProgram;
        [shaderProgram use];
    }
}
- (void)presentBufferForDisplay {
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString {
    NSString *lookupKeyForShaderProgram = [NSString stringWithFormat:@"V: %@ - F: %@", vertexShaderString, fragmentShaderString];
    GLProgram *programFromCache = [self.shaderProgramCache objectForKey:lookupKeyForShaderProgram];
    
    if (programFromCache == nil) {
        programFromCache = [[GLProgram alloc] initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
        [self.shaderProgramCache setObject:programFromCache forKey:lookupKeyForShaderProgram];
    }
    
    return programFromCache;
}

- (EAGLContext *)createContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSAssert(context != nil, @"Unable to create an OpenGL ES 2.0 context. The GPUImage framework requires OpenGL ES 2.0 support to work.");
    return context;
}

@end
