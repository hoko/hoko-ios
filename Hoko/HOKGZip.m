//
//  HOKGZip.m
//  Hoko
//
//  Created by Hoko, S.A. on 01/12/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKGZip.h"
#import <zlib.h>

@implementation HOKGZip

static const NSUInteger ChunkSize = 16384;

+ (NSData *)gzipData:(NSData *)data compressionLevel:(float)level {
  if ([data length]) {
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)[data length];
    stream.next_in = (Bytef *)[data bytes];
    stream.total_out = 0;
    stream.avail_out = 0;
    
    int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
      NSMutableData *data = [NSMutableData dataWithLength:ChunkSize];
      
      while (stream.avail_out == 0) {
        if (stream.total_out >= [data length]) {
          data.length += ChunkSize;
        }
        
        stream.next_out = (uint8_t *)[data mutableBytes] + stream.total_out;
        stream.avail_out = (uInt)([data length] - stream.total_out);
        deflate(&stream, Z_FINISH);
      }
      
      deflateEnd(&stream);
      data.length = stream.total_out;
      return data;
    }
  }
  
  return nil;
}

+ (NSData *)gzippedData:(NSData *)data {
  return [self gzipData:data compressionLevel:-1.0];
}

+ (NSData *)gunzippedData:(NSData *)data {
  if ([data length]) {
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.avail_in = (uint)[data length];
    stream.next_in = (Bytef *)[data bytes];
    stream.total_out = 0;
    stream.avail_out = 0;
    
    NSMutableData *mutableData = [NSMutableData dataWithLength:(NSUInteger)([data length] * 1.5)];
    if (inflateInit2(&stream, 47) == Z_OK) {
      int status = Z_OK;
      while (status == Z_OK) {
        if (stream.total_out >= [mutableData length]) {
          mutableData.length += [data length] / 2;
        }
        
        stream.next_out = (uint8_t *)[mutableData mutableBytes] + stream.total_out;
        stream.avail_out = (uInt)([mutableData length] - stream.total_out);
        status = inflate (&stream, Z_SYNC_FLUSH);
      }
      
      if (inflateEnd(&stream) == Z_OK) {
        if (status == Z_STREAM_END) {
          mutableData.length = stream.total_out;
          return mutableData;
        }
      }
    }
  }
  
  return data;
}

@end
