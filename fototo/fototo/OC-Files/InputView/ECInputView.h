//
//  ECInputView.h
//  textInput
//
//  Created by Even on 2017/4/11.
//  Copyright © 2017年 Even. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ECInputViewDelegate

- (void)sendText:(NSString *)text;

@end

@interface ECInputView : UIView

- (void)inputViewShow;
- (void)inputViewHiden;
@property (nonatomic, weak) id<ECInputViewDelegate>delegate;

@end
