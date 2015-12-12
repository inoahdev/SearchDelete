#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface SBIconView : NSObject
+ (id)_jitterTransformAnimation;
+ (id)_jitterPositionAnimation;
@end

@interface SBIcon : NSObject
@end

@interface SBApplication : NSObject
- (NSString *)displayName;
- (NSString *)bundleIdentifier;
- (BOOL)isSystemApplication;
@end

@interface SBApplicationIcon : SBIcon
- (id)initWithApplication:(SBApplication *)application;
- (SBApplication *)application;
- (BOOL)allowsUninstall;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

@interface SBDeleteIconAlertItem : NSObject
- (id)initWithIcon:(SBIcon *)icon;
@property(nonatomic, strong) UIAlertController *alertController;
@end

@interface UIAlertController ()
@property(readonly) UIAlertAction *_cancelAction;
@end

@interface SBAlertItemsController : NSObject
+ (id)sharedInstance;
- (void)activateAlertItem:(SBDeleteIconAlertItem *)alertItem;
- (NSArray *)alertItemsOfClass:(Class)alertClass;
@end

@interface SBIconModel : NSObject
- (SBIcon *)expectedIconForDisplayIdentifier:(NSString *)identifier; //why not bundle identifier?
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (SBIconModel *)model;
- (void)iconCloseBoxTapped:(SBIcon *)icon;
@property(nonatomic) BOOL isEditing;
@end

@interface SPSearchResult : NSObject
- (BOOL)isApplication;
- (BOOL)isSystemApplication;
- (BOOL)searchdelete_allowsUninstall;
@property(nonatomic, copy) NSString *bundleID; //nil if not application
@property(nonatomic, strong) NSString *section_header;
@end

@interface SearchUITextAreaView : UIView
@property (retain) UILabel *titleLabel;
@end

@interface SearchUISingleResultTableViewCell : UITableViewCell <UIAlertViewDelegate>
- (void)searchdelete_startJittering;
- (BOOL)searchdelete_isJittering;
- (BOOL)searchdelete_stopJittering;
@property(retain) UIView *thumbnailContainer;
@property(retain) SearchUITextAreaView *textAreaView;
@property(nonatomic, strong) SPSearchResult *result;
@end

@interface SPUISearchViewController : UIViewController
+ (id)sharedInstance;
- (BOOL)isActivated;
@end
