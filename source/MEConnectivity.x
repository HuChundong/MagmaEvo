#import "MagmaEvo.h"

%hook CCUILabeledRoundButtonViewController
	-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {
		return %orig(arg1, [self evoGetToggleColor:arg2], arg3);
	}
	-(id)initWithGlyphPackageDescription:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {
		return %orig(arg1, [self evoGetToggleColor:arg2], arg3);
	}

	%new
	-(UIColor *)evoGetToggleColor:(UIColor *)color {
		if (![self isKindOfClass:%c(CCUIConnectivityButtonViewController)]) return color;

		if ([[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"]) {
			color = [UIColor clearColor];
		} else {
			NSString *prefKey = [NSString stringWithFormat:@"%@Enabled", NSStringFromClass([self class])];
			if ([settings valueForKey:prefKey]) color = [UIColor evoRGBAColorFromHexString:[settings valueForKey:prefKey]];
		}

		return color;
	}
%end

%hook CCUIRoundButton
	-(void)didMoveToWindow {
		%orig;

		if ([settings boolForKey:@"powerModuleHideBackground"] && ([self._viewControllerForAncestor isKindOfClass:%c(LockButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(PowerDownButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(RebootButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(RespringButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(SafemodeButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(UICacheButtonController)])) {
				self.normalStateBackgroundView.alpha = 0;
		}
	}

	-(void)_updateForStateChange {
		%orig;

		if ([settings boolForKey:@"powerModuleHideBackground"] && ([self._viewControllerForAncestor isKindOfClass:%c(LockButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(PowerDownButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(RebootButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(RespringButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(SafemodeButtonController)]
			|| [self._viewControllerForAncestor isKindOfClass:%c(UICacheButtonController)])) {
				self.normalStateBackgroundView.alpha = 0;
		}

		if (![self._viewControllerForAncestor isKindOfClass:%c(CCUIConnectivityButtonViewController)]) return;

		if ([[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"]) {
			self.normalStateBackgroundView.alpha = 0;
		}

		if (self.glyphPackageView == nil) {
			// Only need to update the selectedGlyphView because the regular one is already colored after a respring
			forceLayerUpdate(@[self.selectedGlyphView.layer]);
		} else {
			// WiFi & Bluetooth buttons
			forceLayerUpdate(self.glyphPackageView.layer.sublayers);
		}

	}

	-(BOOL)useAlternateBackground {
		if ([self._viewControllerForAncestor isKindOfClass:%c(CCUIConnectivityButtonViewController)]) return NO;
		return %orig;
	}
%end

%hook CCUIConnectivityModuleViewController
	-(void)_setupPortraitButtons {
		%orig;

		NSArray *newOrder = [self evoGetToggleOrder:self.portraitButtonViewControllers];
		if ([newOrder count] != 0) {
			[self setPortraitButtonViewControllers:newOrder];
		} else {
			// Write them to the preference file so we know which ones are available later
			NSString *path = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";
			NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];

			for (int i = 0; i < [self.portraitButtonViewControllers count]; i++) {
				[settings setObject:NSStringFromClass([self.portraitButtonViewControllers[i] class]) forKey:[NSString stringWithFormat:@"connectivityPosition%d", i]];
			}

			[settings writeToFile:path atomically:YES];
		}
	}

	-(void)_setupLandscapeButtons {
		%orig;

		NSArray *newOrder = [self evoGetToggleOrder:self.landscapeButtonViewControllers];
		if ([newOrder count] != 0) [self setLandscapeButtonViewControllers:newOrder];
	}

	%new
	-(NSArray*)evoGetToggleOrder:(NSArray *)originalOrder {

		NSMutableArray *newOrder = [NSMutableArray arrayWithCapacity: 6];
		for (int i = 0; i < 6; i++) {
    		[newOrder addObject:[NSNull null]];
		}

		for (id obj in originalOrder) {
			for (int i = 0; i < 6; i++) {
				NSString *val = [settings valueForKey:[NSString stringWithFormat:@"connectivityPosition%d", i]];
				if (val != nil && [val isEqual:NSStringFromClass([obj class])]) [newOrder replaceObjectAtIndex:i withObject:obj];
			}
		}

		[newOrder removeObjectIdenticalTo:[NSNull null]];

		return newOrder;
	}
%end

CGColorRef getConnectivityGlyphColor(CCUILabeledRoundButtonViewController *controller) {
	NSString *prefKey = [NSString stringWithFormat:@"%@%@", NSStringFromClass([controller class]), [controller isEnabled] ? @"Enabled" : @"Disabled"];
	UIColor *color = ([settings valueForKey:prefKey] != nil) ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:prefKey]] : nil;

	if ([[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] || ![controller isEnabled]) {
		if (color != nil) return [color CGColor];

		if ([prefKey isEqual:@"CCUIConnectivityAirDropViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#007AFF"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityAirplaneViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#FF9500"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityBluetoothViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#007AFF"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityCellularDataViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#4CD964"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityHotspotViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#4CD964"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityWifiViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#007AFF"] CGColor];
	}	else if([controller isEnabled]) {
		if (color != nil && [color evoIsBrightColor]) return [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] CGColor];
	}

	return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
}

CGColorRef getPowerModuleColor(CCUILabeledRoundButtonViewController *controller) {
	NSString *prefKey = NSStringFromClass([controller class]);
	UIColor *color = ([settings valueForKey:prefKey] != nil) ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:prefKey]] : nil;

	if (color != nil) return [color CGColor];

	return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
}

%ctor {
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		// Load WeatherVane or QuickCC if installed because they have to be injected BEFORE the Connectivity Module gets loaded
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/QuickCC.dylib"]) {
			dlopen("/Library/MobileSubstrate/DynamicLibraries/QuickCC.dylib", RTLD_LAZY);
		}

		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/WeatherVane.dylib"]) {
			dlopen("/Library/MobileSubstrate/DynamicLibraries/WeatherVane.dylib", RTLD_LAZY);
		}

		// Need to load the Connectivity Bundle here or our CCUIConnectivityModuleViewController will be injected too early
		[[NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/"] load];
		%init;
	}
}
