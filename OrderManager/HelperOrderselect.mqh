//
#include "Loader.mqh"

#define HELPER_ORDERSELECT_H

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

ENUM_ORDER_TYPE ordertype_convert_to_market(ENUM_ORDER_TYPE in_ordertype) {
   switch (in_ordertype) {
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
         return(ORDER_TYPE_SELL);
         break;
      case ORDER_TYPE_BUY:
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
