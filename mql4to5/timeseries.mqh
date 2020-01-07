//+------------------------------------------------------------------+
//|                                                   timeseries.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "constants.mqh"

/*int iBarShiftMQL4(string symbol,
                  int tf,
                  datetime time,
                  bool exact=false)
  {
   if(time<0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[],time1;
   CopyTime(symbol,timeframe,0,1,Arr);
   time1=Arr[0];
   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      if(ArraySize(Arr)>2) return(ArraySize(Arr)-1);
      if(time<time1) return(1);
      else return(0);
     }
   else return(-1);
  }*/

int iBarShift(string in_symbol,
                  ENUM_TIMEFRAMES __timeframe,
                  datetime time)
{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(time<0) return(-1);
   datetime Arr[],time1;
   ArrayResize(Arr,2);
   CopyTime(in_symbol,__timeframe,0,1,Arr);
   time1=Arr[0];
   if(CopyTime(in_symbol,__timeframe,time,time1,Arr)>0)
     {
      if(ArraySize(Arr)>2) return(ArraySize(Arr)-1);
      if(time<time1) return(1);
      else return(0);
     }
   else return(-1);
}

/*double iClose(string in_symbol,ENUM_TIMEFRAMES __timeframe,int index)
{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(index < 0) return(-1);
   double Arr[];
   if(CopyClose(in_symbol,__timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iOpen(string in_symbol,ENUM_TIMEFRAMES __timeframe,int index)
{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(index < 0) return(-1);
   double Arr[];
   if(CopyOpen(in_symbol,__timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iHigh(string in_symbol,ENUM_TIMEFRAMES __timeframe,int index)
{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(index < 0) return(-1);
   double Arr[];
   if(CopyHigh(in_symbol,__timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iLow(string in_symbol,ENUM_TIMEFRAMES __timeframe,int index)
{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(index < 0) return(-1);
   double Arr[];
   if(CopyLow(in_symbol,__timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

datetime iTime(string in_symbol,ENUM_TIMEFRAMES __timeframe,int index)

{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(index < 0) return(-1);
   datetime Arr[];
   if(CopyTime(in_symbol, __timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}

datetime iTime(string in_symbol,int __timeframe,int index)

{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(index < 0) return(-1);
   datetime Arr[];
   if(CopyTime(in_symbol, (ENUM_TIMEFRAMES)__timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}
*/

int iHighest(string in_symbol,
                 ENUM_TIMEFRAMES __timeframe,
                 int type,
                 int count=WHOLE_ARRAY,
                 int start=0)
{
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(start<0) return(-1);

   if(count<=0) count=Bars(in_symbol,__timeframe);
   
   if(type==MODE_OPEN)
     {
      double _Open[];
      ArraySetAsSeries(_Open,true);
      CopyOpen(in_symbol,__timeframe,start,count,_Open);
      return(ArrayMaximum(_Open,0,count)+start);
     }
   if(type==MODE_LOW)
     {
      double _Low[];
      ArraySetAsSeries(_Low,true);
      CopyLow(in_symbol,__timeframe,start,count,_Low);
      return(ArrayMaximum(_Low,0,count)+start);
     }
   if(type==MODE_HIGH)
     {
      double _High[];
      ArraySetAsSeries(_High,true);
      CopyHigh(in_symbol,__timeframe,start,count,_High);
      return(ArrayMaximum(_High,0,count)+start);
     }
   if(type==MODE_CLOSE)
     {
      double _Close[];
      ArraySetAsSeries(_Close,true);
      CopyClose(in_symbol,__timeframe,start,count,_Close);
      return(ArrayMaximum(_Close,0,count)+start);
     }
   if(type==MODE_VOLUME)
     {
      long _Volume[];
      ArraySetAsSeries(_Volume,true);
      CopyTickVolume(in_symbol,__timeframe,start,count,_Volume);
      return(ArrayMaximum(_Volume,0,count)+start);
     }
   if(type>=MODE_TIME)
     {
      datetime _Time[];
      ArraySetAsSeries(_Time,true);
      CopyTime(in_symbol,__timeframe,start,count,_Time);
      return(ArrayMaximum(_Time,0,count)+start);
      //---
     }
   return(0);   
}

int iLowest(string in_symbol,
                ENUM_TIMEFRAMES __timeframe,
                int type,
                int count=WHOLE_ARRAY,
                int start=0)
  {
   if (in_symbol == NULL) in_symbol = _Symbol;
   if(start<0) return(-1);
   if(count<=0) count=Bars(in_symbol,__timeframe);
   if(type==MODE_OPEN)
     {
      double _Open[];
      ArraySetAsSeries(_Open,true);
      CopyOpen(in_symbol,__timeframe,start,count,_Open);
      return(ArrayMinimum(_Open,0,count)+start);
     }
   if(type==MODE_LOW)
     {
      double _Low[];
      ArraySetAsSeries(_Low,true);
      CopyLow(in_symbol,__timeframe,start,count,_Low);
      return(ArrayMinimum(_Low,0,count)+start);
     }
   if(type==MODE_HIGH)
     {
      double _High[];
      ArraySetAsSeries(_High,true);
      CopyHigh(in_symbol,__timeframe,start,count,_High);
      return(ArrayMinimum(_High,0,count)+start);
     }
   if(type==MODE_CLOSE)
     {
      double _Close[];
      ArraySetAsSeries(_Close,true);
      CopyClose(in_symbol,__timeframe,start,count,_Close);
      return(ArrayMinimum(_Close,0,count)+start);
     }
   if(type==MODE_VOLUME)
     {
      long _Volume[];
      ArraySetAsSeries(_Volume,true);
      CopyTickVolume(in_symbol,__timeframe,start,count,_Volume);
      return(ArrayMinimum(_Volume,0,count)+start);
     }
   if(type>=MODE_TIME)
     {
      datetime _Time[];
      ArraySetAsSeries(_Time,true);
      CopyTime(in_symbol,__timeframe,start,count,_Time);
      return(ArrayMinimum(_Time,0,count)+start);
     }
//---
   return(0);
  }
  
