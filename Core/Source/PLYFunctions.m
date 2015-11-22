//
//  PLYFunctions.m
//  PL
//
//  Created by Oliver Drobnik on 30/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYFunctions.h"
#import "PLYProduct.h"

DTColor *_overrideBrandColor = nil;

PLYProduct *PLYProductBestMatchingUserPreferredLanguages(NSArray *products)
{
	NSMutableArray *languages = [[NSLocale preferredLanguages] mutableCopy];
	
	// according to http://www.weltsprachen.net and http://www.w3schools.com/tags/ref_language_codes.asp
	NSArray *secondaryLanguages = @[@"en",  // English
											  @"zh",  // Chinese
											  @"hi",  // Hindi
											  @"es",  // Spanish
											  @"fr",  // French
											  @"ar",  // Arabic
											  @"ru",  // Russian
											  @"pt",  // Portuguese
											  @"bn",  // Bengalese
											  @"de",  // German
											  @"ja",  // Japanese
											  @"ko"   // Korean
											 ];
	
	for (NSString *secondLang in secondaryLanguages)
	{
		if (![languages containsObject:secondLang])
		{
			[languages addObject:secondLang];
		}
	}
	
	for (NSString *lang in languages)
	{
		for (PLYProduct *product in products)
		{
			if ([product.language isEqualToString:lang])
			{
				return product;
			}
		}
	}
	
	// preferred language does not exist
	NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"updatedTime" ascending:NO];
	NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:NO];
	
	NSArray *sorted = [products sortedArrayUsingDescriptors:@[sort1, sort2]];
	
	return [sorted firstObject];
}

NSUInteger PLYCheckDigitForGTIN(NSString *GTIN)
{
	if ([GTIN length]>14)
	{
		// too long
		return NO;
	}
	
	// pad to 14 digits
	while ([GTIN length]<14)
	{
		GTIN = [@"0" stringByAppendingString:GTIN];
	}
	
	NSInteger sum = 0;
	
	// sum the first
	for (NSInteger i = 0; i<13; i++)
	{
		NSInteger digit = [[GTIN substringWithRange:NSMakeRange(i, 1)] integerValue];
		
		// every second value multiplied by 3
		if ((i+1)%2)
		{
			digit *= 3;
		}
		
		sum += digit;
	}
	
	NSInteger check = (10 - (sum%10)) % 10;
	return check;
}

BOOL PLYIsValidGTIN(NSString *GTIN)
{
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+$" options:0 error:NULL];
	
	NSArray *matches = [regex matchesInString:GTIN options:0 range:NSMakeRange(0, [GTIN length])];
	
	if ([matches count]!=1)
	{
		// not numeric
		return NO;
	}
	
	NSInteger checkDigit = PLYCheckDigitForGTIN(GTIN);
	NSInteger lastDigit = [[GTIN substringWithRange:NSMakeRange(GTIN.length-1, 1)] integerValue];
	
	return lastDigit == checkDigit;
}

#pragma mark - Localization and Resources

NSBundle *PLYResourceBundle()
{
	// bundle reference only retrieved once
	static NSBundle *_resourceBundle = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// get the same bundle where one of the core entities classes are located in
		NSBundle *bundle = [NSBundle bundleForClass:[PLYImage class]];
		
        NSString *resourceBundlePath = [bundle pathForResource:@"ProductLayerSDK" ofType:@"bundle"];
        if (resourceBundlePath)
        {
            _resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
        }
        else
        {
            // inside a framework, but no bundle found, so that framework IS the resource bundle
            _resourceBundle = bundle;
        }
	});
	
	return _resourceBundle;
}

DTColor *PLYBrandColor()
{
	if (_overrideBrandColor)
	{
		return _overrideBrandColor;
	}
	
	return [DTColor colorWithRed:110.0/256.0 green:190.0/256.0 blue:68.0/256.0 alpha:1];
}

NSString *PLYLocalizedStringFromTable(NSString *key, NSString *tbl, NSString *comment)
{
    return NSLocalizedStringFromTableInBundle(key, tbl, PLYResourceBundle(), comment);
}

void PLYBrandColorSetOverride(DTColor *color)
{
	_overrideBrandColor = color;
}

