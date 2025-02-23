#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>


// Оригинальные функции
static int (*orig_stat)(const char *, struct stat *);
static int (*orig_access)(const char *, int);
static int (*orig_sysctl)(int *, u_int, void *, size_t *, void *, size_t);

// Список файлов, которые нужно скрыть
const char *hiddenFiles[] = {
    // Системные джейлбрейк-файлы
    "/Applications/Cydia.app",
    "/Applications/Sileo.app",
    "/Applications/Zebra.app",
    "/Applications/Filza.app",
    "/Applications/NewTerm.app",
    "/bin/bash",
    "/usr/bin/ssh",
    "/usr/sbin/sshd",
    "/usr/libexec/ssh-keysign",
    "/etc/apt",
    "/var/lib/dpkg",
    "/var/cache/apt",
    "/var/log/syslog",
    "/var/tmp/cydia.log",
    "/private/var/lib/apt",
    "/private/var/lib/cydia",
    "/private/var/log/syslog",
    "/private/var/tmp/cydia.log",
    "/private/etc/apt",
    "/private/etc/ssh/sshd_config",
    "/private/etc/dpkg",
    // Rootless-джейлбрейк (Dopamine, RootHide)
    "/var/jb/Applications/Sileo.app",
    "/var/jb/Applications/Zebra.app",
    "/var/jb/Applications/Filza.app",
    "/var/jb/Applications/NewTerm.app",
    "/var/jb/bin/bash",
    "/var/jb/usr/bin/ssh",
    "/var/jb/usr/sbin/sshd",
    "/var/jb/usr/libexec/ssh-keysign",
    "/var/jb/etc/apt",
    "/var/jb/var/lib/dpkg",
    "/var/jb/var/cache/apt",
    "/var/jb/var/log/syslog",
    "/var/jb/var/tmp/cydia.log",
    // Твики
    "/Library/MobileSubstrate",
    "/Library/TweakInject",
    "/var/jb/Library/MobileSubstrate",
    "/var/jb/Library/TweakInject",
    // TrollStore
    "/Applications/TrollStore.app",
    "/var/containers/Bundle/Application/TrollStore",
    // Все приложения
    "/Applications",
    "/var/jb/Applications",
    NULL
};

// Список процессов, которые нужно скрыть
const char *hiddenProcesses[] = {
    "Cydia",
    "Sileo",
    "Zebra",
    "Filza",
    "NewTerm",
    "sshd",
    "dropbear",
    "bash",
    "apt",
    "dpkg",
    NULL
};

// Проверка, нужно ли скрыть файл
BOOL shouldHideFile(const char *path) {
    for (int i = 0; hiddenFiles[i] != NULL; i++) {
        if (strstr(path, hiddenFiles[i]) != NULL) {
            return YES;
        }
    }
    return NO;
}

// Проверка, нужно ли скрыть процесс
BOOL shouldHideProcess(const char *processName) {
    for (int i = 0; hiddenProcesses[i] != NULL; i++) {
        if (strcmp(processName, hiddenProcesses[i]) == 0) {
            return YES;
        }
    }
    return NO;
}

// Хук для stat
int hooked_stat(const char *path, struct stat *buf) {
    NSLog(@"hooked_stat called for path: %s", path);
    if (shouldHideFile(path)) {
        NSLog(@"Hiding file: %s", path);
        errno = ENOENT; // Файл не найден
        return -1;
    }
    return orig_stat(path, buf);
}

// Хук для access
int hooked_access(const char *path, int mode) {
    NSLog(@"hooked_access called for path: %s", path);
    if (shouldHideFile(path)) {
        NSLog(@"Hiding file: %s", path);
        errno = ENOENT; // Файл не найден
        return -1;
    }
    return orig_access(path, mode);
}

// Хук для sysctl
int hooked_sysctl(int *name, u_int namelen, void *info, size_t *infosize, void *newinfo, size_t newinfosize) {
    int result = orig_sysctl(name, namelen, info, infosize, newinfo, newinfosize);

    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_ALL) {
        // Фильтрация процессов
        struct kinfo_proc *proc = (struct kinfo_proc *)info;
        size_t count = *infosize / sizeof(struct kinfo_proc);

        for (size_t i = 0; i < count; i++) {
            NSLog(@"Checking process: %s", proc[i].kp_proc.p_comm);
            if (shouldHideProcess(proc[i].kp_proc.p_comm)) {
                NSLog(@"Hiding process: %s", proc[i].kp_proc.p_comm);
                // Скрытие процесса
                memmove(&proc[i], &proc[i + 1], (count - i - 1) * sizeof(struct kinfo_proc));
                count--;
                i--;
            }
        }
        *infosize = count * sizeof(struct kinfo_proc);
    }

    return result;
}

