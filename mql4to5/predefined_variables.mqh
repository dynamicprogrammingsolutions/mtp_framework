//+------------------------------------------------------------------+
//|                                         predefined_variables.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

int Bars;
double Ask, Bid, Digits;
double Close[];
double High[];
double Low[];
double Open[];
double Point;
datetime Time[];
long Volume[];

void predefined_variables(int count = 3)
{
   MqlTick last_tick;

   SymbolInfoTick(_Symbol,last_tick);
   Ask=last_tick.ask;
   
   Bars=Bars(_Symbol,_Period);
   
   SymbolInfoTick(_Symbol,last_tick);
   Bid=last_tick.bid;
   
   ArraySetAsSeries(Close,true);
   CopyClose(_Symbol,_Period,0,count,Close);

   Digits=_Digits;
   
   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,_Period,0,count,High);

   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,_Period,0,count,Low);

   ArraySetAsSeries(Open,true);
   CopyOpen(_Symbol,_Period,0,count,Open);
   
   Point=_Point;
   
   ArraySetAsSeries(Time,true);
   CopyTime(_Symbol,_Period,0,count,Time);
   
   ArraySetAsSeries(Volume,true);
   CopyTickVolume(_Symbol,_Period,0,count,Volume);
}

bool RefreshRates()
{
   predefined_variables();
   return(true);
}
