//+------------------------------------------------------------------+
//|                                              commonfunctions.mq4 |
//|                                            Zoltan Laszlo Ferenci |
//|                              http://www.metatraderprogrammer.com |
//+------------------------------------------------------------------+
#property copyright "Zoltan Laszlo Ferenci"
#property link      "http://www.metatraderprogrammer.com"

#include "arrays.mqh"

double MathMaxNoZero(double value1, double value2)
{
   if (value1 == 0) return value2;
   if (value2 == 0) return value1;
   return MathMax(value1,value2);
}

double MathMinNoZero(double value1, double value2)
{
   if (value1 == 0) return value2;
   if (value2 == 0) return value1;
   return MathMin(value1,value2);
}

#define ISSET(__obj__) (CheckPointer(__obj__)!=POINTER_INVALID)

bool isset(const CObject* anyobject)
{
   return(CheckPointer(anyobject)!=POINTER_INVALID);
}

bool empty(double val)
{
   return(val == 0 || val == EMPTY_VALUE);
}

/*int shiftconvert(int bar1, ENUM_TIMEFRAMES timeframe1, ENUM_TIMEFRAMES timeframe2, string symbol1, string symbol2 = "")
{
   if (symbol1 == "") symbol1 = _Symbol;
   if (symbol2 == "") symbol2 = symbol1;
   return(iBarShift(symbol2,timeframe2,iTime(symbol1,timeframe1,bar1)));
}*/

string tfname(ENUM_TIMEFRAMES tf)
{
   switch (tf) {
   case PERIOD_M1: return("M1");
   case PERIOD_M5: return("M5");
   case PERIOD_M15: return("M15");
   case PERIOD_M30: return("M30");
   case PERIOD_H1: return("H1");
   case PERIOD_H4: return("H4");
   case PERIOD_D1: return("D1");
   case PERIOD_W1: return("W1");
   case PERIOD_MN1: return("MN1");
   }
   return("");
}

bool runonce_have_run = false;

void runonce_reset()
{
   runonce_have_run = false;
}

bool runonce()
{
   if (runonce_have_run) return(false);
   else {
      runonce_have_run = true;
      return(true);
   }
}

/*
void printerror(string point)
{
   int lasterror = GetLastError();
   if (lasterror > 0) Print(point," error:",lasterror);
}
*/

string tf_name(int in_timeframe)
{
   switch (in_timeframe) {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN1");
      default: return("Invalid TF");
   }
}

double if_d(bool condition, double iftrue, double iffalse)
{
   if (condition) return(iftrue);
   else return(iffalse);
}

string if_s(bool condition, string iftrue, string iffalse)
{
   if (condition) return(iftrue);
   else return(iffalse);
}
/*
*/

bool isvaluechanged(int val, int id, int def = 0)
{
   static int last_value[];
   array_increase_int(last_value,id+1,def);
   if (val != last_value[id]) {
      last_value[id] = val;
      return(true);
   } else {
      last_value[id] = val;
      return(false);
   }
}

void printval(string name, double val, bool printnow = false)
{
   static string print = "";
   print = print + name + ": " + (string)val + " ";
   if (printnow) {
      Print(print);
      print = "";
   }
}