#import <cstddef>
#import <cstring>
#import <cstdlib>
#import <dlfcn.h>
#import <spawn.h>
#import <unistd.h>
#import <sys/sysctl.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>


#pragma mark -

typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct __IOHIDNotification *IOHIDNotificationRef;
typedef struct __IOHIDService *IOHIDServiceRef;
typedef struct __GSEvent *GSEventRef;

#if __cplusplus
extern "C" {
#endif
void *BKSHIDEventRegisterEventCallback(void (*)(void *, void *, IOHIDServiceRef, IOHIDEventRef));
void UIApplicationInstantiateSingleton(id aclass);
void UIApplicationInitialize();
void BKSDisplayServicesStart();
void GSInitialize();
void GSEventInitialize(Boolean registerPurple);
void GSEventPopRunLoopMode(CFStringRef mode);
void GSEventPushRunLoopMode(CFStringRef mode);
void GSEventRegisterEventCallBack(void (*)(GSEventRef));
#if __cplusplus
}
#endif


#pragma mark -

@interface UIApplication (Private)
- (id)_systemAnimationFenceExemptQueue;
- (void)_accessibilityInit;
- (void)_enqueueHIDEvent:(IOHIDEventRef)event;
- (void)__completeAndRunAsPlugin;
- (void)_run;
@end




