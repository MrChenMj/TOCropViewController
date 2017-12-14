//
//  TOCropToolbar.h
//
//  Copyright 2015-2016 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropToolbar.h"

#define RGBACROP(r,g,b,a)      [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#define kTOCropToolbarShowButtonsContainerRectForDebugging     0   // convenience debug toggle
#define KResColorNor RGBACROP(255,77,91,1)
#define KResColorDid RGBACROP(200,200,200,0.4)

@interface TOCropToolbar()

@property (nonatomic, strong, readwrite) UIButton *doneTextButton;
@property (nonatomic, strong, readwrite) UIButton *doneIconButton;

@property (nonatomic, strong, readwrite) UIButton *cancelTextButton;
@property (nonatomic, strong, readwrite) UIButton *cancelIconButton;

@property (nonatomic, strong, readwrite) UIButton *resetTextButton;
@property (nonatomic, strong, readwrite) UIButton *resetIconButton;

@property (nonatomic, strong) UIButton *rotateCounterclockwiseButton;
@property (nonatomic, strong) UIButton *rotateClockwiseButton;
@property (nonatomic, strong) UIButton *clampButton;

@property (nonatomic, strong) UIButton *rotateButton; // defaults to counterclockwise button for legacy compatibility

@property (nonatomic, assign) BOOL reverseContentLayout; // For languages like Arabic where they natively present content flipped from English

- (void)setup;
- (void)buttonTapped:(id)button;

+ (UIImage *)doneImage;
+ (UIImage *)cancelImage;
+ (UIImage *)resetImage;
+ (UIImage *)rotateCCWImage;
+ (UIImage *)rotateCWImage;
+ (UIImage *)clampImage;

@end

@implementation TOCropToolbar
+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"TOCropViewController" withExtension:@"bundle"];
        bundle = [[NSBundle alloc] initWithURL:bundleURL];
    });
    return bundle;
}

static inline NSString *MJLocalizedString(NSString *key, NSString *comment)
{
    return [[TOCropToolbar bundle] localizedStringForKey:key value:nil table:@"Localizable"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor =RGBACROP(50, 50, 50, 1); //[UIColor colorWithWhite:0.12f alpha:1.0f];
    
    // On iOS 9, we can use the new layout features to determine whether we're in an 'Arabic' style language mode
    if ([UIView resolveClassMethod:@selector(userInterfaceLayoutDirectionForSemanticContentAttribute:)]) {
        self.reverseContentLayout = ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft);
    }
    else {
        self.reverseContentLayout = [[[NSLocale preferredLanguages] objectAtIndex:0] containsString:@"ar"];
    }
    
    _doneTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
   /* [_doneTextButton setTitle:NSLocalizedStringFromTableInBundle(@"Done",
                                                                 @"TOCropViewControllerLocalizable",
                                                                 [NSBundle bundleForClass:[self class]],
                                                                 nil)
                     forState:UIControlStateNormal];
    [_doneTextButton setTitleColor:[UIColor colorWithRed:1.0f green:0.8f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];*/
    [_doneTextButton setImage:[TOCropToolbar doneImage] forState:UIControlStateNormal];
    [_doneTextButton setTintColor:RGBACROP(255,77,91,1)];
    [_doneTextButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [_doneTextButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneTextButton];
    
    _doneIconButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_doneIconButton setImage:[TOCropToolbar doneImage] forState:UIControlStateNormal];
    [_doneIconButton setTintColor:RGBACROP(255,77,91,1)];
    [_doneIconButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneIconButton];
    
    _cancelTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
  /*  [_cancelTextButton setTitle:NSLocalizedStringFromTableInBundle(@"Cancel",
                                                                   @"TOCropViewControllerLocalizable",
                                                                   [NSBundle bundleForClass:[self class]],
                                                                   nil)
                       forState:UIControlStateNormal];
    [_cancelTextButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];*/
    [_cancelTextButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelTextButton setImage:[TOCropToolbar cancelImage] forState:UIControlStateNormal];
    [_cancelTextButton setTintColor:RGBACROP(255,77,91,1)];
    [self addSubview:_cancelTextButton];
    
    _cancelIconButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelIconButton setImage:[TOCropToolbar cancelImage] forState:UIControlStateNormal];
    [_cancelIconButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelIconButton setTintColor:RGBACROP(255,77,91,1)];
    [self addSubview:_cancelIconButton];
    
    _clampButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _clampButton.contentMode = UIViewContentModeCenter;
