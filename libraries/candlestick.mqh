//+------------------------------------------------------------------+
//|                                                  candlestick.mq4 |
//|                                            Zoltan Laszlo Ferenci |
//|                              http://www.metatraderprogrammer.com |
//+------------------------------------------------------------------+
#property copyright "Zoltan Laszlo Ferenci"
#property link      "http://www.metatraderprogrammer.com"

//#include <variables.mqh>

string candle_symbol = "";
datetime candle_time = 0;
int candle_dir, candle_bar;
double
candle_high,
candle_low,
candle_open,
candle_close,
candle_body,
candle_range,
candle_bodyhigh,
candle_bodylow,
candle_upwick,
candle_dnwick;

double
high[],
low[],
open[],
close[],
body[],
range[],
bodyhigh[],
bodylow[],
upwick[],
dnwick[];

int candledir[];
datetime candletime[];
string candlesymbol = "";

enum ENUM_CANDLE_DIR {
   DIR_NONE = 0,
   DIR_UP = 1,
   DIR_DN = 2
};

void getcandles(string __symbol, int __timeframe = 0, int barmin = 1, int barmax = 1)
{
   for (int i = barmax; i > barmin; i--) {
      getcandle(__symbol, __timeframe, i, false);
   }
   getcandle(__symbol, __timeframe, barmin, true);
   
   /*
   for (i = barmin; i <= barmax; i++) {
      addcomment("high[",i,"]=",high[i]);
      addcomment(" low[",i,"]=",low[i]);
      addcomment(" open[",i,"]=",open[i]);
      addcomment(" close[",i,"]=",close[i]);
      addcomment(" body[",i,"]=",body[i]);
      addcomment(" range[",i,"]=",range[i]);
      addcomment(" bodyhigh[",i,"]=",bodyhigh[i]);
      addcomment(" bodylow[",i,"]=",bodylow[i]);
      addcomment(" upwick[",i,"]=",upwick[i]);
      addcomment(" dnwick[",i,"]=",dnwick[i]);
      addcomment(" candledir[",i,"]=",candledir[i]);
      addcomment(" candletime[",i,"]=",TimeToStr(candletime[i],TIME_MINUTES));
      addcomment("\n");
   }  
   */
   
}

void getcandle(string __symbol, int __timeframe = 0, int bar = 1, bool usevars = true)
{
   //initalized_alert("getcanlde: ");

   candle_array_incrase_double(high, bar+1);
   candle_array_incrase_double(low, bar+1);
   candle_array_incrase_double(open, bar+1);
   candle_array_incrase_double(close, bar+1);
   candle_array_incrase_double(body, bar+1);
   candle_array_incrase_double(range, bar+1);
   candle_array_incrase_double(bodyhigh, bar+1);
   candle_array_incrase_double(bodylow, bar+1);
   candle_array_incrase_double(upwick, bar+1);   
   candle_array_incrase_double(dnwick, bar+1);
   candle_array_incrase_int(candledir, bar+1);
   candle_array_incrase_datetime(candletime, bar+1);
   
   bool iscurrent = (__symbol == _Symbol && (__timeframe == _Period || __timeframe == 0));
   
   datetime time = iscurrent?Time[bar]:iTime(__symbol,__timeframe,bar);
   
   //addcomment("time=",TimeToStr(time,TIME_MINUTES)," candletime=",TimeToStr(candletime[bar],TIME_MINUTES));
   
   if (time != candletime[bar] || candlesymbol != __symbol || bar == 0) {
      //addcomment(" getcandle");
      candlesymbol = __symbol;
      candletime[bar] = time;
   
      if (iscurrent) {
         high[bar] = High[bar];
         low[bar] = Low[bar];
         open[bar] = Open[bar];
         close[bar] = Close[bar];
      } else {
         high[bar] = iHigh(candlesymbol,__timeframe,bar);
         low[bar] = iLow(candlesymbol,__timeframe,bar);
         open[bar] = iOpen(candlesymbol,__timeframe,bar);
         close[bar] = iClose(candlesymbol,__timeframe,bar);
      }
      body[bar] = MathAbs(open[bar] - close[bar]);
      range[bar] = high[bar] - low[bar];
      if (close[bar] > open[bar])
         candledir[bar] = DIR_UP;
      else if (close[bar] < open[bar])
         candledir[bar] = DIR_DN;
      else if (close[bar] == open[bar])
         candledir[bar] = DIR_NONE;
   
      if ((candledir[bar] == DIR_UP) || (candledir[bar] == DIR_NONE))
      {
         bodyhigh[bar] = close[bar];
         bodylow[bar] = open[bar];
      }
      else if (candledir[bar] == DIR_DN)
      {
         bodyhigh[bar] = open[bar];
         bodylow[bar] = close[bar];
      }
   
      upwick[bar] = high[bar] - bodyhigh[bar];
      dnwick[bar] = bodylow[bar] -  low[bar];
   }
   if (usevars && (candle_bar != bar || candle_time != candletime[bar] || bar == 0)) {
      //addcomment(" getvars");
      candle_bar = bar;
      candle_time = candletime[bar];
      candle_high = high[bar];
      candle_low = low[bar];
      candle_open = open[bar];
      candle_close = close[bar];
      candle_body = body[bar];
      candle_range = range[bar];
      candle_bodyhigh = bodyhigh[bar];
      candle_bodylow = bodylow[bar];
      candle_upwick = upwick[bar];
      candle_dnwick = dnwick[bar];
      candle_dir = candledir[bar];
   }
   //addcomment("\n");
}


