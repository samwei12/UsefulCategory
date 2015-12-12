/**
 *  @author Xiaosen Dong, 15-01-07
 *
 *  @brief  Warnings:All this category do task in background thread,
 *
 */
#import <AssetsLibrary/AssetsLibrary.h>
@import ImageIO;
@import UIKit;
typedef void (^ALAssetsLibraryFetchCompletionBlock)(NSArray *results);

@interface ALAssetsLibrary (AssetsLibraryKit)

@property (nonatomic, assign, readonly) BOOL canRequestAccess;
@property (nonatomic, assign, readonly) BOOL authorized;

+ (ALAssetsLibrary *) sharedLibrary;

- (void) requestAuthorization:(void(^)(BOOL granted))block;

#pragma mark - Group
	// get certain groups
- (void) fetchGroupsForURLs:(NSArray *)urls
			completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;

	// get certain group with url
- (void) fetchGroupsForURL:(NSURL *) url
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;

	// important
	// in use for get group and create group
	// get certain group with name, create one if not exist,
- (void) fetchGroupForName:(NSString *) name
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock) completionBlock
			  failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

	// get all groups
- (void) fetchGroupsWithCompletionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock
						   failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

#pragma mark - Assets
	// get certain assets from all groups
- (void) fetchAssetsForURLs:(NSArray *)urls
			completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;
	// get certain asset from all groups
- (void) fetchAssetsForURL:(NSURL *)url
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;


	// get all assets from certain group
- (void) fetchAssetsFromGroup:(ALAssetsGroup *)group
			  completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;


	// get certain assets from certain group
- (void) fetchAssetsForURL:(NSURL *)url
				 fromGroup:(ALAssetsGroup *) group
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;
@end

@interface ALAssetsGroup (AssetsLibraryKit)

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSURL    *url;

	// in use for get all item
- (void) fetchAssetsWithcompletionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;

	// in use for save.delete and get image
- (void) fetchAssetsForURLString:(NSString *) urlString
			  andcompletionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock;

@end

@interface ALAsset (AssetsLibraryKit)

@property (nonatomic, strong, readonly) NSURL      *url;
@property (nonatomic, strong, readonly) NSString   *assetType;
@property (nonatomic, strong, readonly) NSString   *name;
@property (nonatomic, strong, readonly) UIImage    *image;
@property (nonatomic, strong, readonly) NSData     *imageData;
@property (nonatomic, assign, readonly) CGImageRef fullSizeImage;

#pragma mark - Flurry
@property (nonatomic, strong, readonly) NSString   *shareInfoString;
@property (nonatomic, copy, readonly) NSString *effectTitle;
@property (nonatomic, copy, readonly) NSString *devicePosition;
@property (nonatomic, copy, readonly) NSString *flashMode;
@end