import { MapPin, RefreshCw } from "lucide-react";
import { Button } from "./ui/button";

interface LocationHeaderProps {
  location: string;
  lastUpdated: string;
  onRefresh: () => void;
}

export function LocationHeader({ location, lastUpdated, onRefresh }: LocationHeaderProps) {
  return (
    <div className="flex items-center justify-between p-4 bg-white/80 backdrop-blur-md border-b border-gray-200">
      <div className="flex items-center space-x-2">
        <MapPin className="w-5 h-5 text-blue-600" />
        <div>
          <h1 className="font-semibold">{location}</h1>
          <p className="text-xs text-muted-foreground">Updated {lastUpdated}</p>
        </div>
      </div>
      
      <Button
        variant="ghost"
        size="sm"
        onClick={onRefresh}
        className="h-8 w-8 p-0"
      >
        <RefreshCw className="w-4 h-4" />
      </Button>
    </div>
  );
}