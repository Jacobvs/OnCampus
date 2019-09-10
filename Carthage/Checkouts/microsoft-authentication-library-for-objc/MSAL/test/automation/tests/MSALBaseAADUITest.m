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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MSALBaseAADUITest.h"
#import "XCUIElement+CrossPlat.h"
#import "MSIDAADIdTokenClaimsFactory.h"

@implementation MSALBaseAADUITest

#pragma mark - Shared parameterized steps

- (NSString *)runSharedAADLoginWithTestRequest:(MSALTestRequest *)request
{
    NSDictionary *config = [self configWithTestRequest:request];
    [self acquireToken:config];

    [self acceptAuthSessionDialogIfNecessary:request];
    [self assertAuthUIAppearsUsingEmbeddedWebView:request.usesEmbeddedWebView];

    if (request.usePassedWebView)
    {
        XCTAssertTrue(self.testApp.staticTexts[@"PassedIN"]);
    }

    if (!request.loginHint && !request.accountIdentifier)
    {
        [self aadEnterEmail];
    }

    [self aadEnterPassword];
    [self acceptMSSTSConsentIfNecessary:self.consentTitle ? self.consentTitle : @"Accept" embeddedWebView:request.usesEmbeddedWebView];

    NSString *homeAccountId = [self runSharedResultAssertionWithTestRequest:request guestTenantScenario:NO];

    [self closeResultView];
    return homeAccountId;
}

- (void)runSharedSilentAADLoginWithTestRequest:(MSALTestRequest *)request
{
    [self runSharedSilentAADLoginWithTestRequest:request guestTenantScenario:NO];
}

- (void)runSharedSilentAADLoginWithTestRequest:(MSALTestRequest *)request
                           guestTenantScenario:(BOOL)usesGuestTenant
{
    NSDictionary *config = [self configWithTestRequest:request];
    // Acquire token silently
    [self acquireTokenSilent:config];
    [self assertAccessTokenNotNil];
    [self closeResultView];

    NSMutableDictionary *mutableConfig = [config mutableCopy];

    // The developer provided authority is not necessarily the authority that MSAL does cache lookups with
    // Therefore, authority used to expire access token might be different
    if (request.cacheAuthority) mutableConfig[@"authority"] = request.cacheAuthority;

    // Now expire access token
    [self expireAccessToken:mutableConfig];
    [self assertAccessTokenExpired];
    [self closeResultView];

    // Now do access token refresh
    [self acquireTokenSilent:config];
    [self assertAccessTokenNotNil];

    [self runSharedResultAssertionWithTestRequest:request guestTenantScenario:usesGuestTenant];

    [self closeResultView];

    // Now lookup access token without authority
    mutableConfig[@"authority"] = request.authority;
    mutableConfig[@"silent_authority"] = nil;

    [self acquireTokenSilent:mutableConfig];
    [self runSharedResultAssertionWithTestRequest:request guestTenantScenario:usesGuestTenant];
    [self closeResultView];
}

- (void)runSharedAuthUIAppearsStepWithTestRequest:(MSALTestRequest *)request
{
    NSDictionary *config = [self configWithTestRequest:request];
    [self acquireToken:config];

    [self acceptAuthSessionDialogIfNecessary:request];

    [self assertAuthUIAppearsUsingEmbeddedWebView:request.usesEmbeddedWebView];
    [self closeAuthUIUsingWebViewType:request.webViewType passedInWebView:request.usePassedWebView];

    [self assertErrorCode:request.usePassedWebView ? @"MSALErrorSessionCanceled" : @"MSALErrorUserCanceled"];
    [self closeResultView];
}

- (NSString *)runSharedResultAssertionWithTestRequest:(MSALTestRequest *)request
                                  guestTenantScenario:(BOOL)usesGuestTenant
{
    [self assertAccessTokenNotNil];
    [self assertScopesReturned:request.expectedResultScopes];
    [self assertAuthorityReturned:request.expectedResultAuthority];

    NSDictionary *resultDictionary = [self resultDictionary];
    NSString *homeAccountId = resultDictionary[@"user"][@"home_account_id"];
    XCTAssertNotNil(homeAccountId);

    if (request.testAccount)
    {
        NSDictionary *result = [self resultDictionary];
        NSString *resultTenantId = result[@"tenantId"];

        NSString *idToken = result[@"id_token"];
        XCTAssertNotNil(idToken);

        MSIDIdTokenClaims *claims = [MSIDAADIdTokenClaimsFactory claimsFromRawIdToken:idToken error:nil];
        XCTAssertNotNil(idToken);

        NSString *idTokenTenantId = claims.jsonDictionary[@"tid"];

        if (!usesGuestTenant)
        {
            XCTAssertEqualObjects(resultTenantId, request.testAccount.homeTenantId);
        }
        else
        {
            XCTAssertEqualObjects(resultTenantId, request.testAccount.targetTenantId);
        }

        XCTAssertEqualObjects(resultTenantId, idTokenTenantId);
        XCTAssertEqualObjects(homeAccountId, request.testAccount.homeAccountId);
    }

    return homeAccountId;
}

- (void)selectAccountWithTitle:(NSString *)accountTitle
{
    XCUIElement *pickAccount = self.testApp.staticTexts[@"Pick an account"];
    [self waitForElement:pickAccount];

    NSPredicate *accountPredicate = [NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", accountTitle];

    XCUIElement *element = [[self.testApp.staticTexts containingPredicate:accountPredicate] elementBoundByIndex:0];
    XCTAssertNotNil(element);

    [element msidTap];
}

@end