//    _clampButton.tintColor = [UIColor whiteColor];
    [_clampButton setTintColor:RGBACROP(255,77,91,1)];
    [_clampButton setImage:[TOCropToolbar clampImage] forState:UIControlStateNormal];
    [_clampButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_clampButton];
    
    _rotateClockwiseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rotateClockwiseButton.contentMode = UIViewContentModeCenter;
//    _rotateClockwiseButton.tintColor = [UIColor whiteColor];
    [_rotateClockwiseButton setTintColor:RGBACROP(255,77,91,1)];
    [_rotateClockwiseButton setImage:[TOCropToolbar rotateCWImage] forState:UIControlStateNormal];
    [_rotateClockwiseButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rotateClockwiseButton];
    
    _rotateCounterclockwiseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rotateCounterclockwiseButton.contentMode = UIViewContentModeCenter;
//    _rotateCounterclockwiseButton.tintColor = [UIColor whiteColor];
    [_rotateCounterclockwiseButton setTintColor:RGBACROP(255,77,91,1)];
    [_rotateCounterclockwiseButton setImage:[TOCropToolbar rotateCCWImage] forState:UIControlStateNormal];
    [_rotateCounterclockwiseButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rotateCounterclockwiseButton];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _resetButton.contentMode = UIViewContentModeCenter;
    [_resetButton setTitle:MJLocalizedString(@"Reset", nil)
     forState:UIControlStateNormal];
    [_resetButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [_resetButton setTitleEdgeInsets:UIEdgeInsetsMake(5,0, 0,0)];
    [_resetButton setTintColor:KResColorDid];
//    _resetButton.tintColor = [UIColor whiteColor];
    _resetButton.userInteractionEnabled = NO;
    [_resetButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_resetButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL verticalLayout = (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds));
    CGSize boundsSize = self.bounds.size;
    
    self.cancelIconButton.hidden = (!verticalLayout);
    self.cancelTextButton.hidden = (verticalLayout);
    self.doneIconButton.hidden   = (!verticalLayout);
    self.doneTextButton.hidden   = (verticalLayout);
    
//    self.rotateCounterclockwiseButton.hidden = self.rotateButtonHidden;
    
    
#if kTOCropToolbarShowButtonsContainerRectForDebugging
    static UIView *containerView = nil;
    if (!containerView) {
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.backgroundColor = [UIColor redColor];
        containerView.alpha = 0.1;
        [self addSubview:containerView];
    }
#endif
    
    if (verticalLayout == NO) {
        CGFloat insetPadding = 10.0f;
        
        // Work out the cancel button frame
        CGRect frame = CGRectZero;
        frame.size.height = 44.0f;
       
        frame.size.width = [MJLocalizedString(@"Cancel", nil) sizeWithAttributes:@{NSFontAttributeName:self.cancelTextButton.titleLabel.font}].width + 10;

        //If normal layout, place on the left side, else place on the right
        if (self.reverseContentLayout == NO) {
            frame.origin.x = insetPadding;
        }
        else {
            frame.origin.x = boundsSize.width - (frame.size.width + insetPadding);
        }
        self.cancelTextButton.frame = frame;
        
        // Work out the Done button frame
   
        frame.size.width = [MJLocalizedString(@"Done", nil) sizeWithAttributes:@{NSFontAttributeName:self.doneTextButton.titleLabel.font}].width + 10;
        
        if (self.reverseContentLayout == NO) {
            frame.origin.x = boundsSize.width - (frame.size.width + insetPadding);
        }
        else {
            frame.origin.x = insetPadding;
        }
        self.doneTextButton.frame = frame;
        
        // Work out the frame between the two buttons where we can layout our action buttons
        CGFloat x = self.reverseContentLayout ? CGRectGetMaxX(self.doneTextButton.frame) : CGRectGetMaxX(self.cancelTextButton.frame);
        CGFloat width = 0.0f;
        
        if (self.reverseContentLayout == NO) {
            width = CGRectGetMinX(self.doneTextButton.frame) - CGRectGetMaxX(self.cancelTextButton.frame);
        }
        else {
            width = CGRectGetMinX(self.cancelTextButton.frame) - CGRectGetMaxX(self.doneTextButton.frame);
        }
        
        CGRect containerRect = (CGRect){x,0,width,44.0f};

#if kTOCropToolbarShowButtonsContainerRectForDebugging
        containerView.frame = containerRect;
#endif
        
        CGSize buttonSize = (CGSize){44.0f,44.0f};
        
        NSMutableArray *buttonsInOrderHorizontally = [NSMutableArray new];
        if (!self.rotateCounterClockwiseButtonHidden) {
            [buttonsInOrderHorizontally addObject:self.rotateCounterclockwiseButton];
        }
        
        [buttonsInOrderHorizontally addObject:self.resetButton];
        
        if (!self.clampButtonHidden) {
            [buttonsInOrderHorizontally addObject:self.clampButton];
        }
        
        if (!self.rotateClockwiseButtonHidden) {
            [buttonsInOrderHorizontally addObject:self.rotateClockwiseButton];
        }
        
        
        [self layoutToolbarButtons:buttonsInOrderHorizontally withSameButtonSize:buttonSize inContainerRect:containerRect horizontally:YES];
    }
    else {
        CGRect frame = CGRectZero;
        frame.size.height = 44.0f;
        frame.size.width = 44.0f;
        frame.origin.y = CGRectGetHeight(self.bounds) - 44.0f;
        self.cancelIconButton.frame = frame;
        
        frame.origin.y = 0.0f;
        frame.size.width = 44.0f;
        frame.size.height = 44.0f;
        self.doneIconButton.frame = frame;
        
        CGRect containerRect = (CGRect){0,CGRectGetMaxY(self.doneIconButton.frame),44.0f,CGRectGetMinY(self.cancelIconButton.frame)-CGRectGetMaxY(self.doneIconButton.frame)};
        
#if kTOCropToolbarShowButtonsContainerRectForDebugging
        containerView.frame = containerRect;
#endif
        
        CGSize buttonSize = (CGSize){44.0f,44.0f};
        
        if (self.rotateCounterClockwiseButtonHidden) {
            [self layoutToolbarButtons:@[self.resetButton, self.clampButton] withSameButtonSize:buttonSize inContainerRect:containerRect horizontally:NO];
        }
        else {
            NSMutableArray *buttonsInOrderVertically = [@[self.rotateCounterclockwiseButton, self.resetButton, self.clampButton] mutableCopy];
            if (self.rotateClockwiseButton) {
                [buttonsInOrderVertically addObject:self.rotateClockwiseButton];
            }
            
            [self layoutToolbarButtons:buttonsInOrderVertically withSameButtonSize:buttonSize inContainerRect:containerRect horizontally:NO];
        }
    }
}

