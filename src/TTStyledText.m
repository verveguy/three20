#import "Three20/TTStyledText.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledLayout.h"
#import "Three20/TTStyledTextParser.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTURLResponse.h"
#import "Three20/TTURLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledText

@synthesize delegate = _delegate, touchDelegate = _touchDelegate, rootNode = _rootNode, font = _font, width = _width,
            height = _height, invalidImages = _invalidImages;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTStyledText*)textFromXHTML:(NSString*)source {
  return [self textFromXHTML:source lineBreaks:NO urls:YES];
}

+ (TTStyledText*)textFromXHTML:(NSString*)source lineBreaks:(BOOL)lineBreaks urls:(BOOL)urls {
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = urls;
  [parser parseXHTML:source];
  if (parser.rootNode) {
    return [[[TTStyledText alloc] initWithNode:parser.rootNode] autorelease];
  } else {
    return nil;
  }
}

+ (TTStyledText*)textWithURLs:(NSString*)source {
  return [self textWithURLs:source lineBreaks:NO];
}

+ (TTStyledText*)textWithURLs:(NSString*)source lineBreaks:(BOOL)lineBreaks {
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = YES;
  [parser parseText:source];
  if (parser.rootNode) {
    return [[[TTStyledText alloc] initWithNode:parser.rootNode] autorelease];
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)stopLoadingImages {
  if (_imageRequests) {
    NSMutableArray* requests = [_imageRequests retain];
    [_imageRequests release];
    _imageRequests = nil;

    if (!_invalidImages) {
      _invalidImages = [[NSMutableArray alloc] init];
    }
    
    for (TTURLRequest* request in requests) {
      [_invalidImages addObject:request.userInfo];
      [request cancel];
    }
    [requests release];
  }
}

- (void)loadImages {
  [self stopLoadingImages];

  if (_delegate && _invalidImages) {
    BOOL loadedSome = NO;
    for (TTStyledImageNode* imageNode in _invalidImages) {
      if (imageNode.url) {
        UIImage* image = [[TTURLCache sharedCache] imageForURL:imageNode.url];
        if (image) {
          imageNode.image = image;
          loadedSome = YES;
        } else {
          TTURLRequest* request = [TTURLRequest requestWithURL:imageNode.url delegate:self];
          request.userInfo = imageNode;
          request.response = [[[TTURLImageResponse alloc] init] autorelease];
          [request send];
        }
      }
    }

    [_invalidImages release];
    _invalidImages = nil;
    
    if (loadedSome) {
      [_delegate styledTextNeedsDisplay:self];
    }
  }
}

- (TTStyledFrame*)getFrameForNode:(TTStyledNode*)node inFrame:(TTStyledFrame*)frame {
  while (frame) {
    if ([frame isKindOfClass:[TTStyledBoxFrame class]]) {
      TTStyledBoxFrame* boxFrame = (TTStyledBoxFrame*)frame;
      if (boxFrame.element == node) {
        return boxFrame;
      }
      TTStyledFrame* found = [self getFrameForNode:node inFrame:boxFrame.firstChildFrame];
      if (found) {
        return found;
      }
    } else if ([frame isKindOfClass:[TTStyledTextFrame class]]) {
      TTStyledTextFrame* textFrame = (TTStyledTextFrame*)frame;
      if (textFrame.node == node) {
        return textFrame;
      }
    } else if ([frame isKindOfClass:[TTStyledImageFrame class]]) {
      TTStyledImageFrame* imageFrame = (TTStyledImageFrame*)frame;
      if (imageFrame.imageNode == node) {
        return imageFrame;
      }
    }
    frame = frame.nextFrame;
  }
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNode:(TTStyledNode*)rootNode {
  if (self = [self init]) {
    _rootNode = [rootNode retain];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _rootNode = nil;
    _rootFrame = nil;
    _font = nil;
    _width = 0;
    _height = 0;
    _invalidImages = nil;
    _imageRequests = nil;
  }
  return self;
}

- (void)dealloc {
  [self stopLoadingImages];
  [_rootNode release];
  [_rootFrame release];
  [_font release];
  [_invalidImages release];
  [_imageRequests release];
  [super dealloc];
}

- (NSString*)description {
  return [self.rootFrame description];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  if (!_imageRequests) {
    _imageRequests = [[NSMutableArray alloc] init];
  }
  [_imageRequests addObject:request];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  TTStyledImageNode* imageNode = request.userInfo;
  imageNode.image = response.image;
  
  [_imageRequests removeObject:request];
  
  [_delegate styledTextNeedsDisplay:self];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  [_imageRequests removeObject:request];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  [_imageRequests removeObject:request];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setDelegate:(id<TTStyledTextDelegate>)delegate {
  if (_delegate != delegate) {
    _delegate = delegate;
    [self loadImages];
  }
}

- (TTStyledFrame*)rootFrame {
  [self layoutIfNeeded];
  return _rootFrame;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsLayout];
  }
}

- (void)setWidth:(CGFloat)width {
  if (width != _width) {
    _width = width;
    [self setNeedsLayout];
  }
}

- (CGFloat)height {
  [self layoutIfNeeded];
  return _height;
}

- (BOOL)needsLayout {
  return !_rootFrame;
}

- (void)layoutFrames {
  TTStyledLayout* layout = [[TTStyledLayout alloc] initWithRootNode:_rootNode];
  layout.width = _width;
  layout.font = _font;
  [layout layout:_rootNode];
  
  [_rootFrame release];
  _rootFrame = [layout.rootFrame retain];
  _height = ceil(layout.height);
  [_invalidImages release];
  _invalidImages = [layout.invalidImages retain];
  [layout release];
  
  [self loadImages];
}

- (void)layoutIfNeeded {
  if (!_rootFrame) {
    [self layoutFrames];
  }
}

- (void)setNeedsLayout {
  [_rootFrame release];
  _rootFrame = nil;
  _height = 0;
}

- (void)drawAtPoint:(CGPoint)point {
  [self drawAtPoint:point highlighted:NO];
}

- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextTranslateCTM(ctx, point.x, point.y);

  TTStyledFrame* frame = self.rootFrame;
  while (frame) {
    [frame drawInRect:frame.bounds];
    frame = frame.nextFrame;
  }

  CGContextRestoreGState(ctx);
}

