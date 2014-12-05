//
//  PLYVideoPreviewInterestBox.m
//  ProductLayer SDK
//
//  Created by Oliver Drobnik on 11/12/13.
//  Copyright (c) 2013 ProductLayer. All rights reserved.
//

#import "PLYVideoPreviewInterestBox.h"

#define EDGE_LENGTH 20.0

@implementation PLYVideoPreviewInterestBox

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.image)
	{
		self.image = [self _stretchableImage];
	}
}

// allow resizing via auto layout
- (CGSize)intrinsicContentSize
{
	return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

// creates a stretchable image of the finder view
- (UIImage *)_stretchableImage
{
	CGRect box = CGRectMake(0, 0, 100, 100);
	
	UIGraphicsBeginImageContextWithOptions(box.size, NO, 0);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(ctx);
	
	CGContextSetGrayFillColor(ctx, 1, 0.05);
	CGContextFillRect(ctx, box);
	
	CGContextRestoreGState(ctx);
	
	CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 0.5);
	
	CGFloat lineWidth=2;
	box = CGRectInset(box, lineWidth/2.0, lineWidth/2.0);
	
	CGContextSetLineWidth(ctx, lineWidth);
	
	CGFloat minX = CGRectGetMinX(box);
	CGFloat minY = CGRectGetMinY(box);
	
	CGFloat maxX = CGRectGetMaxX(box);
	CGFloat maxY = CGRectGetMaxY(box);
	
	// top left
	CGContextMoveToPoint(ctx, minX, minY + EDGE_LENGTH);
	CGContextAddLineToPoint(ctx, minX, minY);
	CGContextAddLineToPoint(ctx, minX +  EDGE_LENGTH, minY);
	
	// bottom left
	CGContextMoveToPoint(ctx, minX, maxY - EDGE_LENGTH);
	CGContextAddLineToPoint(ctx, minX, maxY);
	CGContextAddLineToPoint(ctx, minX +  EDGE_LENGTH, maxY);
	
	// top right
	CGContextMoveToPoint(ctx, maxX - EDGE_LENGTH, minY);
	CGContextAddLineToPoint(ctx, maxX, minY);
	CGContextAddLineToPoint(ctx, maxX, minY +  EDGE_LENGTH);
	
	// bottom right
	CGContextMoveToPoint(ctx, maxX - EDGE_LENGTH, maxY);
	CGContextAddLineToPoint(ctx, maxX, maxY);
	CGContextAddLineToPoint(ctx, maxX, maxY -  EDGE_LENGTH);
	
	CGContextStrokePath(ctx);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	// make stretchable image caps wide enough so that only the inside is stretched
	CGFloat cap = EDGE_LENGTH+lineWidth;
	return [image stretchableImageWithLeftCapWidth:cap topCapHeight:cap];
}

@end
