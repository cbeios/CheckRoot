#include "CheckRoot.h"
#include <Foundation/Foundation.h>

std::string getJailbreakStatus() 
{
    //use static variable to cache the result
    static std::string cachedStatus;
    static bool isChecked = false;

    //return cached result if already checked
    if (isChecked) {
        return cachedStatus;
    }

    //mark as checked to prevent re-running
    isChecked = true;

    //common jailbreak files and directories
    const char* jailbreakPaths[] = 
    {
        "/Applications/Cydia.app",
        "/usr/bin/ssh",
        "/usr/sbin/sshd",
        "/bin/bash",
        "/etc/apt",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/private/var/stash",
        "/private/var/lib/apt"
    };

    //rootless jailbreak specific paths
    const char* rootlessPaths[] = 
    {
        "/var/jb",
        "/var/jb/bin",
        "/var/jb/usr/lib",
        "/var/jb/Library/MobileSubstrate/DynamicLibraries"
    };

    //roothide specific path
    const char* roothidePath = "/var/jb/.roothide";

    // Check for common jailbreak files
    for (const char* path : jailbreakPaths) 
    {
        if (access(path, F_OK) == 0) 
        {
            // Check if it's roothide
            if (access(roothidePath, F_OK) == 0) 
            {
                cachedStatus = "Roothide";
            } else {
                cachedStatus = "Rootfull";
            }
            return cachedStatus;
        }
    }

    //check for rootless jailbreak
    for (const char* path : rootlessPaths) 
    {
        if (access(path, F_OK) == 0) 
        {
            // Check for roothide specifically
            if (access(roothidePath, F_OK) == 0) 
            {
                cachedStatus = "Roothide";
            } else {
                cachedStatus = "Rootless";
            }
            return cachedStatus;
        }
    }

    //check if the app is running in a sandbox (non-jailbroken devices have strict sandbox)
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    if ([bundlePath containsString:@"/Applications/"]) 
    {
        cachedStatus = "Non Root";
        return cachedStatus;
    }

    //additional check: try to write to a restricted directory
    NSString *testPath = @"/private/test_jb.txt";
    NSError *error = nil;
    [@"" writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) 
    {
        //if we can write to /private, it's jailbroken
        unlink([testPath UTF8String]); // Clean up
        cachedStatus = (access(roothidePath, F_OK) == 0) ? "Roothide" : "Rootfull";
    } else {
        cachedStatus = "Non Root";
    }

    return cachedStatus;
}
