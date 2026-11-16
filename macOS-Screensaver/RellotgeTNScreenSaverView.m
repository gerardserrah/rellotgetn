#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

static NSString * const kModuleIdentifier = @"cat.tv3.rellotgetn.saver";
static NSString * const kPrefKeySelectedYear = @"SelectedYear";

@interface RellotgeTNScreenSaverView : ScreenSaverView <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSWindow *sheet;
@property (nonatomic, strong) NSPopUpButton *yearPopUp;
@end

@implementation RellotgeTNScreenSaverView

+ (BOOL)hasConfigureSheet {
    return YES;
}

- (BOOL)hasConfigureSheet {
    return YES;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1.0 / 30.0];
        [self setupWebView];
    }
    return self;
}

- (NSString *)currentSelectedYear {
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleIdentifier];
    [defaults registerDefaults:@{kPrefKeySelectedYear: @"2014"}];
    NSString *year = [defaults stringForKey:kPrefKeySelectedYear];
    if (!year || year.length == 0) {
        CFPropertyListRef val = CFPreferencesCopyAppValue((__bridge CFStringRef)kPrefKeySelectedYear, (__bridge CFStringRef)kModuleIdentifier);
        if (val) {
            year = (__bridge_transfer NSString *)val;
        }
    }
    if (!year || year.length == 0) {
        // Fallback: fitxer de suport
        NSString *supportPath = [@"~/Library/Application Support/RellotgeTN/year.txt" stringByExpandingTildeInPath];
        year = [NSString stringWithContentsOfFile:supportPath encoding:NSUTF8StringEncoding error:nil];
    }
    return (year && year.length > 0) ? [year stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : @"2014";
}