// The convenience method for calculating button's frame inside of the container rect
- (void)layoutToolbarButtons:(NSArray *)buttons withSameButtonSize:(CGSize)size inContainerRect:(CGRect)containerRect horizontally:(BOOL)horizontally
{
    NSInteger count = buttons.count;
    CGFloat fixedSize = horizontally ? size.width : size.height;
    CGFloat maxLength = horizontally ? CGRectGetWidth(containerRect) : CGRectGetHeight(containerRect);
    CGFloat padding = (maxLength - fixedSize * count) / (count + 1);
    
    for (NSInteger i = 0; i < count; i++) {
        UIView *button = buttons[i];
        CGFloat sameOffset = horizontally ? fabs(CGRectGetHeight(containerRect)-CGRectGetHeight(button.bounds)) : fabs(CGRectGetWidth(containerRect)-CGRectGetWidth(button.bounds));
        CGFloat diffOffset = padding + i * (fixedSize + padding);
        CGPoint origin = horizontally ? CGPointMake(diffOffset, sameOffset) : CGPointMake(sameOffset, diffOffset);
        if (horizontally) {
            origin.x += CGRectGetMinX(containerRect);
            if (i==0) {
                origin.x += 15;
            }else if(i==1)
            {
                origin.x -= 15;
            }
        } else {
            origin.y += CGRectGetMinY(containerRect);
        }
        button.frame = (CGRect){origin, size};
    }
}

