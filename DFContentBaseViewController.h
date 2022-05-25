//
//  DFContentBaseViewController.h
//  JXCategoryView
//
//  Created by 董恭甫 on 2022/5/16.
//

#import <UIKit/UIKit.h>

#import "JXCategoryView.h"
#import "JXCategoryListContainerView.h"

NS_ASSUME_NONNULL_BEGIN

/// CategoryView位置
typedef NS_ENUM(NSInteger, DFContentBaseViewControllerCategoryViewStyle) {
    DFContentBaseViewControllerCategoryViewStyleDefault = 0, // navbar下方
    DFContentBaseViewControllerCategoryViewStyleTitleView, // navbar's titleview
};

@interface DFContentBaseViewController : UIViewController <JXCategoryViewDelegate, JXCategoryListContainerViewDelegate, JXCategoryListContentViewDelegate>

@property (nonatomic, readonly) DFContentBaseViewControllerCategoryViewStyle categoryViewStyle;

@property (nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers; // set view controllers before push/present DFContentBaseViewController
@property (nullable, nonatomic, weak) __kindof UIViewController *selectedViewController;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) JXCategoryBaseView *categoryView;
@property (nonatomic, strong) JXCategoryTitleView *categoryTitleView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

- (instancetype)initWithCategoryViewStyle:(DFContentBaseViewControllerCategoryViewStyle)categoryViewStyle;

- (JXCategoryBaseView *)preferredCategoryView;
- (CGFloat)preferredCategoryViewHeight;
- (JXCategoryIndicatorComponentView *)preferredIndicator;

- (void)reloadData;

// subclassing
@property (nonatomic, assign) JXCategoryListContainerType listContainerType;
@property (nonatomic, assign) BOOL isNested;

@end

NS_ASSUME_NONNULL_END
