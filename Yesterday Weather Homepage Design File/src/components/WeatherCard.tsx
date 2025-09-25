import { Card } from "./ui/card";
import { Badge } from "./ui/badge";
import { 
  Sun, 
  Cloud, 
  CloudRain, 
  Snowflake, 
  Zap, 
  Wind, 
  Droplets, 
  Eye, 
  Thermometer,
  ArrowUp,
  ArrowDown
} from "lucide-react";

interface WeatherData {
  date: string;
  dayName: string;
  temperature: number;
  condition: string;
  humidity: number;
  windSpeed: number;
  visibility: number;
  highTemp: number;
  lowTemp: number;
  feelsLike: number;
}

interface WeatherCardProps {
  weather: WeatherData;
  isToday?: boolean;
}

const getWeatherIcon = (condition: string) => {
  const iconProps = { className: "w-12 h-12" };
  
  switch (condition.toLowerCase()) {
    case 'sunny':
    case 'clear':
      return <Sun {...iconProps} className="w-12 h-12 text-yellow-500" />;
    case 'cloudy':
    case 'partly cloudy':
      return <Cloud {...iconProps} className="w-12 h-12 text-gray-400" />;
    case 'rainy':
    case 'light rain':
      return <CloudRain {...iconProps} className="w-12 h-12 text-blue-500" />;
    case 'snowy':
      return <Snowflake {...iconProps} className="w-12 h-12 text-blue-200" />;
    case 'stormy':
      return <Zap {...iconProps} className="w-12 h-12 text-purple-500" />;
    default:
      return <Sun {...iconProps} className="w-12 h-12 text-yellow-500" />;
  }
};

export function WeatherCard({ weather, isToday = false }: WeatherCardProps) {
  return (
    <Card className="p-6 bg-gradient-to-br from-blue-50 to-indigo-100 border-0 shadow-lg">
      <div className="flex flex-col space-y-4">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold">{weather.dayName}</h3>
            <p className="text-sm text-muted-foreground">{weather.date}</p>
          </div>
          {isToday && (
            <Badge variant="default" className="bg-blue-600 hover:bg-blue-700">
              Today
            </Badge>
          )}
        </div>

        {/* Main Temperature and Icon */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            {getWeatherIcon(weather.condition)}
            <div>
              <div className="text-4xl font-light">{weather.temperature}°</div>
              <p className="text-sm text-muted-foreground">{weather.condition}</p>
            </div>
          </div>
        </div>

        {/* High/Low and Feels Like */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-1">
              <ArrowUp className="w-4 h-4 text-red-500" />
              <span className="text-sm">{weather.highTemp}°</span>
            </div>
            <div className="flex items-center space-x-1">
              <ArrowDown className="w-4 h-4 text-blue-500" />
              <span className="text-sm">{weather.lowTemp}°</span>
            </div>
          </div>
          <div className="flex items-center space-x-1 text-sm text-muted-foreground">
            <Thermometer className="w-4 h-4" />
            <span>Feels {weather.feelsLike}°</span>
          </div>
        </div>

        {/* Weather Details */}
        <div className="grid grid-cols-3 gap-4 pt-4 border-t border-gray-200">
          <div className="flex flex-col items-center space-y-1">
            <Droplets className="w-5 h-5 text-blue-500" />
            <span className="text-xs text-muted-foreground">Humidity</span>
            <span className="text-sm font-medium">{weather.humidity}%</span>
          </div>
          <div className="flex flex-col items-center space-y-1">
            <Wind className="w-5 h-5 text-gray-500" />
            <span className="text-xs text-muted-foreground">Wind</span>
            <span className="text-sm font-medium">{weather.windSpeed} mph</span>
          </div>
          <div className="flex flex-col items-center space-y-1">
            <Eye className="w-5 h-5 text-gray-500" />
            <span className="text-xs text-muted-foreground">Visibility</span>
            <span className="text-sm font-medium">{weather.visibility} mi</span>
          </div>
        </div>
      </div>
    </Card>
  );
}