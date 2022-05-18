//
//  AppDelegate.m
//  libjpegturbo
//
//  Created by blackox626 on 2022/5/18.
//

#import "AppDelegate.h"
#import "jpeglib.h"

int decode_JPEG_file(char *inJpegName, char *outRgbName) {
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;

    FILE * infile;
    FILE * outfile;

    if ((infile = fopen(inJpegName, "rb")) == NULL) {
        fprintf(stderr, "can't open %s\n", inJpegName);
        return -1;
    }
    if ((outfile = fopen(outRgbName, "wb")) == NULL) {
        fprintf(stderr, "can't open %s\n", outRgbName);
        return -1;
    }

    cinfo.err = jpeg_std_error(&jerr);

    jpeg_create_decompress(&cinfo);

    jpeg_stdio_src(&cinfo, infile);

    jpeg_read_header(&cinfo, TRUE);

    printf("image_width = %d\n", cinfo.image_width);
    printf("image_height = %d\n", cinfo.image_height);
    printf("num_components = %d\n", cinfo.num_components);
    printf("enter scale M/N:\n");

    jpeg_start_decompress(&cinfo);

    //输出的图象的信息
    printf("output_width = %d\n", cinfo.output_width);
    printf("output_height = %d\n", cinfo.output_height);
    printf("output_components = %d\n", cinfo.output_components);

    int row_stride = cinfo.output_width * cinfo.output_components;
    /* Make a one-row-high sample array that will go away when done with image */
    JSAMPARRAY buffer = (JSAMPARRAY)malloc(sizeof(JSAMPROW));
    buffer[0] = (JSAMPROW)malloc(sizeof(JSAMPLE) * row_stride);

    unsigned char *pixels = malloc(row_stride*cinfo.image_height);
    
    
    long counter = 0;

    while (cinfo.output_scanline < cinfo.output_height) {
        jpeg_read_scanlines(&cinfo, buffer, 1);
        memcpy(pixels + counter, buffer[0], row_stride);
        counter += row_stride;
    }

    printf("total size: %ld\n", counter);
    fwrite(pixels,  counter, 1, outfile);


    jpeg_finish_decompress(&cinfo);

    jpeg_destroy_decompress(&cinfo);

    fclose(infile);
    fclose(outfile);
    free(pixels);

    return 0;
}

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpeg"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString *rgbpath = [docDir stringByAppendingPathComponent:@"test.rgb24"];
    
    
    decode_JPEG_file([path UTF8String], [rgbpath UTF8String]);
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
