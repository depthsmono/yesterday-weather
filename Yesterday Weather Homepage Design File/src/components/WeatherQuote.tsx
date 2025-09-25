import { Card } from "./ui/card";
import { Quote } from "lucide-react";

interface WeatherQuoteProps {
  quote: string;
  author: string;
  source: string;
}

export function WeatherQuote({ quote, author, source }: WeatherQuoteProps) {
  return (
    <Card className="p-4 bg-gradient-to-br from-yellow-50 via-amber-50 to-orange-50 border-0 shadow-sm">
      <div className="space-y-3">
        <Quote className="w-6 h-6 text-amber-600 opacity-60" />
        
        <blockquote className="text-sm italic text-gray-700 leading-relaxed">
          "{quote}"
        </blockquote>
        
        <div className="text-xs text-muted-foreground">
          <p className="font-medium">{author}</p>
          <p className="text-xs">{source}</p>
        </div>
      </div>
    </Card>
  );
}