- (TTStyledBoxFrame*)hitTest:(CGPoint)point {
  return [self.rootFrame hitTest:point];
}

- (TTStyledFrame*)getFrameForNode:(TTStyledNode*)node {
  return [self getFrameForNode:node inFrame:_rootFrame];
}

- (void)addChild:(TTStyledNode*)child {
  if (!_rootNode) {
    self.rootNode = child;
  } else {
    TTStyledNode* previousNode = _rootNode;
    TTStyledNode* node = _rootNode.nextSibling;
    while (node) {
      previousNode = node;
      node = node.nextSibling;
    }
    previousNode.nextSibling = child;
  }
}

- (void)addText:(NSString*)text {
  [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
}

- (void)insertChild:(TTStyledNode*)child atIndex:(NSInteger)index {
  if (!_rootNode) {
    self.rootNode = child;
  } else if (index == 0) {
    child.nextSibling = _rootNode;
    self.rootNode = child;
  } else {
    NSInteger i = 0;
    TTStyledNode* previousNode = _rootNode;
    TTStyledNode* node = _rootNode.nextSibling;
    while (node && i != index) {
      ++i;
      previousNode = node;
      node = node.nextSibling;
    }
    child.nextSibling = node;
    previousNode.nextSibling = child;
  }
}

- (TTStyledNode*)getElementByClassName:(NSString*)className {
  TTStyledNode* node = _rootNode;
  while (node) {
    if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* element = (TTStyledElement*)node;
      if ([element.className isEqualToString:className]) {
        return element;
      }

      TTStyledNode* found = [element getElementByClassName:className];
      if (found) {
        return found;
      }
    }
    node = node.nextSibling;
  }
  return nil;
}

@end
