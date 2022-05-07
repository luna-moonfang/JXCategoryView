//
//  JXCategoryBaseCell.m
//  UI系列测试
//
//  Created by jiaxin on 2018/3/15.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "JXCategoryBaseCell.h"
#import "RTLManager.h"

@interface JXCategoryBaseCell ()
@property (nonatomic, strong) JXCategoryBaseCellModel *cellModel;
@property (nonatomic, strong) JXCategoryViewAnimator *animator;
@property (nonatomic, strong) NSMutableArray <JXCategoryCellSelectedAnimationBlock> *animationBlockArray;
@end

@implementation JXCategoryBaseCell

#pragma mark - Initialize

- (void)dealloc {
    [self.animator stop];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    [self.animator stop];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeViews];
    }
    return self;
}

#pragma mark - Public

- (void)initializeViews {
    _animationBlockArray = [NSMutableArray array];
    
    // df: 忽略RTL(right to left)
    [RTLManager horizontalFlipViewIfNeeded:self];
    [RTLManager horizontalFlipViewIfNeeded:self.contentView];
}

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    self.cellModel = cellModel;

    if (cellModel.isSelectedAnimationEnabled) {
        // ???: why remove last
        [self.animationBlockArray removeLastObject];
        if ([self checkCanStartSelectedAnimation:cellModel]) {
            self.animator = [[JXCategoryViewAnimator alloc] init];
            self.animator.duration = cellModel.selectedAnimationDuration;
        } else {
            [self.animator stop];
        }
    }
}

- (BOOL)checkCanStartSelectedAnimation:(JXCategoryBaseCellModel *)cellModel {
    BOOL canStartSelectedAnimation;
    if (cellModel.selectedType == JXCategoryCellSelectedTypeCode ||
        cellModel.selectedType == JXCategoryCellSelectedTypeClick) {
        canStartSelectedAnimation = YES; // 代码调用或点击可执行动画
    } else {
        canStartSelectedAnimation = NO; // 滑动不执行动画, 应该是执行跟手的交互动画
    }
    
    return canStartSelectedAnimation;
}

- (void)addSelectedAnimationBlock:(JXCategoryCellSelectedAnimationBlock)block {
    [self.animationBlockArray addObject:block];
}

- (void)startSelectedAnimationIfNeeded:(JXCategoryBaseCellModel *)cellModel {
    if (cellModel.isSelectedAnimationEnabled && [self checkCanStartSelectedAnimation:cellModel]) {
        // 需要更新 isTransitionAnimating，用于处理在过滤时，禁止响应点击，避免界面异常。
        cellModel.transitionAnimating = YES;
        __weak typeof(self)weakSelf = self;
        self.animator.progressCallback = ^(CGFloat percent) {
            for (JXCategoryCellSelectedAnimationBlock block in weakSelf.animationBlockArray) {
                block(percent);
            }
        };
        self.animator.completeCallback = ^{
            cellModel.transitionAnimating = NO;
            [weakSelf.animationBlockArray removeAllObjects];
        };
        [self.animator start];
    }
}

@end
