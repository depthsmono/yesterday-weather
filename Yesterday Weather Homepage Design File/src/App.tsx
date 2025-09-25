import { HourlyForecast } from "./components/HourlyForecast";
import { WeatherComparison } from "./components/WeatherComparison";
import { TenDayForecast } from "./components/TenDayForecast";
import { WeatherQuote } from "./components/WeatherQuote";

// Mock data
const todayWeather = {
  temperature: 75,
  condition: "Partly Cloudy",
  humidity: 65,
  windSpeed: 8,
  precipitation: 20
};

const yesterdayWeather = {
  temperature: 72,
  condition: "Sunny",
  humidity: 58,
  windSpeed: 12,
  precipitation: 0
};

const hourlyData = [
  { time: "12PM", temperature: 75, condition: "Partly Cloudy", precipitation: 20 },
  { time: "1PM", temperature: 76, condition: "Cloudy", precipitation: 30 },
  { time: "2PM", temperature: 77, condition: "Cloudy", precipitation: 25 },
  { time: "3PM", temperature: 78, condition: "Partly Cloudy", precipitation: 15 },
  { time: "4PM", temperature: 77, condition: "Sunny", precipitation: 5 },
  { time: "5PM", temperature: 75, condition: "Sunny", precipitation: 0 },
  { time: "6PM", temperature: 73, condition: "Clear", precipitation: 0 }
];

const tenDayForecast = [
  { day: "Today", date: "24", condition: "Partly Cloudy", highTemp: 78, lowTemp: 68, precipitation: 20 },
  { day: "Fri", date: "25", condition: "Rainy", highTemp: 70, lowTemp: 62, precipitation: 80 },
  { day: "Sat", date: "26", condition: "Cloudy", highTemp: 72, lowTemp: 64, precipitation: 40 },
  { day: "Sun", date: "27", condition: "Sunny", highTemp: 76, lowTemp: 66, precipitation: 10 },
  { day: "Mon", date: "28", condition: "Sunny", highTemp: 79, lowTemp: 69, precipitation: 5 },
  { day: "Tue", date: "29", condition: "Partly Cloudy", highTemp: 77, lowTemp: 67, precipitation: 15 },
  { day: "Wed", date: "30", condition: "Cloudy", highTemp: 74, lowTemp: 65, precipitation: 30 },
  { day: "Thu", date: "1", condition: "Rainy", highTemp: 68, lowTemp: 60, precipitation: 70 },
  { day: "Fri", date: "2", condition: "Sunny", highTemp: 73, lowTemp: 63, precipitation: 0 },
  { day: "Sat", date: "3", condition: "Sunny", highTemp: 75, lowTemp: 65, precipitation: 5 }
];

const weatherQuote = {
  quote: "The gutters of the sky fill'd all with tears, The air doth drizzle dew with weeping showers...",
  author: "William Shakespeare",
  source: "Henry VI Part 2 (III.1)"
};

export default function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-100 via-orange-100 via-yellow-100 to-pink-100">
      {/* iPhone-style container */}
      <div className="max-w-sm mx-auto bg-gradient-to-b from-white/95 to-white/90 backdrop-blur-sm shadow-2xl rounded-[2.5rem] overflow-hidden min-h-screen">
        {/* Status bar simulation */}
        <div className="h-6 bg-black rounded-t-[2.5rem] flex items-center justify-center">
          <div className="w-16 h-1 bg-white rounded-full"></div>
        </div>
        
        {/* Main Content */}
        <div className="px-3 py-4 space-y-4">
          {/* 1. Location Header - Large H1 */}
          <div className="text-center">
            <h1 className="text-2xl font-light">San Francisco</h1>
          </div>
          
          {/* 2. Date and Day - H2 Subhead */}
          <div className="text-center">
            <h2 className="text-lg text-muted-foreground">Thursday, September 25</h2>
          </div>
          
          {/* 3. Today's Weather + Hourly Forecast */}
          <HourlyForecast 
            currentCondition={todayWeather.condition}
            currentTemp={todayWeather.temperature}
            hourlyData={hourlyData}
          />
          
          {/* 4. Yesterday vs Today Comparison */}
          <WeatherComparison 
            yesterday={yesterdayWeather}
            today={todayWeather}
          />
          
          {/* 5. 10-Day Forecast */}
          <TenDayForecast forecast={tenDayForecast} />
          
          {/* 6. Weather Quote */}
          <WeatherQuote 
            quote={weatherQuote.quote}
            author={weatherQuote.author}
            source={weatherQuote.source}
          />
        </div>

        {/* Bottom home indicator */}
        <div className="h-8 bg-white flex items-center justify-center">
          <div className="w-32 h-1 bg-gray-300 rounded-full"></div>
        </div>
      </div>
    </div>
  );
}