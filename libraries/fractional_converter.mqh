//+------------------------------------------------------------------+
//|                                         fractional_converter.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#define FRACTIONAL_TRESHOLD 50000

int ConvertPipsToTicks(double ticks, string symbol) {
   return IsFractional(symbol) ? (int)ticks*10 : (int)ticks;
}

int ConvertPipsToPoints(double pips, string symbol) {
   return IsFractional(symbol) ? (int)pips*10 : (int)pips;
}

bool IsFractional(string symbol, double treshold = FRACTIONAL_TRESHOLD)
{
   double ticksize = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   return bid/ticksize > treshold;
}