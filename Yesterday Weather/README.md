# Yesterday Weather

An elegant iOS weather app that compares today's weather with yesterday's conditions, featuring beautiful literary quotes and sophisticated performance optimizations.

## ✨ Features

### Core Functionality
- **Weather Comparison**: Side-by-side comparison of today vs yesterday's weather
- **10-Day Forecast**: Extended weather outlook with detailed daily predictions
- **Hourly Forecast**: Detailed hourly weather data for precise planning
- **Multiple Locations**: Save and switch between favorite locations
- **Literary Quotes**: Curated collection of weather-themed poetry from Shakespeare and Wordsworth

### Visual Design
- **Marble Background**: Elegant rose gold marble texture on loading screen
- **Typography**: Carefully crafted text scaling that preserves poetry line breaks
- **Warm Color Palette**: Sophisticated color scheme with warm accents
- **Progressive Loading**: Phased data loading for optimal user experience

## 🚀 Performance Optimizations

This app has been extensively optimized for speed and responsiveness:

### **Caching System**
- **15-minute intelligent caching** - Instant loading for recently viewed locations
- **NSCache-based storage** - Memory-efficient with automatic cleanup
- **Location-based cache keys** - Efficient data retrieval

### **API Optimization**
- **Reduced from 4 to 2 API calls** - 50% fewer network requests
- **Combined endpoints** - Single call fetches current + forecast + hourly data
- **10-second timeouts** - Faster failure handling vs 60s defaults

### **Progressive Loading**
- **Phase 1**: Weather comparison (most critical data shown first)
- **Phase 2**: 10-day forecast (secondary priority)
- **Phase 3**: Hourly data (background loading)

### **Performance Metrics**
- **Before**: 7+ second minimum loading time
- **After**: Instant cached responses, <2s fresh data
- **Memory**: Efficient NSCache with 50MB limit, 10 location maximum

## 📱 Technical Details

### Architecture
- **SwiftUI** - Modern declarative UI framework
- **Async/await** - Concurrent API calls and data processing
- **MVVM Pattern** - Clean separation of concerns
- **Observation Framework** - Reactive UI updates

### APIs Used
- **Open-Meteo API** - Weather data (free, no API key required)
- **OpenStreetMap Nominatim** - Location search functionality

### Data Flow
```
User Opens App → Check Cache → Display Cached Data (instant)
                            ↓
                    Background: Fetch Fresh Data → Update UI → Cache Results
```

## 🎨 Design Philosophy

### Typography
- **Poetry Preservation**: Literary quotes maintain original line breaks
- **Dynamic Scaling**: Text automatically adjusts based on content length
- **Left-aligned Poetry**: Natural reading flow for verse
- **Smart Word Wrapping**: Prevents mid-line breaks in poetry

### Visual Hierarchy
- **Weather Comparison**: Primary focus on today vs yesterday
- **Progressive Disclosure**: Additional data revealed as it loads
- **Contextual Information**: Relevant details shown when needed

## 🛠 Development Highlights

### Code Quality
- **Performance-first**: Every feature optimized for speed
- **User Experience**: Smooth interactions and instant feedback
- **Error Handling**: Graceful degradation and retry logic
- **Memory Management**: Efficient caching and cleanup

### Recent Improvements
1. **Eliminated artificial delays** - Removed 7-second minimum loading
2. **Implemented intelligent caching** - 15-minute expiration strategy
3. **Added progressive loading** - Critical data shown immediately
4. **Enhanced quote display** - Preserved poetry formatting
5. **Optimized networking** - Reduced API calls and improved timeouts

## 📚 Literary Content

### Quote Collection
- **Shakespeare**: 15 weather-themed quotes from plays and sonnets
- **Wordsworth**: 20 nature and weather excerpts from major poems
- **Dynamic Selection**: Random quote on each app launch
- **Preserved Formatting**: Original line breaks and poetry structure maintained

### Featured Works
- *King Lear*, *The Tempest*, *Macbeth* (Shakespeare)
- *I Wandered Lonely as a Cloud*, *Ode: Intimations of Immortality*, *The Prelude* (Wordsworth)

## 🚧 Future Enhancements

### Performance
- [ ] Background prefetching for frequently accessed locations
- [ ] Offline mode with extended cache for poor connectivity
- [ ] Database persistence for long-term cache storage

### Features
- [ ] Weather alerts and notifications
- [ ] Historical weather trends
- [ ] Seasonal poetry collections
- [ ] Custom location nicknames

## 💡 Architecture Decisions

### Why Open-Meteo API?
- **Free**: No API key required, unlimited usage
- **Comprehensive**: Current, forecast, and historical data
- **Reliable**: High uptime and fast response times
- **Global**: Worldwide coverage with consistent data format

### Why NSCache for Caching?
- **Automatic Memory Management**: iOS handles cleanup during memory pressure
- **Thread Safe**: Built-in concurrent access protection
- **Size Limits**: Configurable memory and item count limits
- **Eviction Policy**: LRU (Least Recently Used) automatic cleanup

### Why Progressive Loading?
- **Perceived Performance**: Users see data immediately
- **Network Efficiency**: Non-blocking concurrent requests
- **User Control**: Can interact with partial data while loading continues

## 📦 Installation

1. Clone the repository
2. Open `Yesterday Weather.xcodeproj` in Xcode
3. Build and run on iOS 16.0+ simulator or device
4. No API keys or additional setup required

## 🤝 Contributing

This project welcomes contributions! Areas of interest:
- Performance optimizations
- UI/UX improvements
- Additional literary content
- Accessibility enhancements
- Test coverage

---

*"The sunshine is a glorious birth; But yet I know, where'er I go, That there hath passed away a glory from the earth."* - William Wordsworth