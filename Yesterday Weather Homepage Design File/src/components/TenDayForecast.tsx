import { ScrollArea } from "./ui/scroll-area";
import { Card } from "./ui/card";
import { Sun, Cloud, CloudRain, Snowflake } from "lucide-react";

interface DayForecast {
  day: string;
  date: string;
  condition: string;
  highTemp: number;
  lowTemp: number;
  precipitation: number;
}

interface TenDayForecastProps {
  forecast: DayForecast[];
}

const getWeatherIcon = (condition: string) => {
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

export function TenDayForecast({ forecast }: TenDayForecastProps) {
  return (
    <Card className="p-3 bg-gradient-to-r from-emerald-50 via-teal-50 to-cyan-50 border-0 shadow-sm">
      <div className="space-y-3">
        <h3 className="text-sm font-medium text-muted-foreground">10-Day Forecast</h3>
        
        <ScrollArea className="w-full">
          <div className="flex space-x-3 pb-1">
            {forecast.map((day, index) => (
              <div key={index} className="flex flex-col items-center space-y-1 min-w-16">
                <div className="text-center">
                  <p className="text-xs font-medium">{day.day}</p>
                  <p className="text-xs text-muted-foreground">{day.date}</p>
                </div>
                
                {getWeatherIcon(day.condition)}
                
                <div className="text-center">
                  <p className="text-sm font-medium">{day.highTemp}°</p>
                  <p className="text-xs text-muted-foreground">{day.lowTemp}°</p>
                </div>
                
                {day.precipitation > 0 && (
                  <p className="text-xs text-blue-500">{day.precipitation}%</p>
                )}
              </div>
            ))}
          </div>
        </ScrollArea>
      </div>
    </Card>
  );
}