- (void)setupWebView {
    if (_webView) {
        [_webView removeFromSuperview];
        _webView = nil;
    }
    
    NSString *year = [self currentSelectedYear];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    
    WKPreferences *prefs = [[WKPreferences alloc] init];
    prefs.javaScriptEnabled = YES;
    @try {
        [prefs setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    } @catch (NSException *e) {}
    config.preferences = prefs;
    
    @try {
        [config setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    } @catch (NSException *e) {}
    
    // Injecció de script al documentStart per configurar mode salvapantalles i any escollit
    NSString *injection = [NSString stringWithFormat:
        @"window.__SCREENSAVER_MODE__ = true;\n"
        @"window.__SCREENSAVER_YEAR__ = '%@';\n"
        @"if (document.documentElement) document.documentElement.classList.add('screensaver-mode');\n", year];
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:injection
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                   forMainFrameOnly:YES];
    [config.userContentController addUserScript:userScript];
    
    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    _webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _webView.navigationDelegate = self;
    
    // Assegurem fons fosc mentre carrega
    _webView.wantsLayer = YES;
    if (_webView.layer) {
        _webView.layer.backgroundColor = [[NSColor blackColor] CGColor];
    }
    
    [self addSubview:_webView];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *webDir = [bundle.resourceURL URLByAppendingPathComponent:@"web"];
    NSURL *indexURL = [webDir URLByAppendingPathComponent:@"index.html"];
    
    if (indexURL) {
        // Importantíssim: URL neta sense query parameters per evitar error de fitxer no trobat a WebKit
        [_webView loadFileURL:indexURL allowingReadAccessToURL:webDir];
    }
}

- (void)loadCurrentMode {
    [self setupWebView];
}

- (void)animateOneFrame {
    // WebKit s'encarrega del seu propi renderitzat a 60 fps
}

- (NSWindow *)configureSheet {
    if (!_sheet) {
        NSRect frame = NSMakeRect(0, 0, 420, 210);
        _sheet = [[NSWindow alloc] initWithContentRect:frame
                                             styleMask:NSWindowStyleMaskTitled
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
        _sheet.title = @"Opcions del Salvapantalles Rellotge TN";
        
        NSView *content = [[NSView alloc] initWithFrame:frame];
        
        NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 155, 370, 26)];
        titleLabel.stringValue = @"Salvapantalles Rellotge TN (TV3)";
        titleLabel.editable = NO;
        titleLabel.bezeled = NO;
        titleLabel.drawsBackground = NO;
        titleLabel.font = [NSFont boldSystemFontOfSize:14];
        [content addSubview:titleLabel];
        
        NSTextField *subLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 128, 370, 20)];
        subLabel.stringValue = @"Tria quina edició del TN vols mostrar en pantalla:";
        subLabel.editable = NO;
        subLabel.bezeled = NO;
        subLabel.drawsBackground = NO;
        subLabel.font = [NSFont systemFontOfSize:12];
        [content addSubview:subLabel];
        
        _yearPopUp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(25, 85, 370, 26) pullsDown:NO];
        [_yearPopUp addItemsWithTitles:@[
            @"2014 (3D Plató TV3)",
            @"2005 (TN Comarques)",
            @"2025 (2D Actual)",
            @"Auto (Canvia segons el dia de la setmana)"
        ]];
        
        NSString *saved = [self currentSelectedYear];
        if ([saved isEqualToString:@"2005"]) [_yearPopUp selectItemAtIndex:1];
        else if ([saved isEqualToString:@"2025"]) [_yearPopUp selectItemAtIndex:2];
        else if ([saved isEqualToString:@"auto"]) [_yearPopUp selectItemAtIndex:3];
        else [_yearPopUp selectItemAtIndex:0];
        
        [content addSubview:_yearPopUp];
        
        NSButton *okBtn = [[NSButton alloc] initWithFrame:NSMakeRect(295, 20, 100, 32)];
        okBtn.title = @"D'acord";
        okBtn.bezelStyle = NSBezelStyleRounded;
        okBtn.target = self;
        okBtn.action = @selector(saveSheet:);
        okBtn.keyEquivalent = @"\r";
        [content addSubview:okBtn];
        
        NSButton *cancelBtn = [[NSButton alloc] initWithFrame:NSMakeRect(190, 20, 100, 32)];
        cancelBtn.title = @"Cancel·la";
        cancelBtn.bezelStyle = NSBezelStyleRounded;
        cancelBtn.target = self;
        cancelBtn.action = @selector(cancelSheet:);
        [content addSubview:cancelBtn];
        
        _sheet.contentView = content;
    } else {
        NSString *saved = [self currentSelectedYear];
        if ([saved isEqualToString:@"2005"]) [_yearPopUp selectItemAtIndex:1];
        else if ([saved isEqualToString:@"2025"]) [_yearPopUp selectItemAtIndex:2];
        else if ([saved isEqualToString:@"auto"]) [_yearPopUp selectItemAtIndex:3];
        else [_yearPopUp selectItemAtIndex:0];
    }
    return _sheet;
}

- (void)saveSheet:(id)sender {
    NSInteger idx = [_yearPopUp indexOfSelectedItem];
    NSString *val = @"2014";
    if (idx == 1) val = @"2005";
    else if (idx == 2) val = @"2025";
    else if (idx == 3) val = @"auto";
    
    // 1. ScreenSaverDefaults
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleIdentifier];
    [defaults setObject:val forKey:kPrefKeySelectedYear];
    [defaults synchronize];
    
    // 2. CFPreferences
    CFPreferencesSetAppValue((__bridge CFStringRef)kPrefKeySelectedYear, (__bridge CFPropertyListRef)val, (__bridge CFStringRef)kModuleIdentifier);
    CFPreferencesAppSynchronize((__bridge CFStringRef)kModuleIdentifier);
    
    // 3. Application Support fallback
    NSString *dir = [@"~/Library/Application Support/RellotgeTN" stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    [val writeToFile:[dir stringByAppendingPathComponent:@"year.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self loadCurrentMode];
    
    if (_sheet.sheetParent) {
        [_sheet.sheetParent endSheet:_sheet];
    } else {
        [[NSApplication sharedApplication] endSheet:_sheet];
        [_sheet orderOut:nil];
    }
}

- (void)cancelSheet:(id)sender {
    if (_sheet.sheetParent) {
        [_sheet.sheetParent endSheet:_sheet];
    } else {
        [[NSApplication sharedApplication] endSheet:_sheet];
        [_sheet orderOut:nil];
    }
}

@end
