//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface NSDictionary (MSIDTestUtil)

- (NSArray<NSURLQueryItem *> *)urlQueryItemsArray;

- (BOOL)compareAndPrintDiff:(NSDictionary *)dictionary;
- (BOOL)compareAndPrintDiff:(NSDictionary *)dictionary
      dictionaryDescription:(NSString *)description;

- (NSString *)msidBase64UrlJson;

@end

/*!
 Sentinel class to use for values you want to make sure are present in a dictionary but don't
 care about the actual value.
 */
@interface MSIDTestRequireValueSentinel : NSObject

+ (instancetype)sentinel;

@end


/*!
 Sentinel class to use for values you don't care if it is present or not
 */
@interface MSIDTestIgnoreSentinel : NSObject

+ (instancetype)sentinel;

@end
