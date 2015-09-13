//+------------------------------------------------------------------+
//|                                                mql4functions.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "constants.mqh"
#include "timeseries.mqh"
#include "objects.mqh"
#include "renamed_functions.mqh"
#include "accountinfo.mqh"
#include "technicalindicators.mqh"
#include "mql4orders.mqh"

#define TRUE true
#define FALSE false

bool IsTradeContextBusy()
{
   Print("Deprecated: IsTradeContextBusy()");
   return(false);
}

int DayOfWeek()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day_of_week);
}