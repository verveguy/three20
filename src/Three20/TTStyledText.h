#import "Three20/TTURLRequest.h"

@protocol TTStyledTextDelegate,TTStyledTextTouchDelegate;
@class TTStyledNode, TTStyledFrame, TTStyledBoxFrame, TTStyledLinkNode;

@interface TTStyledText : NSObject <TTURLRequestDelegate> {
  id<TTStyledTextDelegate> _delegate;
  id<TTStyledTextTouchDelegate> _touchDelegate;
  TTStyledNode* _rootNode;
  TTStyledFrame* _rootFrame;
  UIFont* _font;
  CGFloat _width;
  CGFloat _height;
  NSMutableArray* _invalidImages;
  NSMutableArray* _imageRequests;
}

@property(nonatomic,assign) id<TTStyledTextDelegate> delegate;

/**
 * Calls back for user events to the application layer
 **/
@property(nonatomic,assign) id<TTStyledTextTouchDelegate> touchDelegate;

/**
 * The first in the sequence of nodes that contain the styled text.
 */
@property(nonatomic, retain) TTStyledNode* rootNode;

/**
 * The first in the sequence of frames of text calculated by the layout.
 */
@property(nonatomic, readonly) TTStyledFrame* rootFrame;

/**
 * The font that will be used to measure and draw all text.
 */
@property(nonatomic, retain) UIFont* font;

/**
 * The width that the text should be constrained to fit within.
 */
@property(nonatomic) CGFloat width;

/**
 * The height of the text.
 *
 * The height is automatically calculated based on the width and the size of word-wrapped text.
 */
@property(nonatomic, readonly) CGFloat height;

/**
 * Indicates if the text needs layout to recalculate its size.
 */
@property(nonatomic, readonly) BOOL needsLayout;

/**
 * Images that require loading 
 */
@property(nonatomic, readonly) NSMutableArray* invalidImages;

/**
 * Constructs styled text with XHTML tags turned into style nodes.
 *
 * Only the following XHTML tags are supported: <b>, <i>, <img>, <a>.  The source must
 * be a well-formed XHTML fragment.  You do not need to enclose the source in an tag --
 * it can be any string with XHTML tags throughout.
 */
+ (TTStyledText*)textFromXHTML:(NSString*)source;
+ (TTStyledText*)textFromXHTML:(NSString*)source lineBreaks:(BOOL)lineBreaks urls:(BOOL)urls;

/**
 * Constructs styled text with all URLs transformed into links.
 *
 * Only URLs are parsed, not HTML markup. URLs are turned into links.
 */ 
+ (TTStyledText*)textWithURLs:(NSString*)source;
+ (TTStyledText*)textWithURLs:(NSString*)source lineBreaks:(BOOL)lineBreaks;

- (id)initWithNode:(TTStyledNode*)rootNode;

/**
 * 
 */
- (void)layoutFrames;

/**
 * 
 */
- (void)layoutIfNeeded;

/**
 * Called to indicate that the layout needs to be re-calculated.
 */
- (void)setNeedsLayout;

/** 
 * Draws the text at a point.
 */
- (void)drawAtPoint:(CGPoint)point;

/**
 * Draws the text at a point with optional highlighting.
 *
 * If highlighted is YES, text colors will be ignored and all text will be drawn in the same color.
 */
- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted;

/**
 * Determines which frame is intersected by a point.
 */
- (TTStyledBoxFrame*)hitTest:(CGPoint)point;

/**
 * Finds the frame that represents the node.
 *
 * If multiple frames represent a node, such as an inline frame with line breaks, the
 * first frame in the sequence will be returned.
 */
- (TTStyledFrame*)getFrameForNode:(TTStyledNode*)node;

/**
 *
 */
- (void)addChild:(TTStyledNode*)child;

/**
 *
 */
- (void)addText:(NSString*)text;

/**
 *
 */
- (void)insertChild:(TTStyledNode*)child atIndex:(NSInteger)index;

/**
 *
 */
- (TTStyledNode*)getElementByClassName:(NSString*)className;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTStyledTextDelegate <NSObject>

@optional

- (void)styledTextNeedsDisplay:(TTStyledText*)text;

@end

@protocol TTStyledTextTouchDelegate <NSObject>

@optional

/** Fires whenver a link node is touched **/
- (void)styledLinkNodeWasTouched:(TTStyledLinkNode*)link;

/** Fires whenever _any_ styled node is touched. Probably not universally interesting **/
- (void)styledNodeWasTouched:(TTStyledNode*)node;


@end
