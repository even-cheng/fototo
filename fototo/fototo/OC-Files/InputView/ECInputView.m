//
//  ECInputView.m
//  textInput
//
//  Created by Even on 2017/4/11.
//  Copyright © 2017年 Even. All rights reserved.
//

#import "ECInputView.h"

@interface ECInputView()<UITextViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *ECInputView;
@property (nonatomic, strong) UILabel *placeLabel;
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, assign) CGFloat keyboldH;
@end

@implementation ECInputView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:0.30];
        //使用NSNotificationCenter 鍵盤出現時
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(keyboardWillShown:)
         
                                                     name:UIKeyboardWillShowNotification object:nil];
        
        //使用NSNotificationCenter 鍵盤隐藏時
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(keyboardWillBeHidden:)
         
                                                     name:UIKeyboardWillHideNotification object:nil];
        [self createView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tap.delegate = self;
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)createView{
    self.ECInputView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 50)];
    [self addSubview:self.ECInputView];
    self.ECInputView.backgroundColor = [UIColor colorWithRed:0.80 green:0.82 blue:0.84 alpha:1.00];
    
    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, 30)];
    self.inputTextView.delegate = self;
    self.inputTextView.returnKeyType = UIReturnKeySend;
    self.inputTextView.layer.cornerRadius = 4;
    self.inputTextView.layer.masksToBounds = YES;
    self.inputTextView.font = [UIFont systemFontOfSize:14];
    self.inputTextView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    self.inputTextView.textColor = [UIColor blackColor];
    [self.ECInputView addSubview:self.inputTextView];
    
    self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 12, 200, 10)];
    self.placeLabel.text = @"最多可输入300字";
    self.placeLabel.textColor = [UIColor lightGrayColor];
    [self.inputTextView addSubview:self.placeLabel];
    //self.placeLabel.backgroundColor = [UIColor yellowColor];
    self.placeLabel.font = [UIFont systemFontOfSize:14];
    self.placeLabel.userInteractionEnabled = NO;
    self.placeLabel.hidden = NO;
}
//这个函数的最后一个参数text代表你每次输入的的那个字，所以：
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"-----%@",text);
    if ([text isEqualToString:@""]) {
        //表示删除字符
    }
    
    if ([text isEqualToString:@"\n"]){
        if (self.inputTextView.text.length>0) {
            [self.delegate sendText:self.inputTextView.text];
        }
        return NO;
    }else{
        NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if(new.length > 300){
            if (![text isEqualToString:@""]) {
                return NO;
            }
        }
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.placeLabel.hidden = NO;
    }else{
        self.placeLabel.hidden = YES;
    }
    static CGFloat maxHeight =120.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight){
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }else{
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.ECInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-self.keyboldH-size.height-20, [UIScreen mainScreen].bounds.size.width, size.height+20);
        textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    }];
}

//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWillShown:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    self.keyboldH = kbSize.height;
    CGFloat height = 0;
    if (self.inputTextView.text == nil) {
        height = 50;
    }else{
        CGSize constraintSize = CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT);
        CGSize size = [self.inputTextView sizeThatFits:constraintSize];
        height = size.height;
    }
    [UIView animateWithDuration:0.1 animations:^{
        if (height>=120.0f) {
            self.ECInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kbSize.height-120.0f-20, [UIScreen mainScreen].bounds.size.width, 120.0f+20);
        }else{
            self.ECInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kbSize.height-height-20, [UIScreen mainScreen].bounds.size.width, height+20);
        }
    }];
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    [UIView animateWithDuration:1 animations:^{
        self.ECInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 50);
    }];
}

- (void)inputViewShow{
    [self.inputTextView becomeFirstResponder];
    
}
- (void)inputViewHiden{
    [self.inputTextView resignFirstResponder];
    [self removeFromSuperview];
}

- (void)tapAction{
    [self inputViewHiden];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view == self.ECInputView ) {
        return NO;
    }else{
        return YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
