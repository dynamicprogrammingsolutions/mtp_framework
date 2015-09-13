//+------------------------------------------------------------------+
//|                                          technicalindicators.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "getindicatorbuffers.mqh"

#define MODE_MAIN 0
#define MODE_SIGNAL 1

double CopyBufferMQL4(int handle,int index,int shift)
  {
   double buf[];
   switch(index)
     {
      case 0: if(CopyBuffer(handle,0,shift,1,buf)>0)
         return(buf[0]); break;
      case 1: if(CopyBuffer(handle,1,shift,1,buf)>0)
         return(buf[0]); break;
      case 2: if(CopyBuffer(handle,2,shift,1,buf)>0)
         return(buf[0]); break;
      case 3: if(CopyBuffer(handle,3,shift,1,buf)>0)
         return(buf[0]); break;
      case 4: if(CopyBuffer(handle,4,shift,1,buf)>0)
         return(buf[0]); break;
      default: break;
     }
   return(EMPTY_VALUE);
  }

double iMACD(string in_symbol,
                 ENUM_TIMEFRAMES timeframe,
                 int fast_ema_period,
                 int slow_ema_period,
                 int signal_period,
                 ENUM_APPLIED_PRICE applied_price,
                 int mode,
                 int shift)
  {
   int handle=iMACD(in_symbol,timeframe,
                    fast_ema_period,slow_ema_period,
                    signal_period,applied_price);
   if(handle<0)
     {
      Print("The iMACD object is not created: Error ",GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode,shift));
  }
  
double iRSI(string in_symbol,
                ENUM_TIMEFRAMES timeframe,
                int period,
                ENUM_APPLIED_PRICE applied_price,
                int shift)
  {
   int handle=iRSI(in_symbol,timeframe,period,applied_price);
   if(handle<0)
     {
      Print("The iRSI object is not created: Error",GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
/*
ENUM_STO_PRICE StoFieldMigrate(int field)
  {
   switch(field)
     {
      case 0: return(STO_LOWHIGH);
      case 1: return(STO_CLOSECLOSE);
      default: return(STO_LOWHIGH);
     }
  }
*/
  
double iStochastic(string in_symbol,
                       ENUM_TIMEFRAMES timeframe,
                       int Kperiod,
                       int Dperiod,
                       int slowing,
                       ENUM_MA_METHOD ma_method,
                       ENUM_STO_PRICE price_field,
                       int mode,
                       int shift)
  {
   int handle=iStochastic(in_symbol,timeframe,Kperiod,Dperiod,
                          slowing,ma_method,price_field);
   if(handle<0)
     {
      Print("The iStochastic object is not created: Error",GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode,shift));
  }

double iCCI(string in_symbol,
                ENUM_TIMEFRAMES timeframe,
                int period,
                ENUM_APPLIED_PRICE applied_price,
                int shift)
  {
   int handle=iCCI(in_symbol,timeframe,period,applied_price);
   if(handle<0)
     {
      Print("The iCCI object is not created: Error",GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
double iMA(string in_symbol,
               ENUM_TIMEFRAMES timeframe,
               int period,
               int ma_shift,
               ENUM_MA_METHOD ma_method,
               ENUM_APPLIED_PRICE applied_price,
               int shift)
  {
   int handle=iMA(in_symbol,timeframe,period,ma_shift,
                  ma_method,applied_price);
   if(handle<0)
     {
      Print("The iMA object is not created: Error",GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
  double iMAOnArray(double &array[],
                      int total,
                      int period,
                      int ma_shift,
                      ENUM_MA_METHOD ma_method,
                      int shift)
  {
   double buf[],arr[];
   if(total==0) total=ArraySize(array);
   if(total>0 && total<=period) return(0);
   if(shift>total-period-ma_shift) return(0);
   switch(ma_method)
     {
      case MODE_SMA :
        {
         total=ArrayCopy(arr,array,0,shift+ma_shift,period);
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,pos=total-1;
         for(i=1;i<period;i++,pos--)
            sum+=arr[pos];
         while(pos>=0)
           {
            sum+=arr[pos];
            buf[pos]=sum/period;
            sum-=arr[pos+period-1];
            pos--;
           }
         return(buf[0]);
        }
      case MODE_EMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double pr=2.0/(period+1);
         int    pos=total-2;
         while(pos>=0)
           {
            if(pos==total-2) buf[pos+1]=array[pos+1];
            buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,k,pos;
         pos=total-period;
         while(pos>=0)
           {
            if(pos==total-period)
              {
               for(i=0,k=pos;i<period;i++,k++)
                 {
                  sum+=array[k];
                  buf[k]=0;
                 }
              }
            else sum=buf[pos+1]*(period-1)+array[pos];
            buf[pos]=sum/period;
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0.0,lsum=0.0;
         double price;
         int    i,weight=0,pos=total-1;
         for(i=1;i<=period;i++,pos--)
           {
            price=array[pos];
            sum+=price*i;
            lsum+=price;
            weight+=i;
           }
         pos++;
         i=pos+period;
         while(pos>=0)
           {
            buf[pos]=sum/weight;
            if(pos==0) break;
            pos--;
            i--;
            price=array[pos];
            sum=sum-lsum+price*period;
            lsum-=array[i];
            lsum+=price;
           }
         return(buf[shift+ma_shift]);
        }
      default: return(0);
     }
   return(0);
  }
  
  