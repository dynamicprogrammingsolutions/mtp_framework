//

int get_fractal_up(int from, int idx, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0)
{
   int cnt = 0;
   for (int i = from; i <= iBars(__symbol,_timeframe); i++) {
      double fractal_up = iFractals(__symbol,_timeframe,MODE_UPPER,i);
      if (fractal_up != 0) {
         if (cnt >= idx) {
            return(i);
            break;
         }
         cnt++;
      }            
   }
   return(-1);   
}

int get_fractal_dn(int from, int idx, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0)
{
   int cnt = 0;
   for (int i = from; i <= iBars(__symbol,_timeframe); i++) {
      double fractal_up = iFractals(__symbol,_timeframe,MODE_LOWER,i);
      if (fractal_up != 0) {
         if (cnt >= idx) {
            return(i);
            break;
         }
         cnt++;
      }            
   }
   return(-1);   
}


int get_fractal_up(int from, int idx, double& fractal_up, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0)
{
   int cnt = 0;
   for (int i = from; i <= iBars(__symbol,_timeframe); i++) {
      fractal_up = iFractals(__symbol,_timeframe,MODE_UPPER,i);
      if (fractal_up != 0) {
         if (cnt >= idx) {
            return(i);
            break;
         }
         cnt++;
      }            
   }
   return(-1);   
}

int get_fractal_dn(int from, int idx, double& fractal_dn, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0)
{
   int cnt = 0;
   for (int i = from; i <= iBars(__symbol,_timeframe); i++) {
      fractal_dn = iFractals(__symbol,_timeframe,MODE_LOWER,i);
      if (fractal_dn != 0) {
         if (cnt >= idx) {
            return(i);
            break;
         }
         cnt++;
      }            
   }
   return(-1);   
}


double highesthigh(int minbar=1, int maxbar=1, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0)
{
   return(iHigh(__symbol,_timeframe,highest_bar(minbar,maxbar,__symbol,_timeframe)));
}

double lowestlow(int minbar=1, int maxbar=1, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0)
{
   return(iLow(__symbol,_timeframe,lowest_bar(minbar,maxbar,__symbol,_timeframe)));
}

int highest_bar(int minbar=1, int maxbar=1, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0, int series_mode = MODE_HIGH)
{
   if (minbar > maxbar) {
      int temp = minbar;
      minbar = maxbar;
      maxbar = temp;
   }
   return(iHighest(__symbol,_timeframe,series_mode,maxbar-minbar+1,minbar));
}

int lowest_bar(int minbar=1, int maxbar=1, string __symbol = NULL, ENUM_TIMEFRAMES _timeframe=0, int series_mode = MODE_LOW)
{
   if (minbar > maxbar) {
      int temp = minbar;
      minbar = maxbar;
      maxbar = temp;
   }
   return(iLowest(__symbol,_timeframe,series_mode,maxbar-minbar+1,minbar));
}