BOOL PLYGTINIsValidGlobally(NSString *GTIN)
{
	NSUInteger length = [GTIN length];
	
	if (!(length == 8 ||
			length == 12 ||
			length == 13))
	{
		[NSException raise:@"PLYGTINException" format:@"Incorrect GTIN Length"];
	}
	
	if (length == 12)
	{
		// add invisible 0 to GTIN-12
		GTIN = [@"0" stringByAppendingString:GTIN];
		length++;
	}
	
	// handle GTIN-13
	
	if (length == 13)
	{
		if ([GTIN hasPrefix:@"02"])
		{
			// GS1 Variable Measure Trade Item identification for restricted distribution
			return NO;
		}

		if ([GTIN hasPrefix:@"04"])
		{
			// GS1 restricted circulation number within a company
			return NO;
		}

		if ([GTIN hasPrefix:@"05"])
		{
			// GS1 US coupon identification
			return NO;
		}
		
		NSUInteger prefix2 = [[GTIN substringToIndex:2] integerValue];
		
		if (prefix2 >= 20 && prefix2 <= 29)
		{
			// GS1 restricted circulation number within a geographic region
			return NO;
		}
		
		if ([GTIN hasPrefix:@"980"])
		{
			// GS1 identification of Refund Receipts
			return NO;
		}
		
		NSUInteger prefix3 = [[GTIN substringToIndex:3] integerValue];
		
		if (prefix3 >= 981 && prefix3 <= 984)
		{
			// GS1 coupon identification for common currency areas
			return NO;
		}

		if (prefix3 >= 985 && prefix3 <= 989)
		{
			// Reserved for further GS1 coupon identification
			return NO;
		}
		
		if ([GTIN hasPrefix:@"99"])
		{
			// GS1 coupon identification
			return NO;
		}
		
		return YES;
	}
	
	// handle GTIN-8
	
	if ([GTIN hasPrefix:@"0"])
	{
		// Velocity Codes
		return NO;
	}
	
	if ([GTIN hasPrefix:@"2"])
	{
		// GS1 restricted circulation number within a company
		return NO;
	}
	
	NSUInteger prefix2 = [[GTIN substringToIndex:2] integerValue];
	
	if (prefix2 >= 97 && prefix2 <= 99)
	{
		// Reserve
		return NO;
	}
	
	NSUInteger prefix3 = [[GTIN substringToIndex:3] integerValue];
	
	if ((prefix3 >= 140 && prefix3 <= 199))
	{
		// Reserve
		return NO;
	}
	
	// 100-139, 300-969 fall through
	return YES;
}


NSString *PLYUPCAFromUPCE(NSString *UPCE)
{
	if ([UPCE length]==6)
	{
		// do nothing everything is OK
		return UPCE;
	}
	
	if ([UPCE length]==7)
	{
		// truncate last digit - assume that it is the UPCE check digit
		UPCE = [UPCE substringWithRange:NSMakeRange(0, UPCE.length-1)];
	}
	else if ([UPCE length]==8)
	{
		// truncate first and last digit
		// assume that the first digit is the number system digit
		// and the last digit is the UPCE check digit
		UPCE = [UPCE substringWithRange:NSMakeRange(0, UPCE.length-1)];
	}
	
	NSInteger digit1 = [[UPCE substringWithRange:NSMakeRange(1, 1)] integerValue];
	NSInteger digit2 = [[UPCE substringWithRange:NSMakeRange(2, 1)] integerValue];
	NSInteger digit3 = [[UPCE substringWithRange:NSMakeRange(3, 1)] integerValue];
	NSInteger digit4 = [[UPCE substringWithRange:NSMakeRange(4, 1)] integerValue];
	NSInteger digit5 = [[UPCE substringWithRange:NSMakeRange(5, 1)] integerValue];
	NSInteger digit6 = [[UPCE substringWithRange:NSMakeRange(6, 1)] integerValue];
	
	NSString *manufacturer;
	NSString *item;
	
	switch (digit6)
	{
		case 0:
		case 1:
		case 2:
		{
			manufacturer = [NSString stringWithFormat:@"%ld%ld%ld00", (long)digit1, (long)digit2, (long)digit6];
			item = [NSString stringWithFormat:@"00%ld%ld%ld", (long)digit3, (long)digit4, (long)digit5];
			break;
		}

		case 3:
		{
			manufacturer = [NSString stringWithFormat:@"%ld%ld%ld00", (long)digit1, (long)digit2, (long)digit3];
			item = [NSString stringWithFormat:@"000%ld%ld", (long)digit4, (long)digit5];
			break;
		}

		case 4:
		{
			manufacturer = [NSString stringWithFormat:@"%ld%ld%ld%ld0", (long)digit1, (long)digit2, (long)digit3, (long)digit4];
			item = [NSString stringWithFormat:@"0000%ld", (long)digit5];
			break;
		}
			
		default:
		{
			manufacturer = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld", (long)digit1, (long)digit2, (long)digit3, (long)digit4, (long)digit5];
			item = [NSString stringWithFormat:@"0000%ld", (long)digit6];
		}
	}
	
	NSString *message = [NSString stringWithFormat:@"0%@%@0", manufacturer, item];
	NSUInteger checkDigit = PLYCheckDigitForGTIN(message);
	
	return [NSString stringWithFormat:@"0%@%@%ld", manufacturer, item, (long)checkDigit];
}

#pragma mark - Gamification

double __logx(double value, double base)
{
    return log10(value) / log10(base);
}

double PLYLevelForPoints(NSUInteger points)
{
    return 1.0 + __logx(6600.0 + (double)points, 1.05) - __logx(6600.0, 1.05);
}

double PLYPercentProgressInLevelForPoints(NSUInteger points)
{
    double exactLevel = PLYLevelForPoints(points);
    double level = floor(exactLevel);
    return exactLevel - level;
}
