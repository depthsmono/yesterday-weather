import { Card } from "./ui/card";
import { Badge } from "./ui/badge";
import { TrendingUp, TrendingDown, Minus } from "lucide-react";

interface WeatherComparison {
  metric: string;
  yesterday: number | string;
  today: number | string;
  unit: string;
  difference: number;
  percentChange?: number;
}

interface ComparisonCardProps {
  comparisons: WeatherComparison[];
}

const getTrendIcon = (difference: number) => {
  if (difference > 0) {
    return <TrendingUp className="w-4 h-4 text-green-600" />;
  } else if (difference < 0) {
    return <TrendingDown className="w-4 h-4 text-red-600" />;
  } else {
    return <Minus className="w-4 h-4 text-gray-500" />;
  }
};

const getTrendColor = (difference: number) => {
  if (difference > 0) return "text-green-600";
  if (difference < 0) return "text-red-600";
  return "text-gray-500";
};

const formatDifference = (difference: number, unit: string) => {
  const sign = difference > 0 ? "+" : "";
  return `${sign}${difference}${unit}`;
};

export function ComparisonCard({ comparisons }: ComparisonCardProps) {
  return (
    <Card className="p-6 bg-gradient-to-br from-gray-50 to-slate-100 border-0 shadow-lg">
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold">Yesterday vs Today</h3>
          <Badge variant="outline" className="bg-white">
            Comparison
          </Badge>
        </div>

        <div className="space-y-4">
          {comparisons.map((comparison, index) => (
            <div key={index} className="flex items-center justify-between p-3 rounded-lg bg-white/70 backdrop-blur-sm">
              <div className="flex-1">
                <p className="font-medium">{comparison.metric}</p>
                <div className="flex items-center space-x-4 mt-1">
                  <span className="text-sm text-muted-foreground">
                    {comparison.yesterday}{comparison.unit} → {comparison.today}{comparison.unit}
                  </span>
                </div>
              </div>
              
              <div className="flex items-center space-x-2">
                {getTrendIcon(comparison.difference)}
                <span className={`text-sm font-medium ${getTrendColor(comparison.difference)}`}>
                  {formatDifference(comparison.difference, comparison.unit)}
                </span>
                {comparison.percentChange !== undefined && (
                  <span className={`text-xs ${getTrendColor(comparison.difference)}`}>
                    ({comparison.percentChange > 0 ? "+" : ""}{comparison.percentChange}%)
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>

        <div className="mt-4 p-3 rounded-lg bg-blue-50 border border-blue-200">
          <p className="text-sm text-blue-800">
            <strong>Summary:</strong> Today is{" "}
            {comparisons[0]?.difference > 0 ? "warmer" : comparisons[0]?.difference < 0 ? "cooler" : "the same temperature"} than yesterday
            {comparisons[1]?.difference !== 0 && (
              `, with ${Math.abs(comparisons[1]?.difference)}% ${comparisons[1]?.difference > 0 ? "higher" : "lower"} humidity`
            )}
            .
          </p>
        </div>
      </div>
    </Card>
  );
}