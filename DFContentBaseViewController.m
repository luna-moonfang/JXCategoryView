//
//  DFContentBaseViewController.m
//  JXCategoryView
//
//  Created by 董恭甫 on 2022/5/16.
//

#import "DFContentBaseViewController.h"

@interface DFContentBaseViewController ()

@end

@implementation DFContentBaseViewController

- (instancetype)initWithCategoryViewStyle:(DFCategoryViewStyle)categoryViewStyle {
    self = [super init];
    if (self) {
        _categoryViewStyle = categoryViewStyle;
    }
    return self;
}

- (instancetype)init {
    return [self initWithCategoryViewStyle:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // viewDidLoad之前准备好: titles, categoryViewStyle
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.listContainerView];
    
    // 关联 categoryView 和 listContainerView
    self.categoryView.listContainer = self.listContainerView;
    
    if (self.categoryTitleView) {
        self.categoryTitleView.titles = self.titles;
        
        JXCategoryIndicatorComponentView *indicator = [self preferredIndicator];
        if (indicator) {
            self.categoryTitleView.indicators = @[indicator];
        }
    }
    
    if (self.categoryViewStyle == DFCategoryViewStyleTitleView) {
        self.navigationItem.titleView = self.categoryView;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat categoryViewHeight = [self preferredCategoryViewHeight];
    CGFloat listContainerViewY = categoryViewHeight;
    
    if (self.categoryViewStyle == DFCategoryViewStyleTitleView) {
        categoryViewHeight = self.navigationController.navigationBar.bounds.size.height;
        listContainerViewY = 0;
    }
    
    self.categoryView.frame = CGRectMake(0, 0, self.view.bounds.size.width, categoryViewHeight);
    self.listContainerView.frame = CGRectMake(0, listContainerViewY, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.isNested) {
        // 处于第一个item的时候，才允许屏幕边缘手势返回
        self.navigationController.interactivePopGestureRecognizer.enabled = (self.selectedIndex == 0);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.isNested) {
        // 离开页面的时候，需要恢复屏幕边缘手势，不能影响其他页面
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - Public

- (JXCategoryBaseView *)preferredCategoryView {
    return [[JXCategoryTitleView alloc] init];
}

- (CGFloat)preferredCategoryViewHeight {
    return 50;
}

- (JXCategoryIndicatorComponentView *)preferredIndicator {
    // 子类实现
    return nil;
}

- (void)reloadData {
    // 需要准备好titles
    self.categoryTitleView.titles = self.titles;
    [self.categoryView reloadData];
}

#pragma mark - JXCategoryViewDelegate

// 点击选中或滚动选中
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    if (self.isNested) {
        // 作为嵌套的子容器，不需要处理侧滑手势处理。
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
    }
}

#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    if (index < self.viewControllers.count) {
        UIViewController *controller = self.viewControllers[index];
        if ([controller conformsToProtocol:@protocol(JXCategoryListContentViewDelegate)]) {
            return (id<JXCategoryListContentViewDelegate>)controller;
        }
    }
    
    return nil;
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

#pragma mark - Getters & Setters

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    _viewControllers = [viewControllers copy];
    
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:viewControllers.count];
    for (UIViewController *viewController in viewControllers) {
        [titles addObject:viewController.title ?: @""];
    }
    
    self.titles = titles; // set titles triggers reload data
}

- (__kindof UIViewController *)selectedViewController {
    return self.viewControllers[self.selectedIndex];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];
    if (index != NSNotFound) {
        self.selectedIndex = index;
    }
}

- (NSInteger)selectedIndex {
    return self.categoryView.selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex < self.titles.count) {
        [self.categoryView selectItemAtIndex:selectedIndex];
    }
}

- (void)setTitles:(NSArray *)titles {
    _titles = [titles copy];
    // set titles triggers reload data
    [self reloadData];
}

- (JXCategoryBaseView *)categoryView {
    if (!_categoryView) {
        _categoryView = [self preferredCategoryView];
        _categoryView.delegate = self;
    }
    return _categoryView;
}

- (JXCategoryTitleView *)categoryTitleView {
    if ([self.categoryView isKindOfClass:[JXCategoryTitleView class]]) {
        return (JXCategoryTitleView *)self.categoryView;
    } else {
        return nil;
    }
}

- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:self.listContainerType delegate:self];
    }
    return _listContainerView;
}

#pragma mark - Subclassing

- (JXCategoryListContainerType)listContainerType {
    // 默认用collectionview
    return JXCategoryListContainerType_CollectionView;
}

- (BOOL)isNested {
    return NO;
}

@end