// Установка хуков
void installHooks() {
    void *libc = dlopen("/usr/lib/libc.dylib", RTLD_NOW);
    orig_stat = (int (*)(const char *, struct stat *))dlsym(libc, "stat");
    orig_access = (int (*)(const char *, int))dlsym(libc, "access");
    orig_sysctl = (int (*)(int *, u_int, void *, size_t *, void *, size_t))dlsym(libc, "sysctl");

    // Замена функций
    Method originalStatMethod = class_getClassMethod(objc_getClass("NSFileManager"), @selector(stat));
    method_setImplementation(originalStatMethod, (IMP)hooked_stat);

    Method originalAccessMethod = class_getClassMethod(objc_getClass("NSFileManager"), @selector(access));
    method_setImplementation(originalAccessMethod, (IMP)hooked_access);

    Method originalSysctlMethod = class_getClassMethod(objc_getClass("NSProcessInfo"), @selector(sysctl));
    method_setImplementation(originalSysctlMethod, (IMP)hooked_sysctl);

    // Логирование
    NSLog(@"🔒 Hooks installed! Jailbreak hidden.");
}

// Удаление хуков
void removeHooks() {
    void *libc = dlopen("/usr/lib/libc.dylib", RTLD_NOW);
    orig_stat = (int (*)(const char *, struct stat *))dlsym(libc, "stat");
    orig_access = (int (*)(const char *, int))dlsym(libc, "access");
    orig_sysctl = (int (*)(int *, u_int, void *, size_t *, void *, size_t))dlsym(libc, "sysctl");

    // Восстановление оригинальных функций
    Method originalStatMethod = class_getClassMethod(objc_getClass("NSFileManager"), @selector(stat));
    method_setImplementation(originalStatMethod, (IMP)orig_stat);

    Method originalAccessMethod = class_getClassMethod(objc_getClass("NSFileManager"), @selector(access));
    method_setImplementation(originalAccessMethod, (IMP)orig_access);

    Method originalSysctlMethod = class_getClassMethod(objc_getClass("NSProcessInfo"), @selector(sysctl));
    method_setImplementation(originalSysctlMethod, (IMP)orig_sysctl);

    // Логирование
    NSLog(@"🔓 Hooks removed! Jailbreak visible.");
}

// Основной ViewController
@interface ViewController : UIViewController
@property (nonatomic, strong) UIButton *runStopButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, assign) BOOL isJailbreakHidden;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Название приложения
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Jailbreak Hider Pro";
    self.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor blackColor];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 120);
    [self.view addSubview:self.titleLabel];

    // Кнопка Run/Stop
    self.runStopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.runStopButton setTitle:@"Run" forState:UIControlStateNormal];
    [self.runStopButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.runStopButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.runStopButton.frame = CGRectMake(0, 0, 100, 40);
    self.runStopButton.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    [self.runStopButton addTarget:self action:@selector(runStopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.runStopButton];

    // Логи с иконками
    self.logTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, self.view.center.y - 20, self.view.frame.size.width - 40, 100)];
    self.logTextView.editable = NO;
    self.logTextView.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.logTextView.textColor = [UIColor blackColor];
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.logTextView.layer.cornerRadius = 10;
    self.logTextView.layer.masksToBounds = YES;
    [self.view addSubview:self.logTextView];

    self.isJailbreakHidden = NO;
}

// Обработка нажатия кнопки
- (void)runStopButtonPressed {
    if (self.isJailbreakHidden) {
        removeHooks();
        [self.runStopButton setTitle:@"Run" forState:UIControlStateNormal];
        [self animateLog:@"🔓 Hooks removed! Jailbreak visible.\n"];
    } else {
        installHooks();
        [self.runStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self animateLog:@"🔒 Hooks installed! Jailbreak hidden.\n"];
    }
    self.isJailbreakHidden = !self.isJailbreakHidden;
}

// Анимация для логов
- (void)animateLog:(NSString *)logMessage {
    [UIView animateWithDuration:0.3 animations:^{
        self.logTextView.alpha = 0;
    } completion:^(BOOL finished) {
        self.logTextView.text = [self.logTextView.text stringByAppendingString:logMessage];
        [UIView animateWithDuration:0.3 animations:^{
            self.logTextView.alpha = 1;
        }];
    }];
}

@end

// AppDelegate
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];

    // Установка хуков при запуске приложения
    installHooks();
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Убедимся, что хуки остаются активными в фоновом режиме
    installHooks();
}

@end

// Основная функция
int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}