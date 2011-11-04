#import <Foundation/Foundation.h>

__attribute__((visibility("hidden")))
@interface URLConnectionLogDelegate : NSObject {
@private
	id realDelegate;
}
@end

@implementation URLConnectionLogDelegate

- (id)initWithRealDelegate:(id)_realDelegate
{
	if ((self = [super init])) {
		realDelegate = [_realDelegate retain];
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"-[NSURLConnectionDelegate dealloc]");
	[realDelegate release];
	[super dealloc];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	if ([realDelegate respondsToSelector:_cmd])
		return [realDelegate connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
	return NO;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connection:connection didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connection:connection didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connection:connection willSendRequestForAuthenticationChallenge:challenge];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
	if ([realDelegate respondsToSelector:_cmd])
		return [realDelegate connectionShouldUseCredentialStorage:connection];
	return YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connection:connection didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connectionDidFinishLoading:connection];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connection:connection didReceiveData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"-[NSURLConnectionDelegate didReceiveResponse:%@] %@", [response URL], [response respondsToSelector:@selector(allHeaderFields)] ? (id)[(NSHTTPURLResponse *)response allHeaderFields] : @"");
	if ([realDelegate respondsToSelector:_cmd])
		[realDelegate connection:connection didReceiveResponse:response];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	if ([realDelegate respondsToSelector:_cmd])
		return [realDelegate connection:connection willCacheResponse:cachedResponse];
	return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if ([realDelegate respondsToSelector:_cmd])
		return [realDelegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
	return request;
}

@end

%hook NSURLConnection

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
	NSLog(@"+[NSURLConnection sendSynchronousRequest:%@ returningResponse:%p error:%p] %@ %@", [request URL], response, error, [request allHTTPHeaderFields], [request HTTPBody]);
	return %orig;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
	NSLog(@"-[NSURLConnection initWithRequest:%@ delegate:%@ startImmediately:%d] %@ %@", [request URL], delegate, startImmediately, [request allHTTPHeaderFields], [request HTTPBody]);
	id newDelegate = [[[URLConnectionLogDelegate alloc] initWithRealDelegate:delegate] autorelease];
	return %orig(request, newDelegate, startImmediately);
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
	NSLog(@"-[NSURLConnection initWithRequest:%@ delegate:%@] %@ %@", [request URL], delegate, [request allHTTPHeaderFields], [request HTTPBody]);
	id newDelegate = [[[URLConnectionLogDelegate alloc] initWithRealDelegate:delegate] autorelease];
	return %orig(request, newDelegate);
}

%end
