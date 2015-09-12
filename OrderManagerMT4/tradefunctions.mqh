//+------------------------------------------------------------------+
//|                                               tradefunctions.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "MT4OrderInfo.mqh"
#include "..\SymbolLoader\SymbolLoaderMT4.mqh"

enum ENUM_ORDERSELECT {
   ORDERSELECT_ANY,
   ORDERSELECT_MARKET,
   ORDERSELECT_PENDING,
   ORDERSELECT_LIMIT,
   ORDERSELECT_STOP,
   ORDERSELECT_BUY,
   ORDERSELECT_SELL,
   ORDERSELECT_BUYSTOP,
   ORDERSELECT_SELLSTOP,
   ORDERSELECT_BUYLIMIT,
   ORDERSELECT_SELLLIMIT,
   ORDERSELECT_LONG,
   ORDERSELECT_SHORT,
   ORDERSELECT_LONGPENDING,
   ORDERSELECT_SHORTPENDING,
   ORDERSELECT_NONE
};


enum ENUM_STATESELECT {
   STATESELECT_ANY,
   STATESELECT_PLACED,
   STATESELECT_CANCELED,
   STATESELECT_FILLED,
   STATESELECT_UNDONE,
   STATESELECT_ONGOING,
   STATESELECT_CLOSED
};

string statename(ENUM_ORDER_STATE state)
{
   switch (state)
   {
      case ORDER_STATE_UNKNOWN: return "Unknown";
      case ORDER_STATE_PLACED: return "Placed";
      case ORDER_STATE_FILLED: return "Filled";
      case ORDER_STATE_DELETED: return "Deleted";
      case ORDER_STATE_CLOSED: return "Closed";
   }
   return "";
}

int ordertype_opposite(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY:
         return(ORDER_TYPE_SELL);
      case ORDER_TYPE_SELL:
         return(ORDER_TYPE_BUY);
      case ORDER_TYPE_BUY_STOP:
         return(ORDER_TYPE_SELL_STOP);
      case ORDER_TYPE_SELL_STOP:
         return(ORDER_TYPE_BUY_STOP);
      case ORDER_TYPE_BUY_LIMIT:
         return(ORDER_TYPE_SELL_LIMIT);
      case ORDER_TYPE_SELL_LIMIT:
         return(ORDER_TYPE_BUY_LIMIT);
      default:
         return(-1);
   }
}

int ordertype_opposite_stop(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return(ORDER_TYPE_SELL_STOP);
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return(ORDER_TYPE_BUY_STOP);
      default:
         return(-1);
   }
}


bool ordertype_pending(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_SELL_STOP:
         return(true);
      default:
         return(false);
   }
}

bool ordertype_stop(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_SELL_STOP:
         return(true);
      default:
         return(false);
   }
}

bool ordertype_limit(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_SELL_LIMIT:
         return(true);
      default:
         return(false);
   }
}

bool ordertype_market(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_SELL:
         return(true);
      default:
         return(false);
   }
}

bool ordertype_pendinglong(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
         return(true);
      default:
         return(false);
   }
}

bool ordertype_long(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
         return(true);
      default:
         return(false);
   }
}

bool ordertype_short(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
         return(true);
      default:
         return(false);
   }
}


bool ordertype_pendingshort(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
         return(true);
      default:
         return(false);
   }
}

int ordertype_convert_to_market(int in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
         return(ORDER_TYPE_SELL);
         break;
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
         return(ORDER_TYPE_BUY);
         break;
      default:
         return(-1);
   }
}

