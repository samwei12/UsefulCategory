//
//  ViewUtils.h
//
//  Version 1.1.2
//
//  Created by Nick Lockwood on 19/11/2011.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/ViewUtils
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import <UIKit/UIKit.h>

@interface UIView (ViewUtils)

//nib loading
/**
 *  This method loads a view from a nib file. The view to be loaded must be the first object in the file. This method is useful for loading views such as UITableViewCells, or iCarousel item views. The nib file is cached, so subequent loads will perform better.
 */
+ (id)instanceWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil owner:(id)owner;
/**
 *  This method is similar to instanceWithNibName:, but instead of returning the first view in the nib file, this method loads that view and then adds it as a subview to the view on which the method is called, resizing the loaded view to fit the bounds of the superview if neccesary. This is especially useful if you want to create a complex view composed of reusable subviews, each stored in their own nib file.
 */
- (void)loadContentsWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil;

//hierarchy
/**
 *  Returns either the view itself or the first subview that matches the specified predicate. If no subview matches, the method returns nil.
 */
- (UIView *)viewMatchingPredicate:(NSPredicate *)predicate;
/**
 *  Returns either the view itself or the first subview that has the specified tag value, and is of the specified class. This is safer than the regular viewWithTag: method.
 */
- (UIView *)viewWithTag:(NSInteger)tag ofClass:(Class)viewClass;
/**
 *  Returns either the view itself or the first subview of the specified class.
 */
- (UIView *)viewOfClass:(Class)viewClass;


/**
 *  These methods work exactly like their single-view equivalents, but instead of returning the first view that matches, they return all views that match. The search is performed in a depth-first fashion.
 */
- (NSArray *)viewsMatchingPredicate:(NSPredicate *)predicate;
- (NSArray *)viewsWithTag:(NSInteger)tag;
- (NSArray *)viewsWithTag:(NSInteger)tag ofClass:(Class)viewClass;
- (NSArray *)viewsOfClass:(Class)viewClass;

/**
 *  These methods work like the viewMatching/Of/Width versions, but work up the view hierarchy instead of down and will return the first parent view that matches the specified criteria.
 *
 */
- (UIView *)firstSuperviewMatchingPredicate:(NSPredicate *)predicate;
- (UIView *)firstSuperviewOfClass:(Class)viewClass;
- (UIView *)firstSuperviewWithTag:(NSInteger)tag;
- (UIView *)firstSuperviewWithTag:(NSInteger)tag ofClass:(Class)viewClass;

/**
 *  This method returns YES if the view, or any superview in in the chain matches the criteria. This is useful for event handling, for example if you'd like to know if a given touch was either on or within a given control or control type, e.g. so you can ignore gestures performed on specific views.
 */
- (BOOL)viewOrAnySuperviewMatchesPredicate:(NSPredicate *)predicate;
- (BOOL)viewOrAnySuperviewIsKindOfClass:(Class)viewClass;

/**
 *  These methods allow you to determine if a view is a child of another view. These methods will search the entire superview chain, not just a single level, so if one view is the superview of the superview of the other one, it will still return YES.
 */
- (BOOL)isSuperviewOfView:(UIView *)view;
- (BOOL)isSubviewOfView:(UIView *)view;

/**
 *  This method uses the responder chain to identify the first view controller in the controller chain that is responsible for the view. So for example, if this method is called on a button, it will return the view controller that hosts the view that contains that button.
 *
 */
- (UIViewController *)firstViewController;

/**
 *  This method returns the first responder if it is a subview of the view on which the method is called, or nil if not. If you don't know which subview tree the first responder might be located in, calling this method on the main window or the root view of the current frontmost view controller should return the desired result.
 *
 */
- (UIView *)firstResponder;

//frame accessors

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

//bounds accessors

@property (nonatomic, assign) CGSize boundsSize;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;

//content getters

@property (nonatomic, readonly) CGRect contentBounds;
@property (nonatomic, readonly) CGPoint contentCenter;

//additional frame setters
/**
 *  It's often fiddly to set both the left and right edges of a view, or set the width without affecting the right-hand edge because the properties are linked. These setter methods make it a little easier to do this by allowing you to set both properties with a single method call.
 */
- (void)setLeft:(CGFloat)left right:(CGFloat)right;
- (void)setWidth:(CGFloat)width right:(CGFloat)right;
- (void)setTop:(CGFloat)top bottom:(CGFloat)bottom;
- (void)setHeight:(CGFloat)height bottom:(CGFloat)bottom;

//animation
/**
 *  These methods use Core Animation to perform a crossfade transition of the specified duration. A crossfade is often useful if you want to animate the change of some view property that does not already support animation. A typical example would be changing the text in a UILabel or the image in a UIImageView.
 *
 */
- (void)crossfadeWithDuration:(NSTimeInterval)duration;
- (void)crossfadeWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

@end

