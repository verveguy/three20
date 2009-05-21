#import "Three20/TTTableViewController.h"
#import "Three20/TTThumbsTableViewCell.h"
#import "Three20/TTPhotoSource.h"

@protocol TTThumbsViewControllerDelegate, TTPhotoSource;
@class TTPhotoViewController;

@interface TTThumbsViewController : TTTableViewController {
  id<TTThumbsViewControllerDelegate> _delegate;
  id<TTPhotoSource> _photoSource;
}

@property(nonatomic,assign) id<TTThumbsViewControllerDelegate> delegate;
@property(nonatomic,retain) id<TTPhotoSource> photoSource;

- (TTPhotoViewController*)createPhotoViewController;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTThumbsDataSource : TTDataSource
          <TTPhotoSourceDelegate, TTThumbsTableViewCellDelegate> {
  TTThumbsViewController* _controller;
  id<TTPhotoSource> _photoSource;
}

- (id)initWithController:(TTThumbsViewController*)controller;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTThumbsViewControllerDelegate <NSObject>

- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo;

@optional

- (BOOL)thumbsViewController:(TTThumbsViewController*)controller
        shouldNavigateToPhoto:(id<TTPhoto>)photo;

@end