bool ordertype_select(ENUM_ORDERSELECT type, int ordtype)
{
   if (type == ORDERSELECT_ANY)
      return(true);
   
   if (type == ORDERSELECT_MARKET)
   {
      if ((ordtype == ORDER_TYPE_BUY) || (ordtype == ORDER_TYPE_SELL))
      {
         return(true);
      }
      else
         return(false);
   }

   if (type == ORDERSELECT_PENDING)
   {   
      if ((ordtype == ORDER_TYPE_BUY_LIMIT) || (ordtype == ORDER_TYPE_SELL_LIMIT) || (ordtype == ORDER_TYPE_BUY_STOP) || (ordtype == ORDER_TYPE_SELL_STOP))
         return(true);
      else
         return(false);
   }
   
   if (type == ORDERSELECT_LIMIT)
   {
      if ((ordtype == ORDER_TYPE_BUY_LIMIT) || (ordtype == ORDER_TYPE_SELL_LIMIT))
         return(true);
      else
         return(false);
   }
   
   if (type == ORDERSELECT_STOP)
   {
      if ((ordtype == ORDER_TYPE_BUY_STOP) || (ordtype == ORDER_TYPE_SELL_STOP))
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_BUY)
   {
      if (ordtype == ORDER_TYPE_BUY)
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_SELL)
   {
      if (ordtype == ORDER_TYPE_SELL)
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_BUYSTOP)
   {
      if (ordtype == ORDER_TYPE_BUY_STOP)
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_SELLSTOP)
   {
      if (ordtype == ORDER_TYPE_SELL_STOP)
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_BUYLIMIT)
   {
      if (ordtype == ORDER_TYPE_BUY_LIMIT)
         return(true);
      else
         return(false);
   }
   
   if (type == ORDERSELECT_SELLLIMIT)
   {
      if (ordtype == ORDER_TYPE_SELL_LIMIT)
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_LONG)
   {
      if (ordtype == ORDER_TYPE_BUY || ordtype == ORDER_TYPE_BUY_LIMIT || ordtype == ORDER_TYPE_BUY_STOP)
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_SHORT)
   {
      if (ordtype == ORDER_TYPE_SELL || ordtype == ORDER_TYPE_SELL_LIMIT || ordtype == ORDER_TYPE_SELL_STOP)
         return(true);
      else
         return(false);
   }
   
   if (type == ORDERSELECT_LONGPENDING)
   {
      if (ordtype == ORDER_TYPE_BUY_LIMIT || ordtype == ORDER_TYPE_BUY_STOP)
         return(true);
      else
         return(false);
   }

   if (type == ORDERSELECT_SHORTPENDING)
   {
      if (ordtype == ORDER_TYPE_SELL_LIMIT || ordtype == ORDER_TYPE_SELL_STOP)
         return(true);
      else
         return(false);
   }

   return(true);
}

bool state_placed(ENUM_ORDER_STATE orderstate)
{
   if (orderstate == ORDER_STATE_PLACED) return(true);
   else return(false);
}

bool state_canceled(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_DELETED:
         return(true);
      default:
         return(false);
   }
}

bool state_filled(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_FILLED:
         return(true);
      default:
         return(false);
   }
}

bool state_undone(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_PLACED:
         return(true);
      default:
         return(false);
   }
}

bool state_ongoing(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_PLACED:
      case ORDER_STATE_FILLED:
         return(true);
      default:
         return(false);
   }
}


bool state_select(ENUM_STATESELECT stateselect, ENUM_ORDER_STATE orderstate) {
   switch (stateselect) {
      case STATESELECT_ANY:
         return(true);
      case STATESELECT_PLACED:
         return(state_placed(orderstate));
      case STATESELECT_CANCELED:
         return(state_canceled(orderstate));
      case STATESELECT_FILLED:
         return(state_filled(orderstate));
      case STATESELECT_UNDONE:
         return(state_undone(orderstate));
      case STATESELECT_ONGOING:
         return(state_ongoing(orderstate));
      case STATESELECT_CLOSED:
         return(orderstate == ORDER_STATE_CLOSED);
      default:
         return(false);
   }
}

double getstoplossprice(string in_symbol, int in_ordertype, int in_stoploss, double price=0, bool formodify = false)
{
   if (price == 0) {
      price = getentryprice(in_symbol,in_ordertype,0,0);      
   }

   if (ordertype_long(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_SELL_STOP,in_stoploss,price));
   }
   else if (ordertype_short(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_BUY_STOP,in_stoploss,price));
   }
   else Print(__FUNCTION__,": Invalid Order Type");
   return(0);
}

double gettakeprofitprice(string in_symbol, int in_ordertype, int in_stoploss, double price=0, bool formodify = false)
{
   if (price == 0) {
      price = getentryprice(in_symbol,in_ordertype,0,0);      
   }

   if (ordertype_long(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_SELL_LIMIT,in_stoploss,price));
   }
   else if (ordertype_short(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_BUY_LIMIT,in_stoploss,price));
   }
   else Print(__FUNCTION__,": Invalid Order Type");
   return(0);
}

double getentryprice(string in_symbol, int in_ordertype, int entrydistance, double price = 0)
{
   loadsymbol(in_symbol,__FUNCTION__);

   if (price == 0) {      
      if (ordertype_long(in_ordertype)) price = _symbol.Ask();
      else if (ordertype_short(in_ordertype)) price = _symbol.Bid();
   }
   
   switch (in_ordertype) {
   case (ORDER_TYPE_BUY):
      return(price);
   case (ORDER_TYPE_SELL):
      return(price);
   case (ORDER_TYPE_BUY_LIMIT):
      return(price-entrydistance*_symbol.TickSizeR());
   case (ORDER_TYPE_BUY_STOP):
      return(price+entrydistance*_symbol.TickSizeR());
   case (ORDER_TYPE_SELL_LIMIT):
      return(price+entrydistance*_symbol.TickSizeR());
   case (ORDER_TYPE_SELL_STOP):
      return(price-entrydistance*_symbol.TickSizeR());
   default:
      Print(__FUNCTION__,": Invalid Order Type");
      return(0);      
   }
}

