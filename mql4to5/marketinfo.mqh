//+------------------------------------------------------------------+
//|                                                   marketinfo.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "constants.mqh"

bool IsExpertEnabled()
{
   return((bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT));
}

bool IsTradeAllowed()
{
   return((bool)MQL5InfoInteger(MQL5_TRADE_ALLOWED));
}

double MarketInfo(string symbol, int type)
{
MqlTick last_tick;
switch(type)
  {
   case MODE_LOW:
      return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
   case MODE_HIGH:
      return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
   case MODE_TIME:
      return((double)SymbolInfoInteger(symbol,SYMBOL_TIME));
   case MODE_BID:
      SymbolInfoTick(symbol,last_tick);
      return(last_tick.bid);
   case MODE_ASK:
      SymbolInfoTick(symbol,last_tick);
      return(last_tick.ask);
   case MODE_POINT:
      return(SymbolInfoDouble(symbol,SYMBOL_POINT));
   case MODE_DIGITS:
      return((double)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   case MODE_SPREAD:
      return((double)SymbolInfoInteger(symbol,SYMBOL_SPREAD));
   case MODE_STOPLEVEL:
      return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
   case MODE_LOTSIZE:
      return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
   case MODE_TICKVALUE:
      return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
   case MODE_TICKSIZE:
      return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
   case MODE_SWAPLONG:
      return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
   case MODE_SWAPSHORT:
      return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
   case MODE_STARTING:
      return(0);
   case MODE_EXPIRATION:
      return(0);
   case MODE_TRADEALLOWED:
      return(0);
   case MODE_MINLOT:
      return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
   case MODE_LOTSTEP:
      return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
   case MODE_MAXLOT:
      return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
   case MODE_SWAPTYPE:
      return((double)SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
   case MODE_PROFITCALCMODE:
      return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
   case MODE_MARGINCALCMODE:
      return(0);
   case MODE_MARGININIT:
      return(0);
   case MODE_MARGINMAINTENANCE:
      return(0);
   case MODE_MARGINHEDGED:
      return(0);
   case MODE_MARGINREQUIRED:
      return(0);
   case MODE_FREEZELEVEL:
      return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));

   default: return(0);
  }
   return(0);
}
