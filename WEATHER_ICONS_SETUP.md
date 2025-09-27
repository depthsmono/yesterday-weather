# Weather Icons Font Setup Instructions

## Download Font Files

To complete the Weather Icons integration, download these font files from the Erik Flowers Weather Icons repository:

### Required Files:
1. **weathericons-regular-webfont.ttf**
   - URL: https://raw.githubusercontent.com/erikflowers/weather-icons/master/font/weathericons-regular-webfont.ttf
   - This is the main TTF font file for iOS

2. **Alternative Download Location:**
   - GitHub Release: https://github.com/erikflowers/weather-icons/releases
   - Download the latest release ZIP and extract the font files from the `/font/` directory

### iOS Integration Steps:

1. **Add Font to Project:**
   - Download `weathericons-regular-webfont.ttf`
   - Drag the TTF file into your Xcode project
   - Choose "Add to target" for your main app target
   - Make sure "Copy items if needed" is selected

2. **Update Info.plist:**
   Add the font to your app's Info.plist file:
   ```xml
   <key>UIAppFonts</key>
   <array>
       <string>weathericons-regular-webfont.ttf</string>
   </array>
   ```

3. **Font Registration:**
   The font should register as "Weather Icons" (as referenced in WeatherIconView.swift)

### Licensing:
- Font: SIL OFL 1.1 License (allows commercial use)
- Code: MIT License
- Documentation: CC BY 3.0

### Verification:
Once added, the WeatherIconView component will automatically use the Weather Icons font when available, falling back to SF Symbols for development.

### Current Status:
✅ WeatherIconView component created with Unicode mappings
✅ All existing weather icons updated to use WeatherIconView
✅ Enhanced admin panel with day/night icon variants
⏳ Font files need to be manually downloaded and added to project