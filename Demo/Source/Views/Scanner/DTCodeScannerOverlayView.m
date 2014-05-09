//
//  DTCoreScannerView.m
//  TagScan
//
//  Created by Oliver Drobnik on 7/12/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "DTCodeScannerOverlayView.h"

@implementation DTCodeScannerOverlayView
{
	UIView *_statusIndicatorView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	 {
		 self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		 self.userInteractionEnabled = NO;

		 self.backgroundColor = [UIColor clearColor];
		 
		 _statusIndicatorView = [[UIView alloc] initWithFrame:CGRectZero];
		 _statusIndicatorView.layer.borderWidth = 1.0f;
		 [self addSubview:_statusIndicatorView];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self _adjustStatusView];
}

- (void)drawRect:(CGRect)rect
{
  	UIColor *darkenColor = [UIColor colorWithWhite:0 alpha:0.2];
	[darkenColor setFill];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextFillRect(context, self.bounds);
	
	if (!CGRectEqualToRect(_scanRegion, CGRectZero))
	{
		CGContextClearRect(context, _scanRegion);
	}
}

- (void)setScanRegion:(CGRect)scanRegion
{
	_scanRegion = scanRegion;
	[self setNeedsDisplay];
}

- (void)_adjustStatusView
{
	if (_showRecognizedBox)
	{
		_statusIndicatorView.frame = _scanRegion;
		_statusIndicatorView.layer.borderColor = [UIColor greenColor].CGColor;
	}
	else
	{
		CGRect frame = CGRectMake(CGRectGetMinX(_scanRegion), CGRectGetMidY(_scanRegion), _scanRegion.size.width, 1);
		_statusIndicatorView.frame = frame;
		_statusIndicatorView.layer.borderColor = [UIColor redColor].CGColor;
	}
}

- (void)setShowRecognizedBox:(BOOL)showRecognizedBox animated:(BOOL)animated
{
	if (_showRecognizedBox != showRecognizedBox)
	{
		_showRecognizedBox = showRecognizedBox;
		
		if (animated)
		{
			CGFloat duration = _showRecognizedBox?0.20:0.10;
			
			[UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
				
				[self _adjustStatusView];
			} completion:NULL];
		}
		else
		{
			[self _adjustStatusView];
		}
	}
}

- (void)setShowRecognizedBox:(BOOL)showRecognizedBox
{
	[self setShowRecognizedBox:showRecognizedBox animated:NO];
}

@end