//bool debug = false;

int getstoplossticks(string in_symbol, int in_ordertype, double in_stoploss, double price=0)
{
   //if (debug) Print("getstoplossticks");
   if (in_stoploss == 0)
      return(0);
      
   if (price == 0)
   {
      loadsymbol(in_symbol,__FUNCTION__);
      if (ordertype_long(in_ordertype))
         {price = _symbol.Ask();}
      else if (ordertype_short(in_ordertype))
         {price = _symbol.Bid();}
   }

   if (ordertype_long(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_SELL_STOP,in_stoploss,price));
   else if (ordertype_short(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_BUY_STOP,in_stoploss,price));
   
   return(0);
}

int gettakeprofitticks(string in_symbol, int in_ordertype, double in_takeprofit, double price=0)
{
   if (in_takeprofit == 0)
      return(0);

   if (price == 0)
   {
      loadsymbol(in_symbol,__FUNCTION__);
      if (ordertype_long(in_ordertype))
         {price = _symbol.Ask();}
      else if (ordertype_short(in_ordertype))
         {price = _symbol.Bid();}
   }

   if (ordertype_long(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_SELL_LIMIT,in_takeprofit,price));
   else if (ordertype_short(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_BUY_LIMIT,in_takeprofit,price));
   
   return(0);
}

int getprofitticks(string in_symbol, int in_ordertype, double closeprice, double entryprice)
{
   if (ordertype_long(in_ordertype)) {
      return(_symbol.InTicks(closeprice-entryprice));
   } else if (ordertype_short(in_ordertype)) {
      return(_symbol.InTicks(-closeprice+entryprice));
   }
   return(0);
}



int getentrypriceticks(string in_symbol,int in_ordertype, double entryprice, double price=0)
{
   loadsymbol(in_symbol,__FUNCTION__);
   
   if (price == 0)
   {
      if (ordertype_long(in_ordertype))
         {price = _symbol.Ask();}
      else if (ordertype_short(in_ordertype))
         {price = _symbol.Bid();}
      else
      {
         Print(__FUNCTION__,": Invalid Order Type");
         return(-1);
      }
   }
   switch (in_ordertype) {
   case ORDER_TYPE_BUY_LIMIT:
   case ORDER_TYPE_SELL_STOP:
      //if (debug) Print(price+"-"+entryprice);
      return(_symbol.InTicks(price-entryprice));
   case ORDER_TYPE_SELL_LIMIT:
   case ORDER_TYPE_BUY_STOP:
      //if (debug) Print("-"+price+"+"+entryprice);
      return(_symbol.InTicks(-price+entryprice));
   }
   return(0);
}

double getcurrententryprice(string in_symbol, int in_ordertype)
{
   loadsymbol(in_symbol,__FUNCTION__);
   double currentprice = 0;
   if (ordertype_long(in_ordertype)) currentprice = _symbol.Ask();
   else if (ordertype_short(in_ordertype)) currentprice = _symbol.Bid();
   return(currentprice);
}

double getcurrentcloseprice(string in_symbol, int in_ordertype)
{
   loadsymbol(in_symbol,__FUNCTION__);
   double currentprice = 0;
   if (ordertype_long(in_ordertype)) currentprice = _symbol.Bid();
   else if (ordertype_short(in_ordertype)) currentprice = _symbol.Ask();
   return(currentprice);
}

bool verifysl(string in_symbol, int in_stoploss)
{
   loadsymbol(in_symbol,__FUNCTION__);
   if ((in_stoploss >= _symbol.MinStopLoss()) || (in_stoploss == 0))
      return(true);
      
   return(false);
}

bool verifytp(string in_symbol, int in_takeprofit)
{
   loadsymbol(in_symbol,__FUNCTION__);
   if ((in_takeprofit >= _symbol.MinTakeProfit()) || (in_takeprofit == 0))
      return(true);
      
   return(false);
}

bool verifyentry(string in_symbol, int in_entry)
{
   loadsymbol(in_symbol,__FUNCTION__);
   if (in_entry >= _symbol.StopsLevelInTicks())
      return(true);
   return(false);
}