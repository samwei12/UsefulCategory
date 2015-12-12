#import "ALAssetsLibrary+AssetsLibraryKit.h"

@implementation ALAssetsLibrary (AssetsLibraryKit)

#pragma mark - Lifecycle

+ (ALAssetsLibrary *)sharedLibrary {

	static dispatch_once_t onceToken;
	static ALAssetsLibrary *_sharedInstance = nil;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[super alloc] init];
	});
	return _sharedInstance;
}

#pragma mark - Public methods

- (BOOL) canRequestAccess {
	return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined;

}

- (BOOL) authorized {
	return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized;
}

- (void) requestAuthorization:(void(^)(BOOL granted))block {

	void(^callBlock)(BOOL granted) = ^(BOOL granted) {
		if (block) {
			block(granted);
		}
	};

	if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
		callBlock(YES);
		return;
	}

	[self enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
			// avoid duplication call
		if (group || !*stop) {
			*stop = YES;
			callBlock(YES);
		}
	} failureBlock:^(NSError *error) {
		callBlock(NO);
	}];
}

#pragma mark - Group
- (void) fetchGroupsWithCompletionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock
						   failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

		__block NSMutableArray *groups = [NSMutableArray array];
		[self enumerateGroupsWithTypes:ALAssetsGroupAll
							usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
								if (group) {
									[groups addObject:group];
								}
								else {
									if (completionBlock) {
										completionBlock(groups);
									}
								}

							}
						  failureBlock:^(NSError *error) {
							  if (failureBlock) {
								  failureBlock(error);
							  }
						  }];
	});
}

- (void) fetchGroupsForURLs:(NSArray *)urls
			completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {

	if (urls.count == 0) {
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

		__block NSMutableArray *groups = [NSMutableArray array];

		for (NSInteger index = 0; index < urls.count; index++) {

			NSURL *url = urls[index];
			[self groupForURL:url
				  resultBlock:^(ALAssetsGroup *group) {

				if (group) [groups addObject:group];

				if (index == urls.count - 1) {
					if (completionBlock) {
						completionBlock(groups);
					}
				}
			}
				 failureBlock:^(NSError *error) {

				if (index == urls.count - 1) {
					if (completionBlock) {
						completionBlock(groups);
					}
				}
			}];
		}
	});
}

- (void) fetchGroupsForURL:(NSURL *)url
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {
	if (!url) {
		return;
	}
	[self fetchGroupsForURLs:@[url]
			 completionBlock:completionBlock];
}

- (void) fetchGroupForName:(NSString *)name
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock
			  failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {

	if (!name) {
		return;
	}

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		__block NSMutableArray *groups = [NSMutableArray array];
		[self enumerateGroupsWithTypes:ALAssetsGroupAll
							usingBlock:^(ALAssetsGroup *group, BOOL *stop)
		 {

			 if ([group.name isEqualToString:name]) {
				 [groups addObject:group];
			 }
				 // not match,do nothing
			 else if (group) {

			 }

			 else {
					 // return results
				 if (groups.count > 0) {
					 if (completionBlock) {
						 completionBlock(groups);
					 }
				 }
				 else {
					 ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group)
					 {
							 // if user created this group,then delete it,we can't created it again
						 if (group) {
							 [groups addObject:group];
							 if (completionBlock) {
								 completionBlock(groups);
							 }
						 }
						 else {
							 NSError *error = [NSError errorWithDomain:@"repeat name"
																  code:-1
															  userInfo:nil];
								 // create failed
							 if (failureBlock) {
								 failureBlock(error);
							 }
						 }
					 };
					 ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
						 if (error) {
							 NSLog(@"Error creating album: %@", error);
						 }
					 };

						 //由于 iOS8上使用 ALAsset 创建相同名称相册会失败,所以使用 PHPhotoLibrary

					 if (IOS_VERSION_UPPER_THAN_8_0) {
							 // PHPhotoLibrary_class will only be non-nil on iOS 8.x.x
						 Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");
						 /**
						  *
						  iOS 8..x. . code that has to be called dynamically at runtime and will not link on iOS 7.x.x ...

						  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
						  [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
						  } completionHandler:^(BOOL success, NSError *error) {
						  if (!success) {
						  NSLog(@"Error creating album: %@", error);
						  }
						  }];
						  */
							 // dynamic runtime code for code chunk listed above
						 id sharedPhotoLibrary = [PHPhotoLibrary_class performSelector:NSSelectorFromString(@"sharedPhotoLibrary")];

						 SEL performChanges = NSSelectorFromString(@"performChanges:completionHandler:");

						 NSMethodSignature *methodSig = [sharedPhotoLibrary methodSignatureForSelector:performChanges];

						 NSInvocation* inv = [NSInvocation invocationWithMethodSignature:methodSig];
						 [inv setTarget:sharedPhotoLibrary];
						 [inv setSelector:performChanges];

						 void(^firstBlock)() = ^void() {
							 Class PHAssetCollectionChangeRequest_class = NSClassFromString(@"PHAssetCollectionChangeRequest");
							 SEL creationRequestForAssetCollectionWithTitle = NSSelectorFromString(@"creationRequestForAssetCollectionWithTitle:");
							 [PHAssetCollectionChangeRequest_class performSelector:creationRequestForAssetCollectionWithTitle withObject:name];

						 };

						 void (^secondBlock)(BOOL success, NSError *error) = ^void(BOOL success, NSError *error) {
							 if (success) {
								 [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
									 if (group) {
										 NSString *name2 = [group valueForProperty:ALAssetsGroupPropertyName];
										 if ([name isEqualToString:name2]) {
											 resultBlock(group);
										 }
									 }
								 } failureBlock:^(NSError *error) {
									 NSLog(@"Error creating album: %@", error);
								 }];
							 }

							 if (error) {
								 NSLog(@"Error creating album: %@", error);
							 }
						 };

							 // Set the success and failure blocks.
						 [inv setArgument:&firstBlock atIndex:2];
						 [inv setArgument:&secondBlock atIndex:3];
						 
						 [inv invoke];
						 /*
						 PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
						 [library performChanges:^{
							 [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:name];
						 }
							   completionHandler:^(BOOL success, NSError *error) {
								   if (success) {
									   [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
														   usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
										   if (group) {
											   NSString *name2 = [group valueForProperty:ALAssetsGroupPropertyName];
											   if ([name isEqualToString:name2]) {
												   resultBlock(group);
											   }
										   }
									   }
														 failureBlock:failureBlock];
								   }

								   if (error) {
									   NSLog(@"Error creating album: %@", error);
								   }
							   }];
						  */
					 }
					 else {
							 // no result, create a new one
						 [self addAssetsGroupAlbumWithName:name
											   resultBlock:resultBlock
											  failureBlock:^(NSError *error) {
													  // create failed
												  if (failureBlock) {
													  failureBlock(error);
												  }
											  }];
					 }
				 }
			 }
		 }
						  failureBlock:^(NSError *error) {
							  if (failureBlock) {
								  failureBlock(error);
							  }
						  }];
	});
}

