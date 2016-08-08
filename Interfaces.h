#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface FBSSystemService : NSObject
+ (instancetype)sharedService;
- (void)sendActions:(NSSet *)actions withResult:(id)result;
@end

@interface SBSRelaunchAction
+ (instancetype)actionWithReason:(NSString *)reason options:(int)options targetURL:(NSURL *)target;
@end

@interface SBIcon : NSObject
@end

@interface SBApplication : NSObject
- (BOOL)isSystemApplication;
- (Class)iconClass;
- (BOOL)iconAllowsUninstall:(SBIcon *)icon;

@property(nonatomic, getter=isUninstallAllowed) BOOL uninstallAllowed;
@end

@interface SBIconView : NSObject
+ (id)_jitterTransformAnimation;
+ (id)_jitterPositionAnimation;
@end

@interface SBApplicationIcon : SBIcon
- (id)initWithApplication:(SBApplication *)application;
- (BOOL)allowsUninstall;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

@interface UIAlertController ()
@property(readonly) UIAlertAction *_cancelAction;
@end

@interface UIAlertAction ()
- (void)setHandler:(void (^)(UIAlertAction *action))handler; // @synthesize handler=_handler;
@end

@interface SBIconModel : NSObject
- (SBIcon *)expectedIconForDisplayIdentifier:(NSString *)identifier; //why not bundle identifier?
@end

@interface SBIconViewMap : NSObject
+ (id)homescreenMap;
- (SBIconView *)iconViewForIcon:(SBIcon *)icon;
- (SBIconView *)mappedIconViewForIcon:(SBIcon *)icon;
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (SBIconModel *)model;
- (void)iconCloseBoxTapped:(SBIconView *)icon;

@property(nonatomic) BOOL isEditing;
@property(nonatomic, strong) SBIconViewMap *homescreenMap;
@end

@interface SPSearchResult : NSObject
- (BOOL)searchdelete_isApplication;
- (BOOL)isUserApplication;
- (BOOL)searchdelete_isSystemApplication;
- (BOOL)searchdelete_allowsUninstall;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, copy) NSString *bundleID;
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
@property(nonatomic, strong) SPSearchResult *result;
@end

@interface SPUISearchHeader : NSObject
- (UITextField *)searchField;
@end

@interface SPUISearchViewController : UIViewController <UIAlertViewDelegate>
+ (id)sharedInstance;
- (BOOL)isActivated;
- (void)_searchFieldEditingChanged;
- (void)searchdelete_reload;
@end
