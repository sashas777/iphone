//
//  AppDelegate.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASplitViewController;
@class MARootViewController;

@interface MAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MASplitViewController *splitViewController;
@property (nonatomic, strong) UINavigationController *rootNavigationController;
@property (nonatomic, strong) MARootViewController *theRootestViewController;

@end


/*


 h ttp://www.extensions.sashas.org/
 21.10.14
 Api
 iphone - username
 iphone api key

 name: iphone
 key: ef972f566e5a86dfc735f11a2d970229
 secret: 717cdb296b0631a5b09484c3edb66974
 
 h ttp://www.extensions.sashas.org/magento/oauth/authorize?oauth_token=ef972f566e5a86dfc735f11a2d970229
 
 h ttp://www.extensions.sashas.org/magento/api/rest/products?oauth_consumer_key=tydkxii2jyswedm6uo2cfcjay7uy0crws&oauth_nonce=HWJHh83HKeJnsFahdQxye52dapt8F7bswrnLcAYjsy&oauth_signature=%2FkHLJKs9W3fmWRVxAPrd8R7LHDs%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1335162435&oauth_token=aqvlfv9tuexn0mqiydgkaff4ixxgs58s&oauth_version=1.0
 
*/