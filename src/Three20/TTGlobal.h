#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Three20/NSObjectAdditions.h"
#import "Three20/NSStringAdditions.h"
#import "Three20/NSDateAdditions.h"
#import "Three20/NSArrayAdditions.h"
#import "Three20/UIColorAdditions.h"
#import "Three20/UIImageAdditions.h"
#import "Three20/UIViewControllerAdditions.h"
#import "Three20/UIViewAdditions.h"
#import "Three20/UITableViewAdditions.h"
#import "Three20/UIWebViewAdditions.h"
#import "Three20/UIToolbarAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Helpers

#ifdef DEBUG
#define TTLOG NSLog
#else
#define TTLOG    
#endif

#define TTLOGRECT(rect) \
  TTLOG(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
    rect.size.width, rect.size.height)

#define TTLOGPOINT(pt) \
  TTLOG(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define TTLOGSIZE(size) \
  TTLOG(@"%s w=%f, h=%f", #size, size.width, size.height)

#define TTLOGEDGES(edges) \
  TTLOG(@"%s left=%f, right=%f, top=%f, bottom=%f", #edges, edges.left, edges.right, \
    edges.top, edges.bottom)

#define TTLOGHSV(_COLOR) \
  TTLOG(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define TT_ERROR_DOMAIN @"three20.net"

#define TT_EC_INVALID_IMAGE 101

///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

#define STATUS_HEIGHT 20
#define TOOLBAR_HEIGHT 44
#define KEYBOARD_HEIGHT 216
#define CHROME_HEIGHT (STATUS_HEIGHT + TOOLBAR_HEIGHT)
#define TABLE_GROUPED_PADDING 10
#define TT_ROUNDED -1

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:a]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:h saturation:s value:v alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:h saturation:s value:v alpha:a]

#define RGBA(r,g,b,a) r/256.0, g/256.0, b/256.0, a

///////////////////////////////////////////////////////////////////////////////////////////////////
// Style helpers

#define TTSTYLE(_SELECTOR) [[TTStyleSheet globalStyleSheet] styleWithSelector:@#_SELECTOR]

#define TTSTYLESTATE(_SELECTOR, _STATE) [[TTStyleSheet globalStyleSheet] \
                                           styleWithSelector:@#_SELECTOR forState:_STATE]

#define TTSTYLESHEET ((id)[TTStyleSheet globalStyleSheet])

#define TTSTYLEVAR(_VARNAME) [TTSTYLESHEET _VARNAME]

#define TTIMAGE(_URL) [[TTURLCache sharedCache] imageForURL:_URL]

typedef enum {
  TTPositionStatic,
  TTPositionAbsolute,
  TTPositionFloatLeft,
  TTPositionFloatRight,
} TTPosition;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Networking

typedef enum {
   TTURLRequestCachePolicyNone = 0,
   TTURLRequestCachePolicyMemory = 1,
   TTURLRequestCachePolicyDisk = 2,
   TTURLRequestCachePolicyNetwork = 4,
   TTURLRequestCachePolicyAny
    = (TTURLRequestCachePolicyMemory|TTURLRequestCachePolicyDisk|TTURLRequestCachePolicyNetwork),
   TTURLRequestCachePolicyNoCache = 8,    
   TTURLRequestCachePolicyDefault = TTURLRequestCachePolicyAny,
} TTURLRequestCachePolicy;

#define TT_DEFAULT_CACHE_INVALIDATION_AGE (60*60*24) // 1 day
#define TT_DEFAULT_CACHE_EXPIRATION_AGE (60*60*24*7) // 1 week

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration for transition animations.
 */
#define TT_TRANSITION_DURATION 0.3

#define TT_FAST_TRANSITION_DURATION 0.2

#define TT_FLIP_TRANSITION_DURATION 0.7

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* TTCreateNonRetainingArray();

/**
 * Creates a mutable dictionary which does not retain references to the values it contains.
 */
NSMutableDictionary* TTCreateNonRetainingDictionary();

/**
 * Tests if an object is an array which is empty.
 */
BOOL TTIsEmptyArray(NSObject* object);

/**
 * Tests if an object is a string which is empty.
 */
BOOL TTIsEmptyString(NSObject* object);
/**
 * Gets the current device orientation.
 */
UIInterfaceOrientation TTDeviceOrientation();

/**
 * Gets the bounds of the screen with device orientation factored in.
 */
CGRect TTScreenBounds();

/**
 * Gets the application frame.
 */
CGRect TTApplicationFrame();

/**
 * Gets the application frame below the navigation bar.
 */
CGRect TTNavigationFrame();

/**
 * Gets the application frame below the navigation bar and above a toolbar.
 */
CGRect TTToolbarNavigationFrame();

/**
 * Returns a rectangle that is smaller or larger than the source rectangle.
 */
CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose edges have been added to the insets.
 */
CGRect TTRectInset(CGRect rect, UIEdgeInsets insets);
 
/**
 * Increment the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void TTNetworkRequestStarted();

/**
 * Decrement the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void TTNetworkRequestStopped();

/**
 * Gets the current system locale chosen by the user.
 *
 * This is necessary because [NSLocale currentLocale] always returns en_US.
 */
NSLocale* TTCurrentLocale();

/**
 * Returns a localized string from the Three20 bundle.
 */
NSString* TTLocalizedString(NSString* key, NSString* comment);

BOOL TTIsBundleURL(NSString* url);

BOOL TTIsDocumentsURL(NSString* url);

NSString* TTPathForBundleResource(NSString* relativePath);

NSString* TTPathForDocumentsResource(NSString* relativePath);

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPersistable <NSObject>

@property(nonatomic,readonly) NSString* viewURL;

+ (id<TTPersistable>)fromURL:(NSURL*)url;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTLoadable <NSObject>

@property(nonatomic,readonly) NSMutableArray* delegates;
@property(nonatomic,readonly) NSDate* loadedTime;
@property(nonatomic,readonly) BOOL isLoaded;
@property(nonatomic,readonly) BOOL isLoading;
@property(nonatomic,readonly) BOOL isLoadingMore;
@property(nonatomic,readonly) BOOL isOutdated;
@property(nonatomic,readonly) BOOL isEmpty;

- (void)invalidate:(BOOL)erase;
- (void)cancel;

@end

