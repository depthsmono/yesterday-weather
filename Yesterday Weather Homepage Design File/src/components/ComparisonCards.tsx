import { Card } from "./ui/card";
import { 
  Sun, 
  Cloud, 
  CloudRain, 
  Snowflake,
  TrendingUp,
  TrendingDown,
  Minus,
  Droplets,
  Wind
} from "lucide-react";

interface WeatherData {
  temperature: number;
  condition: string;
  humidity: number;
  windSpeed: number;
  precipitation: number;
}

interface ComparisonCardsProps {
  yesterday: WeatherData;
  today: WeatherData;
}

const getWeatherIcon = (condition: string, size: string = "w-8 h-8") => {
  const iconProps = { className: size };
  
  switch (condition.toLowerCase()) {
    case 'sunny':
    case 'clear':
      return <Sun {...iconProps} className={`${size} text-yellow-500`} />;
    case 'cloudy':
    case 'partly cloudy':
      return <Cloud {...iconProps} className={`${size} text-gray-400`} />;
    case 'rainy':
    case 'light rain':
      return <CloudRain {...iconProps} className={`${size} text-blue-500`} />;
    case 'snowy':
      return <Snowflake {...iconProps} className={`${size} text-blue-200`} />;
    default:
      return <Sun {...iconProps} className={`${size} text-yellow-500`} />;
  }
};

const getTrendIcon = (difference: number) => {
  if (difference > 0) return <TrendingUp className="w-3 h-3 text-green-600" />;
  if (difference < 0) return <TrendingDown className="w-3 h-3 text-red-600" />;
  return <Minus className="w-3 h-3 text-gray-500" />;
};

const getTrendColor = (difference: number) => {
  if (difference > 0) return "text-green-600";
  if (difference < 0) return "text-red-600";
  return "text-gray-500";
};

export function ComparisonCards({ yesterday, today }: ComparisonCardsProps) {
  const tempDiff = today.temperature - yesterday.temperature;
  const humidityDiff = today.humidity - yesterday.humidity;
  const windDiff = today.windSpeed - yesterday.windSpeed;

  return (
    <div className="grid grid-cols-2 gap-4">
      {/* Yesterday Card - Muted */}
      <Card className="p-4 bg-gray-50 border border-gray-200">
        <div className="space-y-3">
          <div>
            <p className="text-xs text-gray-500 uppercase tracking-wide">Yesterday</p>
            <div className="flex items-center space-x-2 mt-2">
              {getWeatherIcon(yesterday.condition)}
              <span className="text-2xl font-light text-gray-700">{yesterday.temperature}°</span>
            </div>
            <p className="text-sm text-gray-600 mt-1">{yesterday.condition}</p>
          </div>
          
          <div className="space-y-2 pt-3 border-t border-gray-200">
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center space-x-1">
                <Droplets className="w-4 h-4 text-gray-500" />
                <span className="text-gray-600">Humidity</span>
              </div>
              <span className="text-gray-700">{yesterday.humidity}%</span>
            </div>
            
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center space-x-1">
                <Wind className="w-4 h-4 text-gray-500" />
                <span className="text-gray-600">Wind</span>
              </div>
              <span className="text-gray-700">{yesterday.windSpeed} mph</span>
            </div>
          </div>
        </div>
      </Card>

      {/* Today Card - Highlighted */}
      <Card className="p-4 bg-gradient-to-br from-blue-50 to-indigo-100 border-0 shadow-sm">
        <div className="space-y-3">
          <div>
            <p className="text-xs text-blue-600 uppercase tracking-wide font-medium">Today</p>
            <div className="flex items-center space-x-2 mt-2">
              {getWeatherIcon(today.condition)}
              <span className="text-2xl font-light text-blue-900">{today.temperature}°</span>
            </div>
            <p className="text-sm text-blue-700 mt-1">{today.condition}</p>
          </div>
          
          <div className="space-y-2 pt-3 border-t border-blue-200">
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center space-x-1">
                <Droplets className="w-4 h-4 text-blue-600" />
                <span className="text-blue-700">Humidity</span>
              </div>
              <div className="flex items-center space-x-1">
                <span className="text-blue-900">{today.humidity}%</span>
                {getTrendIcon(humidityDiff)}
                <span className={`text-xs ${getTrendColor(humidityDiff)}`}>
                  {humidityDiff > 0 ? '+' : ''}{humidityDiff}
                </span>
              </div>
            </div>
            
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center space-x-1">
                <Wind className="w-4 h-4 text-blue-600" />
                <span className="text-blue-700">Wind</span>
              </div>
              <div className="flex items-center space-x-1">
                <span className="text-blue-900">{today.windSpeed} mph</span>
                {getTrendIcon(windDiff)}
                <span className={`text-xs ${getTrendColor(windDiff)}`}>
                  {windDiff > 0 ? '+' : ''}{windDiff}
                </span>
              </div>
            </div>
          </div>
        </div>
        
        {/* Temperature comparison at bottom */}
        <div className="mt-3 pt-3 border-t border-blue-200">
          <div className="flex items-center justify-center space-x-2 text-sm">
            {getTrendIcon(tempDiff)}
            <span className={`font-medium ${getTrendColor(tempDiff)}`}>
              {tempDiff > 0 ? '+' : ''}{tempDiff}° from yesterday
            </span>
          </div>
        </div>
      </Card>
    </div>
  );
}