- (void)buttonTapped:(id)button
{
    if (button == self.cancelTextButton || button == self.cancelIconButton) {
        if (self.cancelButtonTapped)
            self.cancelButtonTapped();
    }
    else if (button == self.doneTextButton || button == self.doneIconButton) {
        if (self.doneButtonTapped)
            self.doneButtonTapped();
    }
    else if (button == self.resetButton && self.resetButtonTapped) {
        self.resetButtonTapped();
    }
    else if (button == self.rotateCounterclockwiseButton && self.rotateCounterclockwiseButtonTapped) {
        self.rotateCounterclockwiseButtonTapped();
    }
    else if (button == self.rotateClockwiseButton && self.rotateClockwiseButtonTapped) {
        self.rotateClockwiseButtonTapped();
    }
    else if (button == self.clampButton && self.clampButtonTapped) {
        self.clampButtonTapped();
        return;
    }
}

- (CGRect)clampButtonFrame
{
    return self.clampButton.frame;
}

- (void)setClampButtonHidden:(BOOL)clampButtonHidden {
    if (_clampButtonHidden == clampButtonHidden)
        return;
    
    _clampButtonHidden = clampButtonHidden;
    [self setNeedsLayout];
}

- (void)setClampButtonGlowing:(BOOL)clampButtonGlowing
{
    if (_clampButtonGlowing == clampButtonGlowing)
        return;
    
    _clampButtonGlowing = clampButtonGlowing;
    
    if (_clampButtonGlowing)
        self.clampButton.tintColor = nil;
    else
        self.clampButton.tintColor = [UIColor whiteColor];
}

- (void)setRotateCounterClockwiseButtonHidden:(BOOL)rotateButtonHidden
{
    if (_rotateCounterClockwiseButtonHidden == rotateButtonHidden)
        return;
    
    _rotateCounterClockwiseButtonHidden = rotateButtonHidden;
    [self setNeedsLayout];
}

- (BOOL)resetButtonEnabled
{
    return self.resetButton.userInteractionEnabled;
}

- (void)setResetButtonEnabled:(BOOL)resetButtonEnabled
{
    if (!resetButtonEnabled) {
        [_resetButton setTintColor:KResColorDid];
    }else
    {
        [_resetButton setTintColor:KResColorNor];
    }
    self.resetButton.userInteractionEnabled = resetButtonEnabled;
}

- (CGRect)doneButtonFrame
{
    if (self.doneIconButton.hidden == NO)
        return self.doneIconButton.frame;
    
    return self.doneTextButton.frame;
}

#pragma mark - Image Generation -
+ (UIImage *)doneImage
{
    UIImage *doneImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){17,14}, NO, 0.0f);
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = UIBezierPath.bezierPath;
        [rectanglePath moveToPoint: CGPointMake(1, 7)];
        [rectanglePath addLineToPoint: CGPointMake(6, 12)];
        [rectanglePath addLineToPoint: CGPointMake(16, 1)];
        [UIColor.whiteColor setStroke];
        rectanglePath.lineWidth = 2;
        [rectanglePath stroke];
        
        
        doneImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return doneImage;
}

+ (UIImage *)cancelImage
{
    UIImage *cancelImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){16,16}, NO, 0.0f);
    {
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(15, 15)];
        [bezierPath addLineToPoint: CGPointMake(1, 1)];
        [UIColor.whiteColor setStroke];
        bezierPath.lineWidth = 2;
        [bezierPath stroke];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(1, 15)];
        [bezier2Path addLineToPoint: CGPointMake(15, 1)];
        [UIColor.whiteColor setStroke];
        bezier2Path.lineWidth = 2;
        [bezier2Path stroke];
        
        cancelImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return cancelImage;
}

+ (UIImage *)rotateCCWImage
{
    UIImage *rotateImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){18,21}, NO, 0.0f);
    {
        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 9, 12, 12)];
        [UIColor.whiteColor setFill];
        [rectangle2Path fill];
        
        
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = UIBezierPath.bezierPath;
        [rectangle3Path moveToPoint: CGPointMake(5, 3)];
        [rectangle3Path addLineToPoint: CGPointMake(10, 6)];
        [rectangle3Path addLineToPoint: CGPointMake(10, 0)];
        [rectangle3Path addLineToPoint: CGPointMake(5, 3)];
        [rectangle3Path closePath];
        [UIColor.whiteColor setFill];
        [rectangle3Path fill];
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(10, 3)];
        [bezierPath addCurveToPoint: CGPointMake(17.5, 11) controlPoint1: CGPointMake(15, 3) controlPoint2: CGPointMake(17.5, 5.91)];
        [UIColor.whiteColor setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return rotateImage;
}

