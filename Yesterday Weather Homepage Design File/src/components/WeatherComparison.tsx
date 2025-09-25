import { Card } from "./ui/card";
import { 
  Thermometer,
  Droplets,
  CloudRain,
  Wind,
  TrendingUp,
  TrendingDown,
  Minus
} from "lucide-react";

interface WeatherData {
  temperature: number;
  condition: string;
  humidity: number;
  windSpeed: number;
  precipitation: number;
}

interface WeatherComparisonProps {
  yesterday: WeatherData;
  today: WeatherData;
}

const getComparisonText = (metric: string, difference: number, yesterdayValue: number, todayValue: number) => {
  const absDiff = Math.abs(difference);
  
  switch (metric) {
    case 'temperature':
      if (difference > 5) return "much warmer";
      if (difference > 2) return "warmer";
      if (difference < -5) return "much cooler";
      if (difference < -2) return "cooler";
      return "similar temperature";
    
    case 'humidity':
      if (difference > 15) return "much more humid";
      if (difference > 5) return "more humid";
      if (difference < -15) return "much drier";
      if (difference < -5) return "drier";
      return "similar humidity";
    
    case 'precipitation':
      if (todayValue > 50 && yesterdayValue < 20) return "much rainier";
      if (todayValue > 20 && yesterdayValue < 10) return "rainier";
      if (todayValue < 10 && yesterdayValue > 20) return "much drier";
      if (todayValue < 20 && yesterdayValue > 50) return "drier";
      return "similar chance of rain";
    
    case 'wind':
      if (difference > 8) return "much windier";
      if (difference > 3) return "windier";
      if (difference < -8) return "much calmer";
      if (difference < -3) return "calmer";
      return "similar wind";
    
    default:
      return "similar";
  }
};

const getTrendIcon = (difference: number) => {
  if (difference > 0) return <TrendingUp className="w-4 h-4 text-emerald-600" />;
  if (difference < 0) return <TrendingDown className="w-4 h-4 text-rose-600" />;
  return <Minus className="w-4 h-4 text-slate-500" />;
};

const getTrendColor = (difference: number) => {
  if (difference > 0) return "text-emerald-600";
  if (difference < 0) return "text-rose-600";
  return "text-slate-500";
};

export function WeatherComparison({ yesterday, today }: WeatherComparisonProps) {
  const tempDiff = today.temperature - yesterday.temperature;
  const humidityDiff = today.humidity - yesterday.humidity;
  const precipDiff = today.precipitation - yesterday.precipitation;
  const windDiff = today.windSpeed - yesterday.windSpeed;

  const comparisons = [
    {
      icon: <Thermometer className="w-5 h-5 text-orange-500" />,
      metric: "Temperature",
      yesterday: yesterday.temperature,
      today: today.temperature,
      unit: "°",
      difference: tempDiff,
      narrative: getComparisonText('temperature', tempDiff, yesterday.temperature, today.temperature)
    },
    {
      icon: <Droplets className="w-5 h-5 text-blue-500" />,
      metric: "Humidity",
      yesterday: yesterday.humidity,
      today: today.humidity,
      unit: "%",
      difference: humidityDiff,
      narrative: getComparisonText('humidity', humidityDiff, yesterday.humidity, today.humidity)
    },
    {
      icon: <CloudRain className="w-5 h-5 text-indigo-500" />,
      metric: "Precipitation",
      yesterday: yesterday.precipitation,
      today: today.precipitation,
      unit: "%",
      difference: precipDiff,
      narrative: getComparisonText('precipitation', precipDiff, yesterday.precipitation, today.precipitation)
    },
    {
      icon: <Wind className="w-5 h-5 text-teal-500" />,
      metric: "Wind Speed",
      yesterday: yesterday.windSpeed,
      today: today.windSpeed,
      unit: " mph",
      difference: windDiff,
      narrative: getComparisonText('wind', windDiff, yesterday.windSpeed, today.windSpeed)
    }
  ];

  return (
    <Card className="p-4 bg-gradient-to-br from-rose-50 via-orange-50 to-amber-50 border-0 shadow-sm">
      <div className="space-y-4">
        {/* Header */}
        <div className="text-center">
          <h3 className="text-base font-medium text-slate-800">Yesterday vs Today</h3>
          <p className="text-xs text-slate-600 mt-1">How does today compare?</p>
        </div>

        {/* Comparisons */}
        <div className="space-y-3">
          {comparisons.map((comparison, index) => (
            <div key={index} className="bg-white/60 backdrop-blur-sm rounded-lg p-3 border border-white/40">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center space-x-2">
                  {comparison.icon}
                  <span className="text-sm font-medium text-slate-800">{comparison.metric}</span>
                </div>
                <div className="flex items-center space-x-2">
                  {getTrendIcon(comparison.difference)}
                  <span className={`text-xs font-medium ${getTrendColor(comparison.difference)}`}>
                    {comparison.difference > 0 ? '+' : ''}{comparison.difference}{comparison.unit}
                  </span>
                </div>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3 text-xs">
                  <div className="text-center">
                    <p className="text-xs text-slate-500 uppercase tracking-wide">Yesterday</p>
                    <p className="text-sm font-medium text-slate-700">{comparison.yesterday}{comparison.unit}</p>
                  </div>
                  <div className="text-slate-400">→</div>
                  <div className="text-center">
                    <p className="text-xs text-slate-500 uppercase tracking-wide">Today</p>
                    <p className="text-sm font-medium text-slate-800">{comparison.today}{comparison.unit}</p>
                  </div>
                </div>
                
                <div className="text-right">
                  <p className="text-xs font-medium text-slate-700 capitalize">{comparison.narrative}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Summary */}
        <div className="bg-gradient-to-r from-pink-100 to-orange-100 rounded-lg p-3 border border-pink-200/50">
          <p className="text-xs text-slate-700 text-center">
            Today feels{" "}
            <span className="font-medium">
              {tempDiff > 0 ? "warmer" : tempDiff < 0 ? "cooler" : "similar"}
            </span>
            {humidityDiff !== 0 && (
              <>
                {" "}and{" "}
                <span className="font-medium">
                  {humidityDiff > 0 ? "more humid" : "drier"}
                </span>
              </>
            )}
            {" "}than yesterday.
          </p>
        </div>
      </div>
    </Card>
  );
}