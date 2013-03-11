#include "path.h"
#import "PointCloud.h"

void dumpPath(){
    NSArray  *documentDirList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir  = [documentDirList objectAtIndex:0];
    NSString *documentPath = [documentDir stringByAppendingPathComponent:@"fileName"];
    const char *path = [documentPath cStringUsingEncoding:NSUTF8StringEncoding];
    printf("%s", path);

}


char* getDocumentPath(){
    NSArray  *documentDirList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir  = [documentDirList objectAtIndex:0];
    NSString *documentPath = [documentDir stringByAppendingPathComponent:@"fileName"];
    const char *path = [documentPath cStringUsingEncoding:NSUTF8StringEncoding];
    
    int c = 0;
    while (path[c] != '\0') {
        c++;
        
    }
    char *str = (char *)malloc((c+1)*sizeof(char));
    memcpy(str, path, (c+1)*sizeof(char));

    return str;
}

char* createFileName(const char * name){
    NSArray  *documentDirList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir  = [documentDirList objectAtIndex:0];
    NSString *documentPath = [documentDir stringByAppendingPathComponent:@"name"];
    const char *path = [documentPath cStringUsingEncoding:NSUTF8StringEncoding];
    
    int c = 0;
    while (path[c] != '\0') {
        c++;
        
    }
    
    int c2 = 0;
    
    while (name[c2] != '\0') {
        c2++;
    }
    
    char *str = (char *)malloc((c+c2+1)*sizeof(char));
    memset(str, '\0', sizeof((c+c2+1)*sizeof(char)));
    memcpy(str, path, (c)*sizeof(char));
    memcpy(str+c, name, (c2+1)*sizeof(char));
    
    return str;
}