+ (UIImage *)rotateCWImage
{
    UIImage *rotateCCWImage = [self.class rotateCCWImage];
    UIGraphicsBeginImageContextWithOptions(rotateCCWImage.size, NO, rotateCCWImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, rotateCCWImage.size.width, rotateCCWImage.size.height);
    CGContextRotateCTM(context, M_PI);CGContextDrawImage(context,CGRectMake(0,0,rotateCCWImage.size.width,rotateCCWImage.size.height),rotateCCWImage.CGImage);
    UIImage *rotateCWImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rotateCWImage;
}

+ (UIImage *)resetImage
{
    UIImage *resetImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){22,18}, NO, 0.0f);
    {
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(22, 9)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 18) controlPoint1: CGPointMake(22, 13.97) controlPoint2: CGPointMake(17.97, 18)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 16) controlPoint1: CGPointMake(13, 17.35) controlPoint2: CGPointMake(13, 16.68)];
        [bezier2Path addCurveToPoint: CGPointMake(20, 9) controlPoint1: CGPointMake(16.87, 16) controlPoint2: CGPointMake(20, 12.87)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 2) controlPoint1: CGPointMake(20, 5.13) controlPoint2: CGPointMake(16.87, 2)];
        [bezier2Path addCurveToPoint: CGPointMake(6.55, 6.27) controlPoint1: CGPointMake(10.1, 2) controlPoint2: CGPointMake(7.62, 3.76)];
        [bezier2Path addCurveToPoint: CGPointMake(6, 9) controlPoint1: CGPointMake(6.2, 7.11) controlPoint2: CGPointMake(6, 8.03)];
        [bezier2Path addLineToPoint: CGPointMake(4, 9)];
        [bezier2Path addCurveToPoint: CGPointMake(4.65, 5.63) controlPoint1: CGPointMake(4, 7.81) controlPoint2: CGPointMake(4.23, 6.67)];
        [bezier2Path addCurveToPoint: CGPointMake(7.65, 1.76) controlPoint1: CGPointMake(5.28, 4.08) controlPoint2: CGPointMake(6.32, 2.74)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 0) controlPoint1: CGPointMake(9.15, 0.65) controlPoint2: CGPointMake(11, 0)];
        [bezier2Path addCurveToPoint: CGPointMake(22, 9) controlPoint1: CGPointMake(17.97, 0) controlPoint2: CGPointMake(22, 4.03)];
        [bezier2Path closePath];
        [UIColor.whiteColor setFill];
        [bezier2Path fill];
        
        
        //// Polygon Drawing
        UIBezierPath* polygonPath = UIBezierPath.bezierPath;
        [polygonPath moveToPoint: CGPointMake(5, 15)];
        [polygonPath addLineToPoint: CGPointMake(10, 9)];
        [polygonPath addLineToPoint: CGPointMake(0, 9)];
        [polygonPath addLineToPoint: CGPointMake(5, 15)];
        [polygonPath closePath];
        [UIColor.whiteColor setFill];
        [polygonPath fill];


        resetImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    return resetImage;
}

+ (UIImage *)clampImage
{
    UIImage *clampImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){22,16}, NO, 0.0f);
    {
        //// Color Declarations
        UIColor* outerBox = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.553];
        UIColor* innerBox = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.773];
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 3, 13, 13)];
        [UIColor.whiteColor setFill];
        [rectanglePath fill];
        
        
        //// Outer
        {
            //// Top Drawing
            UIBezierPath* topPath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 22, 2)];
            [outerBox setFill];
            [topPath fill];
            
            
            //// Side Drawing
            UIBezierPath* sidePath = [UIBezierPath bezierPathWithRect: CGRectMake(19, 2, 3, 14)];
            [outerBox setFill];
            [sidePath fill];
        }
        
        
        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(14, 3, 4, 13)];
        [innerBox setFill];
        [rectangle2Path fill];
        
        
        clampImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return clampImage;
}

#pragma mark - Accessors -

- (void)setRotateClockwiseButtonHidden:(BOOL)showClockwiseRotationButton
{
    if (_rotateClockwiseButtonHidden == showClockwiseRotationButton) {
        return;
    }
    
    _rotateClockwiseButtonHidden = showClockwiseRotationButton;
    [self setNeedsLayout];
}

- (void)setRotateButton:(UIButton *)rotateButton
{
    self.rotateCounterclockwiseButton = rotateButton;
}

- (UIButton *)rotateButton
{
    return self.rotateCounterclockwiseButton;
}

@end
