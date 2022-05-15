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

@interface DFContentBaseViewController : UIViewController <JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) JXCategoryBaseView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

- (JXCategoryBaseView *)preferredCategoryView;
- (CGFloat)preferredCategoryViewHeight;

@end

NS_ASSUME_NONNULL_END