int getdir(string __symbol, int __timeframe, int bar)
{
   double __open = iOpen(__symbol,__timeframe,bar);
   double __close = iClose(__symbol,__timeframe,bar);
   
   if (__close > __open)
      return(DIR_UP);
   else if (__close < __open)
      return(DIR_DN);
   else
      return(DIR_NONE);
}

void candle_array_incrase_double(double& array[], int size) {
   if (ArraySize(array) < size) ArrayResize(array,size);
}

void candle_array_incrase_int(int& array[], int size) {
   if (ArraySize(array) < size) ArrayResize(array,size);
}

void candle_array_incrase_datetime(datetime& array[], int size) {
   if (ArraySize(array) < size) ArrayResize(array,size);
}

void getcandle_mindata(string __symbol, int __timeframe, int bar)
{
   candlesymbol = __symbol;
   candle_high = iHigh(candlesymbol,__timeframe,bar);
   candle_low = iLow(candlesymbol,__timeframe,bar);
   candle_open = iOpen(candlesymbol,__timeframe,bar);
   candle_close = iClose(candlesymbol,__timeframe,bar);
}

void getcandle_upwick()
{
   candle_upwick = candle_high-MathMax(candle_open,candle_close);
}

void getcandle_dnwick()
{
   candle_dnwick = MathMin(candle_open,candle_close)-candle_low;
}

void getcandle_body()
{
   candle_body = MathAbs(candle_open-candle_close);
}

double candle_bodytorange(int bar = -1)
{
   if (bar < 0) bar = candle_bar;
   if (range[bar] == 0)
      return(100);
   else   
      return((body[bar]/range[bar])*100);
}

double candle_upwicktobody(int bar = -1)
{
   if (bar < 0) bar = candle_bar;
   if (body[bar] == 0)
   {
      if (upwick[bar] == 0)
         return(0);
      else
         return(100);
   }
   else
   {
      return((upwick[bar]/body[bar])*100);
   }
}

double candle_dnwicktobody(int bar = -1)
{
   if (bar < 0) bar = candle_bar;
   if (body[bar] == 0)
   {
      if (dnwick[bar] == 0)
         return(0);
      else
         return(100);
   }
   else
   {
      return((dnwick[bar]/body[bar])*100);
   }
}


double candle_upwicktorange(int bar = -1)
{
   if (bar < 0) bar = candle_bar;
   if (range[bar] == 0)
   {
      if (upwick[bar] == 0)
         return(0);
      else
         return(100);
   }
   else
   {
      return((upwick[bar]/range[bar])*100);
   }
}

double candle_dnwicktorange(int bar = -1)
{
   if (bar < 0) bar = candle_bar;
   if (range[bar] == 0)
   {
      if (dnwick[bar] == 0)
         return(0);
      else
         return(100);
   }
   else
   {
      return((dnwick[bar]/range[bar])*100);
   }
}