//
//  PLYUserNameValidator.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYUserNameValidator.h"

@implementation PLYUserNameValidator

- (void)validate
{
   UITextField *field = (UITextField *)self.control;

   NSString *user = field.text;
   
   if (![user length])
   {
      self.valid = NO;
      return;
   }
   
   NSRange rangeOfWhitespace = [user rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
   if (rangeOfWhitespace.location != NSNotFound)
   {
      self.valid = NO;
      return;
   }
   
   self.valid = YES;
}

@end
