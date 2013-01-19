//
//  GBVImage.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "GBVImage.h"

@implementation GBVImage


@synthesize fullurl,sampleUrl,thumbUrl,tags,rating,cachedThumb,isMoreCell,parent,cachedSample,webUrl;
#pragma mark - Inits
- (GBVImage *)initAsMoreCell {
    [self init];
    self.isMoreCell = true;
    self.thumbUrl = [[NSBundle mainBundle]URLForResource:@"more" withExtension:@"png"];
    self.sampleUrl = self.thumbUrl;
    return self;
}

- (GBVImage *)initWithFull: (NSURL*)full sample:(NSURL*)sample thumb:(NSURL*)thumb  rating:(NSString*)ratng tags:(NSArray*)t idx:(NSInteger)ind webUrl:(NSString *)web {
    [self init];
    if (self) {
        self.fullurl = full;
        self.sampleUrl =sample;
        self.thumbUrl = thumb;
        self.idx = ind;
        self.webUrl = web;
        self.rating = ratng;
        self.tags = [[NSArray alloc]initWithArray:t];
    }
    return  self;
}
#pragma mark - Image stuff
- (void) _cacheThumb {
        cachedThumb = [[NSImage alloc]initWithContentsOfURL:self.thumbUrl];
    [cachedThumb retain];
        ver = ver + 1;
}
- (void) _cacheSample{
    cachedSample = [[NSImage alloc]initWithContentsOfURL:self.sampleUrl];
    [cachedSample retain];
    ver = ver + 1;
}

-(void)requestSampleImageIntoCache { [self performSelectorInBackground:@selector(_cacheSample) withObject:nil]; }
-(void)requestThumbImageIntoCache { [self performSelectorInBackground:@selector(_cacheThumb) withObject:nil]; }


- (void) copyToPasteBoard {
    NSPasteboard * board = [NSPasteboard generalPasteboard];
    [board clearContents];
    NSArray * itemsToCopy = [NSArray arrayWithObjects:[self getSampleImage], self.fullurl, nil];
    [board writeObjects:itemsToCopy];
}
- (NSImage *)getSampleImage {
    if (cachedSample == nil && !hasAlreadyReqSamp) {
       [self _cacheSample];
    }
    return cachedSample;
}

- (NSImage*)getBestAvailImage {
    if (cachedSample == nil && !hasAlreadyReqSamp) {
        [self requestSampleImageIntoCache];
        hasAlreadyReqSamp = true;
    } else if (cachedSample != nil) return cachedSample;
    
    if(cachedThumb== nil && !hasAlreadyReqThumb) {
        [self requestThumbImageIntoCache];
        hasAlreadyReqThumb = true;
    } else if (cachedThumb != nil) return cachedThumb;
    
    return nil;//[NSImage imageNamed:@"wait.png"];
    
}
#pragma mark - Item data source protocol

- (NSString *)imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
	return [self getBestAvailImage];
}

- (NSString *)imageUID
{
	return [NSString stringWithFormat:@"%p", self];
}

- (id)imageTitle
{
    if (self.isMoreCell) return @"Next page";
  //  return [NSString stringWithFormat:@"Rating: %@, filename: %@",self.rating,[self.fullurl lastPathComponent]];
	return @"";
}

-(id)imageSubtitle {
    if (self.isMoreCell) return @"Double click or press enter to load next 100 images";
    return @"";
}
-(int)imageVersion {
    return ver;
}

#pragma mark - Download

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *destinationFilename;
    NSString *homeDirectory = NSHomeDirectory();
    
    destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Downloads"]
                           stringByAppendingPathComponent:filename];
    [download setDestination:destinationFilename allowOverwrite:NO];
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    // Release the download.
    [download release];
    
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    // Release the download.
    [download release];
    
    // Do something with the data.
    NSLog(@"%@",@"downloadDidFinish");
}

-(void)performDownload{
    if(isMoreCell) return;
    // Create the request.
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.fullurl
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    // Create the download with the request and start loading the data.
    NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    if (!theDownload) {
        // Inform the user that the download failed.
    }
}

#pragma mark - Other methods
- (void)browse{
    if(isMoreCell) return;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.webUrl]];
}

@end

