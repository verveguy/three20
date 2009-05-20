#import "Three20/TTViewController.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTViewController

@synthesize frozenState = _frozenState, viewState = _viewState,
  contentError = _contentError, navigationBarStyle = _navigationBarStyle,
  navigationBarTintColor = _navigationBarTintColor, statusBarStyle = _statusBarStyle,
  appearing = _appearing, appeared = _appeared,
  autoresizesForKeyboard = _autoresizesForKeyboard;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)resizeForKeyboard:(NSNotification*)notification {
  NSValue* v1 = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
  CGRect keyboardBounds;
  [v1 getValue:&keyboardBounds];

  NSValue* v2 = [notification.userInfo objectForKey:UIKeyboardCenterBeginUserInfoKey];
  CGPoint keyboardStart;
  [v2 getValue:&keyboardStart];

  NSValue* v3 = [notification.userInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
  CGPoint keyboardEnd;
  [v3 getValue:&keyboardEnd];
  
  CGFloat keyboardTop = keyboardEnd.y - floor(keyboardBounds.size.height/2);
  CGFloat screenBottom = self.view.screenY + self.view.height;
  if (screenBottom != keyboardTop) {
    BOOL animated = keyboardStart.y != keyboardEnd.y;
    if (animated) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    }
    
    CGFloat dy = screenBottom - keyboardTop;
    self.view.frame = TTRectContract(self.view.frame, 0, dy);

    if (animated) {
      [UIView commitAnimations];
    }
    
    return animated;
  }
  
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		_frozenState = nil;
		_viewState = TTViewEmpty;
		_contentError = nil;
		_navigationBarStyle = UIBarStyleDefault;
		_navigationBarTintColor = nil;
		_statusBarStyle = UIStatusBarStyleDefault;
		_invalidView = YES;
		_invalidViewLoading = NO;
		_invalidViewData = YES;
		_validating = NO;
		_appearing = NO;
		_appeared = NO;
		_unloaded = NO;
		_autoresizesForKeyboard = NO;
		
		self.navigationBarTintColor = TTSTYLEVAR(navigationBarTintColor);
	}
	return self;
}

- (void)awakeFromNib {
  [self init];
}

- (void)dealloc {
  TTLOG(@"DEALLOC %@", self);
  
  self.autoresizesForKeyboard = NO;
  
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

  [_navigationBarTintColor release];
  [_frozenState release];
  [_contentError release];
  [self unloadView];

  if (_appeared) {
    // The controller is supposed to handle this but sometimes due to leaks it does not, so
    // we have to force it here
    [self.view removeSubviews];
  }

  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.view.frame = TTNavigationFrame();
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.view.backgroundColor = TTSTYLEVAR(backgroundColor);
}

- (void)viewWillAppear:(BOOL)animated {
  if (_unloaded) {
    _unloaded = NO;
    [self loadView];
  }

  _appearing = YES;
  _appeared = YES;

  [self validateView];

  [TTURLRequestQueue mainQueue].suspended = YES;

  UINavigationBar* bar = self.navigationController.navigationBar;
  bar.tintColor = _navigationBarTintColor;
  bar.barStyle = _navigationBarStyle;
  [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
  _appearing = NO;
}

- (void)didReceiveMemoryWarning {
  TTLOG(@"MEMORY WARNING FOR %@", self);

  if (!_appearing) {
    if (_appeared) {
      TTLOG(@"UNLOAD VIEW %@", self);      

      NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
      [self persistView:state];
      _frozenState = state;

      NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

      UIView* view = self.view;
      [super didReceiveMemoryWarning];

      // Sometimes, like when the controller is in a tab bar, the view won't
      // be destroyed here like it should by the superclass - so let's do it ourselves!
      [view removeSubviews];

      _viewState = TTViewEmpty;
      _invalidView = YES;
      _appeared = NO;
      _unloaded = YES;
      
      [pool release];

      [self unloadView];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
  if (self.appearing) {
    BOOL animated = [self resizeForKeyboard:notification];
    [self keyboardWillAppear:animated];
  }
}

- (void)keyboardWillHide:(NSNotification*)notification {
  if (self.appearing) {
    BOOL animated = [self resizeForKeyboard:notification];
    [self keyboardWillDisappear:animated];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id<TTPersistable>)viewObject {
  return nil;
}

- (NSString*)viewType {
  return nil;
}

- (void)setAutoresizesForKeyboard:(BOOL)autoresizesForKeyboard {
  if (autoresizesForKeyboard != _autoresizesForKeyboard) {
    _autoresizesForKeyboard = autoresizesForKeyboard;
    
    if (_autoresizesForKeyboard) {
      [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    } else {
      [[NSNotificationCenter defaultCenter] removeObserver:self
        name:@"UIKeyboardWillShowNotification" object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self
        name:@"UIKeyboardWillHideNotification" object:nil];
    }
  }
}

- (void)showObject:(id)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [_frozenState release];
  _frozenState = [state retain];
}

- (void)persistView:(NSMutableDictionary*)state {
}

- (void)restoreView:(NSDictionary*)state {
} 

- (void)reloadContent {
}

- (void)refreshContent {
}

- (void)invalidateView {
  _invalidView = YES;
  _viewState = TTViewEmpty;
  if (_appearing) {
    [self validateView];
  }
}

- (void)invalidateViewState:(TTViewState)state {
  if (!_invalidViewLoading) {
    _invalidViewLoading = (_viewState & TTViewLoadingStates) != (state & TTViewLoadingStates);
  }
  if (!_invalidViewData) {
    _invalidViewData = state == TTViewDataLoaded || state == TTViewEmpty
                       || (_viewState & TTViewDataStates) != (state & TTViewDataStates);
  }
  
  _viewState = state;
  
  if (_appearing) {
    [self validateView];
  }
}

- (void)validateView {
  if (!_validating) {
    _validating = YES;
    if (_invalidView) {
      // Ensure the view is loaded
      self.view;

      [self updateView];

      if (_frozenState && self.viewState & TTViewDataLoaded) {
        [self restoreView:_frozenState];
        [_frozenState release];
        _frozenState = nil;
      }

      _invalidView = NO;
    }
    
    if (_invalidViewLoading) {
      [self updateLoadingView];
      _invalidViewLoading = NO;
    }

    if (_invalidViewData) {
      [self updateDataView];
      _invalidViewData = NO;
    }

    _validating = NO;

    [self refreshContent];
  }
}

- (void)updateView {
}

- (void)updateLoadingView {
}

- (void)updateDataView {
}

- (void)unloadView {
}

- (void)keyboardWillAppear:(BOOL)animated {
}

- (void)keyboardWillDisappear:(BOOL)animated {
}

- (NSString*)titleForActivity {
  if (self.viewState & TTViewRefreshing) {
    return TTLocalizedString(@"Updating...", @"");
  } else {
    return TTLocalizedString(@"Loading...", @"");
  }
}

- (UIImage*)imageForNoData {
  return nil;
}

- (NSString*)titleForNoData {
  return nil;
}

- (NSString*)subtitleForNoData {
  return nil;
}

- (UIImage*)imageForError:(NSError*)error {
  return nil;
}

- (NSString*)titleForError:(NSError*)error {
  return TTLocalizedString(@"Error", @"");
}

- (NSString*)subtitleForError:(NSError*)error {
  return TTLocalizedString(@"Sorry, an error has occurred.", @"");
}

@end
