#import "UIColor+MagmaEvo.h"

@interface UIView (MagmaEvo)
-(id)_viewControllerForAncestor;
@end

@interface MTMaterialView : UIView
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,copy) NSString * moduleIdentifier;
@end

@interface CCUIContentModuleContentContainerView : UIView
@property (nonatomic,readonly) MTMaterialView * moduleMaterialView;
@end

@interface CCUIButtonModuleView : UIControl
@end

@interface CCUICAPackageView : UIView
@end

@interface CCUIRoundButton : UIControl
@property (nonatomic,retain) UIView * normalStateBackgroundView;
@property (nonatomic,retain) UIImageView * selectedGlyphView;
@property (nonatomic,retain) CCUICAPackageView * glyphPackageView;
@end

@interface CCUIButtonModuleViewController : UIViewController
@property (assign,getter=isSelected,nonatomic) BOOL selected;
@end

@interface CCUILabeledRoundButtonViewController : UIViewController
@property (assign,getter=isEnabled,nonatomic) BOOL enabled;
@end

@interface CCUIToggleModule : NSObject
@end

@interface CCUIToggleViewController : CCUIButtonModuleViewController
-(CCUIToggleModule *)module;
@end

@interface _UIStatusBar : UIView
@property (nonatomic,readonly) UIView * containerView;
@end

@interface CAFilter : NSObject
@property (copy) NSString * name;
@end

@interface CALayer (MagmaEvo)
@property (assign) CGColorRef contentsMultiplyColor;
@property (retain) CAFilter *compositingFilter;
@end

BOOL prefBool(NSString *key);
NSString* prefValue(NSString *key);
BOOL prefValueEquals(NSString *key, NSString *value);
void forceLayerUpdate(NSArray *layers);

CGColorRef getConnectivityColor(CCUILabeledRoundButtonViewController *controller);
