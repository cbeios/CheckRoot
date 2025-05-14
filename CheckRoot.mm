#include "CheckRoot.h"
#include <Foundation/Foundation.h>

std::string getJailbreakStatus() 
{
    // Check for non-jailbroken device first
    bool isJailbroken = false;
    // Common jailbreak files and directories
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
    // Rootless jailbreak specific paths
    const char* rootlessPaths[] = 
    {
        "/var/jb",
        "/var/jb/bin",
        "/var/jb/usr/lib",
        "/var/jb/Library/MobileSubstrate/DynamicLibraries"
    };
    // Roothide specific path
    const char* roothidePath = "/var/jb/.roothide";
    
    // Check for jailbreak files
    for (const char* path : jailbreakPaths) 
    {
        if (access(path, F_OK) == 0) 
        {
            isJailbroken = true;
            break;
        }
    }
    if (!isJailbroken) 
   	{
        // If no common jailbreak files are found, check for rootless jailbreak
        for (const char* path : rootlessPaths) 
        {
            if (access(path, F_OK) == 0) 
            {
                // Check for roothide specifically
                if (access(roothidePath, F_OK) == 0) 
                {
                    return "Roothide";
                }
                return "Rootless";
            }
        }
    } 
    else 
    {
        // If jailbreak files are found, check if it's roothide
        if (access(roothidePath, F_OK) == 0) 
        {
            return "Roothide";
        }
        return "Rootfull";
    }
    // Check if the app is running in a sandbox (non-jailbroken devices have strict sandbox)
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    if ([bundlePath containsString:@"/Applications/"] && !isJailbroken) 
    {
        return "Non Root";
    }
    // Additional check: try to write to a restricted directory
    NSString *testPath = @"/private/test_jb.txt";
    NSError *error = nil;
    [@"" writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) 
    {
        // If we can write to /private, it's jailbroken
        unlink([testPath UTF8String]); // Clean up
        return access(roothidePath, F_OK) == 0 ? "Roothide" : "Rootfull";
    }
    return "Non Root";
}



//================================================================================//

//Using text in menu
/*
std::string statusjb = getJailbreakStatus();
ImGui::Text("CheckRoot: %s"), statusjb.c_str());
*/

//================================================================================//