#pragma mark - Assets

- (void) fetchAssetsForURLs:(NSArray *)urls
			completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {
	if (urls.count == 0) {
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

		__block NSMutableArray *assets = [NSMutableArray array];

		for (NSInteger index = 0; index < urls.count; index++) {

			NSURL *url = urls[index];
			[self assetForURL:url
				  resultBlock:^(ALAsset *asset) {
					  if (asset) {
						  [assets addObject:asset];
					  }

					  if (index == urls.count - 1) {
						  if (completionBlock) {
							  completionBlock(assets);
						  }
					  }

				  }
				 failureBlock:^(NSError *error) {

					 if (index == urls.count - 1) {
						 if (completionBlock) {
							 completionBlock(assets);
						 }
					 }
				 }];
		}
	});
}

- (void) fetchAssetsForURL:(NSURL *)url
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {
	if (!url) {
		return;
	}
	[self fetchAssetsForURLs:@[url]
			 completionBlock:completionBlock];
}

- (void) fetchAssetsFromGroup:(ALAssetsGroup *)group
			  completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {
	[group fetchAssetsWithcompletionBlock:completionBlock];
}

- (void) fetchAssetsForURL:(NSURL *)url
				 fromGroup:(ALAssetsGroup *)group
		   completionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {
	[group fetchAssetsForURLString:url.absoluteString
				andcompletionBlock:completionBlock];
}
@end

@implementation ALAssetsGroup (AssetsLibraryKit)

- (NSString *)name {

	return [self valueForProperty:ALAssetsGroupPropertyName];
}

- (NSURL *)url {

	return [self valueForProperty:ALAssetsGroupPropertyURL];
}

- (void) fetchAssetsWithcompletionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

		__block NSMutableArray *assets = [NSMutableArray array];

		[self enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
			if (asset) {
				[assets addObject:asset];
			}
			else {
				if (completionBlock) {
					completionBlock(assets);
				}
			}
		}];
	});
}

- (void) fetchAssetsForURLString:(NSString *)urlString
			  andcompletionBlock:(ALAssetsLibraryFetchCompletionBlock)completionBlock {
	if (!urlString) {
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		__block NSMutableArray *assets = [NSMutableArray array];
		[self enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
			if (result) {
				if ([result.url.absoluteString isEqualToString:urlString]) {
					[assets addObject:result];
				}
			}
			else {
				if (completionBlock) {
					completionBlock(assets);
				}
			}
		}];
	});
}

@end

@implementation ALAsset (AssetsLibraryKit)

- (NSURL *)url {
	return [self valueForProperty:ALAssetPropertyAssetURL];
}

- (NSString *) assetType {
	return [self valueForProperty:ALAssetPropertyType];
}

- (NSString *) name {
	return self.defaultRepresentation.filename;
}

- (UIImage *) image {
	return [UIImage imageWithCGImage:self.fullSizeImage];
}

- (NSData *) imageData {
	return UIImageJPEGRepresentation(self.image, 0.8);
}

- (CGImageRef) fullSizeImage {
	return self.defaultRepresentation.fullScreenImage;
}

#pragma mark - Flurry Info
- (NSString *) shareInfoString {
	NSDictionary *IPTCDic = self.defaultRepresentation.metadata[(NSString *)kCGImagePropertyIPTCDictionary];
	return IPTCDic[(NSString *)kCGImagePropertyIPTCObjectName];
}

- (NSArray *) shareInfoArray {
	NSArray *arr = [self.shareInfoString componentsSeparatedByString:@"_"];
	return arr;
}

- (NSString *) effectTitle {
	return [self shareInfoArray][0];
}
- (NSString *) devicePosition {
	return [self shareInfoArray][1];
}
- (NSString *) flashMode {
	return [self shareInfoArray][2];
}
@end