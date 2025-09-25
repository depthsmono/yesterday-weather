import { ScrollArea } from "./ui/scroll-area";
import { Card } from "./ui/card";
import { Sun, Cloud, CloudRain, Snowflake } from "lucide-react";

interface HourlyWeather {
  time: string;
  temperature: number;
  condition: string;
  precipitation: number;
}

interface HourlyForecastProps {
  currentCondition: string;
  currentTemp: number;
  hourlyData: HourlyWeather[];
}

const getSmallWeatherIcon = (condition: string) => {
  const iconProps = { className: "w-6 h-6" };
  
  switch (condition.toLowerCase()) {
    case 'sunny':
    case 'clear':
      return <Sun {...iconProps} className="w-6 h-6 text-yellow-500" />;
    case 'cloudy':
    case 'partly cloudy':
      return <Cloud {...iconProps} className="w-6 h-6 text-gray-400" />;
    case 'rainy':
    case 'light rain':
      return <CloudRain {...iconProps} className="w-6 h-6 text-blue-500" />;
    case 'snowy':
      return <Snowflake {...iconProps} className="w-6 h-6 text-blue-200" />;
    default:
      return <Sun {...iconProps} className="w-6 h-6 text-yellow-500" />;
  }
};

export function HourlyForecast({ currentCondition, currentTemp, hourlyData }: HourlyForecastProps) {
  return (
    <Card className="p-3 bg-gradient-to-r from-violet-50 via-purple-50 to-pink-50 border-0 shadow-sm">
      <div className="space-y-3">
        {/* Today's headline */}
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-muted-foreground">Now</p>
            <div className="flex items-center space-x-2 mt-1">
              {getSmallWeatherIcon(currentCondition)}
              <span className="text-xl font-light">{currentTemp}°</span>
            </div>
          </div>
          <p className="text-xs text-muted-foreground">{currentCondition}</p>
        </div>
        
        {/* Hourly forecast scroll */}
        <ScrollArea className="w-full">
          <div className="flex space-x-3 pb-1">
            {hourlyData.map((hour, index) => (
              <div key={index} className="flex flex-col items-center space-y-1 min-w-14">
                <p className="text-xs text-muted-foreground">{hour.time}</p>
                {getSmallWeatherIcon(hour.condition)}
                <p className="text-sm font-medium">{hour.temperature}°</p>
                {hour.precipitation > 0 && (
                  <p className="text-xs text-blue-500">{hour.precipitation}%</p>
                )}
              </div>
            ))}
          </div>
        </ScrollArea>
      </div>
    </Card>
  );
}