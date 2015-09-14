//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                                              Revision 2010.02.08 |
//+------------------------------------------------------------------+
/*
#include <Object.mqh>
#include "..\SymbolInfoMT4\MTPSymbolInfo.mqh"
#include "MT4OrderInfo.mqh"
*/
//+------------------------------------------------------------------+
//| enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_LOG_LEVELS
  {
   LOG_LEVEL_NO    =0,
   LOG_LEVEL_ERRORS=1,
   LOG_LEVEL_ALL   =2
  };
  
enum ENUM_TRADE_ACTION
{
   TRADE_ACTION_PENDING,
   TRADE_ACTION_MARKET,
   TRADE_ACTION_MODIFY,
   TRADE_ACTION_CLOSE,
   TRADE_ACTION_CLOSEBY,
   TRADE_ACTION_DELETE
};
//+------------------------------------------------------------------+
//| Class CTrade.                                                    |
//| Appointment: Class trade operations.                             |
//|              Derives from class CObject.                         |
//+------------------------------------------------------------------+
class CTrade : public CObject
  {
public:
   virtual int Type() const { return classMT4Trade; }

  public:
   static int CTrade::SleepIfBusy;
   static int CTrade::SleepIfTooMuch;
   static int CTrade::SleepIfBrokerError;
   static int CTrade::SleepIfPriceError;
   
   static int CTrade::MaxRetryIfBusy;
   static int CTrade::MaxRetryIfTooMuch;
   static int CTrade::MaxRetryIfBrokerError;
   static int CTrade::MaxRetryIfPriceError;
   
   bool get_new_price_for_retry;

protected:
   ulong             m_magic;           // expert magic number
   ulong             m_deviation;       // deviation default
   ulong             m_deviation_close;       // deviation default
   ENUM_LOG_LEVELS   m_log_level;
   int m_ticket;
   int m_errcode;
   bool m_isecn;

public:
   color cl_buy;
   color cl_sell;

   color cl_pendingbuy;
   color cl_pendingsell;

   color cl_closebuy;
   color cl_closesell;   

   color cl_cancelbuy;
   color cl_cancelsell;   

                     CTrade();
   //--- methods of access to protected data
   void              LogLevel(ENUM_LOG_LEVELS log_level)     { m_log_level=log_level;               }

   //--- trade methods
   void              SetExpertMagicNumber(ulong magic)       { m_magic=magic;                       }
   void              SetDeviationInPoints(ulong deviation)   { m_deviation=deviation; m_deviation_close = deviation; }
   void              SetSlippage(ulong deviation)   { m_deviation=deviation; m_deviation_close = deviation; }
   void              SetSlippageOpen(ulong deviation)   { m_deviation=deviation; }
   void              SetSlippageClose(ulong deviation)   { m_deviation_close = deviation; }
   void              SetColors(color buycl, color sellcl)   { cl_buy = buycl; cl_pendingbuy = buycl; cl_closebuy = buycl; cl_cancelbuy = buycl;
      cl_sell = sellcl; cl_pendingsell = sellcl; cl_closesell = sellcl; cl_cancelsell = sellcl; }
   void              SetIsEcn(bool ecn) { m_isecn = ecn; }

   int ResultOrder() { return m_ticket; }
   int ResultRetcode() { return m_errcode; }

   //--- methods for working with pending orders
   bool              PositionOpen(const string symbol, const int order_type,const double volume, const double price, const double _sl = 0, const double _tp = 0, const string _comment = "");
   bool              OrderOpen(const string symbol, const int order_type, const double volume, double price = 0, const double _sl = 0, const double _tp = 0, const datetime expiration = 0,const string _comment = "");   
   bool              OrderModify(ulong ticket,double price,double _sl = 0,double _tp = 0, datetime expiration = 0, COrderInfo* orderinfo = NULL);   
   bool              OrderDelete(ulong ticket, COrderInfo* orderinfo = NULL);   
   bool              OrderClose(ulong ticket, double lots = 0, double price = 0, COrderInfo* orderinfo = NULL);
   int               OrderClosePartial(ulong ticket, double lots = 0, double price = 0, COrderInfo* orderinfo = NULL);
   int               CloseBy(ulong ticket1, ulong ticket2, COrderInfo* orderinfo = NULL);

   bool              CheckRetry(int errcode, ENUM_TRADE_ACTION action, int& retrycnt);

   color getcolor(int ordertype, bool _close = false) {
      if (_close) {
         switch (ordertype) {
            case OP_BUY: return(cl_buy);
            case OP_SELL: return(cl_sell);
            case OP_BUYSTOP:
            case OP_BUYLIMIT:
               return(cl_pendingbuy);
            case OP_SELLSTOP:
            case OP_SELLLIMIT:
               return(cl_pendingsell);
         }
      } else {
         switch (ordertype) {
            case OP_BUY: return(cl_closebuy);
            case OP_SELL: return(cl_closesell);
            case OP_BUYSTOP:
            case OP_BUYLIMIT:
               return(cl_cancelbuy);
            case OP_SELLSTOP:
            case OP_SELLLIMIT:
               return(cl_cancelsell);
         }           
      }
      return(clrNONE);
   }

protected:
   bool              IsStopped(string function);
  };
//+------------------------------------------------------------------+
//| Constructor CTrade.                                              |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTrade::CTrade()
  {
//--- initialize protected data   
   m_magic       =0;
   m_deviation   =10;
   m_isecn = true;
   m_ticket = -1;
   m_log_level   =LOG_LEVEL_ERRORS;
   m_errcode = 0;
//--- check programm mode
   if(IsOptimization()) m_log_level=LOG_LEVEL_NO;
   if(IsTesting())      m_log_level=LOG_LEVEL_ALL;
   
   cl_buy = Blue;
   cl_sell = Red;
   
   cl_pendingbuy = Blue;
   cl_pendingsell = Red;
   
   cl_closebuy = Blue;
   cl_closesell = Red;   
   
   cl_cancelbuy = Blue;
   cl_cancelsell = Red; 
   
   if (IsTesting()) {
      
      SleepIfBusy = 0;
      SleepIfBrokerError = 0;
      SleepIfPriceError = 0;
      SleepIfTooMuch = 0;
      
      MaxRetryIfBrokerError = 0;
      MaxRetryIfBusy = 0;
      MaxRetryIfPriceError = 0;
      MaxRetryIfTooMuch = 0;
      
   }
     
   
  }

//+------------------------------------------------------------------+
//| Installation pending order.                                      |
//| INPUT:  symbol     -symbol for trade,                            |
//|         order_type -type of order,                               |
//|         volume     -volume of order,                             |
//|         limit_price-limit price for activate order,              |
//|         price      -price for open,                              |
//|         _sl         -price of stop loss,                          |
//|         _tp         -price of take profit,                        |
//|         type_time  -type expiration,                             |
//|         expiration -time expiration,                             |
//|         _comment    -_comment of order.                            |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrade::OrderOpen(const string in_symbol, const int order_type, const double volume, const double price = 0, const double _sl = 0, const double _tp = 0, const datetime expiration = 0,const string _comment = "")
  {
//--- check stopped
   if(IsStopped(__FUNCTION__)) return(false);
   
   if(order_type==ORDER_TYPE_BUY && order_type==ORDER_TYPE_SELL)
   {
      if(m_log_level>LOG_LEVEL_NO) Print("Order Open Failed (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",_comment,") Error: Invalid Order Type");
      return(false);
   }
   
   int retrycnt = 0;
   while (true) {
   
      m_ticket = -1;   
      int res;
      res = OrderSend(in_symbol,(int)order_type,volume,price,m_deviation,_sl,_tp,_comment,m_magic,expiration,getcolor(order_type));
      if (res >= 0)
      {   
         m_ticket = res;
         if(m_log_level>LOG_LEVEL_ERRORS) Print("Order Opened: (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",TimeToStr(expiration),",",_comment,")");
         return(true);
      }
      else
      {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order Open Failed (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",TimeToStr(expiration),",",_comment,") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_PENDING,retrycnt)) continue;
         return(false);      
      }
  }
  return(false);
}

bool CTrade::PositionOpen(const string in_symbol, const int order_type, const double volume,
                          double price, const double _sl = 0, const double _tp = 0, const string _comment = "")
  {
   if(IsStopped(__FUNCTION__)) return(false);
   
   if(order_type!=ORDER_TYPE_BUY && order_type!=ORDER_TYPE_SELL)
   {
      if(m_log_level>LOG_LEVEL_NO) Print("Order Open Failed (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",_comment,") Error: Invalid Order Type");
      return(false);
   }

   int retrycnt = 0;
   while (true) {
   
      if(price==0.0)
      {
         CSymbolInfo sym;   
         sym.Name((in_symbol==NULL)?Symbol():in_symbol);
         sym.RefreshRates();
         if (order_type == ORDER_TYPE_BUY)
            price=sym.Ask();
         else
            price=sym.Bid();
      }
      
      m_ticket = -1;
      
      bool twosteps = (m_isecn && (_sl > 0 || _tp > 0));
      
      int res;
      if (!twosteps) {
         res = OrderSend(in_symbol,order_type,volume,price,m_deviation,_sl,_tp,_comment,m_magic,0,getcolor(order_type));
      } else {
         res = OrderSend(in_symbol,order_type,volume,price,m_deviation,0,0,_comment,m_magic,0,getcolor(order_type));
      }
      if (res >= 0)
      {   
         m_ticket = res;
         if(m_log_level>LOG_LEVEL_ERRORS) Print("Order Opened: (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",_comment,")");
         if (!twosteps) {
            return(true);
         } else {
            if (!this.OrderModify(m_ticket,0,_sl,_tp,0)) {
               if(m_log_level>LOG_LEVEL_ERRORS) Print("Placing SL/TP Failed (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",_comment,")");
               this.OrderClose(m_ticket);
               return(false);
            } else {
               return(true);
            }
         }
      }
      else
      {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order Open Failed (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",_comment,") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_PENDING,retrycnt)) { if (get_new_price_for_retry) price=0; continue; }
         return(false);      
      }
   }
   return(false);
}
//+------------------------------------------------------------------+
//| Modify specified pending order.                                  |
//| INPUT:  ticket     -ticket for modify,                           |
//|         price      -new price for open,                          |
//|         _sl         -new price of stop loss,                      |
//|         _tp         -new price of take profit,                    |
//|         type_time  -new type expiration,                         |
//|         expiration -new time expiration.                         |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrade::OrderModify(ulong ticket,double price,double _sl = 0,double _tp = 0, datetime expiration = 0, COrderInfo* orderinfo = NULL)
{
//--- check stopped
   if(IsStopped(__FUNCTION__)) return(false);

   COrderInfo o;
   if (orderinfo == NULL) orderinfo = GetPointer(o);

   if (!orderinfo.Select(ticket)) {
      if(m_log_level>LOG_LEVEL_ERRORS) Print("Order Modify Failed (",ticket,",",price,",",_sl,",",_tp,",",TimeToStr(expiration),") Error: Order Select Failed");
      return(false);
   }

   if(price==0.0) {      
      price = orderinfo.GetOpenPrice();
   }
   
   m_ticket = ticket;

   int retrycnt = 0;
   while (true) {
      
      if (OrderModify(ticket,price,_sl,_tp,expiration,getcolor(orderinfo.GetType())))
      {   
         if(m_log_level>LOG_LEVEL_ERRORS) Print("Order Modified: (",ticket,",",price,",",_sl,",",_tp,",",TimeToStr(expiration),")");
         return(true);      
      }
      else
      {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order Modify Failed (",ticket,",",price,",",_sl,",",_tp,",",TimeToStr(expiration),") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_MODIFY,retrycnt)) continue;
         return(false);
      }
   }
   return(false);
   
}
//+------------------------------------------------------------------+
//| Delete specified pending order.                                  |
//| INPUT:  ticket - ticket of order for delete.                     |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrade::OrderDelete(ulong ticket, COrderInfo* orderinfo = NULL)
  {
//--- check stopped
   if(IsStopped(__FUNCTION__)) return(false);
   
   COrderInfo o;
   if (orderinfo == NULL) {
      orderinfo = GetPointer(o);
      if (!orderinfo.Select(ticket)) {
         if(m_log_level>LOG_LEVEL_ERRORS) Print("Order Delete Failed (",ticket,") Error: Order Select Failed");
         return(false);
      }
   }
   
   m_ticket = ticket;

   int retrycnt = 0;
   while (true) {

      if (OrderDelete(ticket,getcolor(orderinfo.GetType(),true))) {
         if(m_log_level>LOG_LEVEL_ERRORS)
            Print("Order Deleted: (",ticket,")");
         return(true);   
      } else {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order Delete Failed (",ticket,") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_DELETE,retrycnt)) continue;
         return(false);
      }
   }
   return(false);
  }
  
bool CTrade::OrderClose(ulong ticket, double lots = 0, double price = 0, COrderInfo* orderinfo = NULL)
{
//--- check stopped
   if(IsStopped(__FUNCTION__)) return(false);
   
   COrderInfo o;
   if (CheckPointer(orderinfo) == POINTER_INVALID) {
      orderinfo = GetPointer(o);
      if (!orderinfo.Select(ticket)) {
         if(m_log_level>LOG_LEVEL_NO) Print("Order Close Failed (",ticket,",",lots,",",price,") Error: Invalid Ticket");
         return(false);
      }    
   } 
   
   if (lots == 0.0) {
      lots = orderinfo.GetLots();
   }

   int retrycnt = 0;
   while (true) {
      
      if(price==0.0)
      {
         CSymbolInfo sym;
         if (!sym.Name(orderinfo.GetSymbol())) {
            if(m_log_level>LOG_LEVEL_NO) Print("Order Close Failed (",ticket,",",lots,",",price,") Error: Symbol Select Failed");
            return(false);
         }
         sym.RefreshRates();
         if (orderinfo.GetType() == OP_BUY)
            price=sym.Bid();
         else if (orderinfo.GetType() == OP_SELL)
            price=sym.Ask();
      }
      
      m_ticket = ticket;
   
      if (OrderClose(ticket,lots,price,m_deviation_close,getcolor(orderinfo.GetType(),true))) {
         if(m_log_level>LOG_LEVEL_ERRORS)
            Print("Order Closed: (",ticket,",",lots,",",price,")");
         return(true);   
      } else {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order Close Failed (",ticket,",",lots,",",price,") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_DELETE,retrycnt)) { price = 0; continue; }
         return(false);
      }
   }
   return(false);
}

int CTrade::OrderClosePartial(ulong ticket, double lots = 0, double price = 0, COrderInfo* orderinfo = NULL)
{
//--- check stopped
   if(IsStopped(__FUNCTION__)) return(false);
   
   COrderInfo o;
   if (CheckPointer(orderinfo) == POINTER_INVALID) {
      orderinfo = GetPointer(o);
      if (!orderinfo.Select(ticket)) {
         if(m_log_level>LOG_LEVEL_NO) Print("Order Close Failed (",ticket,",",lots,",",price,") Error: Invalid Ticket");
         return(false);
      }    
   } 
   
   if (lots == 0.0) {
      lots = orderinfo.GetLots();
   }

   int retrycnt = 0;
   while (true) {
      
      if(price==0.0)
      {
         CSymbolInfo sym;
         if (!sym.Name(orderinfo.GetSymbol())) {
            if(m_log_level>LOG_LEVEL_NO) Print("Order Close Failed (",ticket,",",lots,",",price,") Error: Symbol Select Failed");
            return(false);
         }
         sym.RefreshRates();
         if (orderinfo.GetType() == OP_BUY)
            price=sym.Bid();
         else if (orderinfo.GetType() == OP_SELL)
            price=sym.Ask();
      }
      
      m_ticket = ticket;
   
      if (OrderClose(ticket,lots,price,m_deviation,getcolor(orderinfo.GetType(),true))) {
         if(m_log_level>LOG_LEVEL_ERRORS)
            Print("Order Closed: (",ticket,",",lots,",",price,")");
         return(true);   
      } else {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order Close Failed (",ticket,",",lots,",",price,") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_DELETE,retrycnt)) { price = 0; continue; }
         return(false);
      }
   }
   return(false);
}

int CTrade::CloseBy(ulong ticket1, ulong ticket2, COrderInfo* orderinfo = NULL)
{
//--- check stopped
   if(IsStopped(__FUNCTION__)) return(false);
   
   COrderInfo o;
   if (orderinfo == NULL) {
      orderinfo = GetPointer(o);
      if (!orderinfo.Select(ticket1)) {
         if(m_log_level>LOG_LEVEL_NO) Print("Order CloseBy Failed (",ticket1,",",ticket2,") Error: Orderinfo Select Failed");
         return(-1);
      }
   }

   datetime orderopentime = orderinfo.GetOpenTime();
   double orderopenprice = orderinfo.GetOpenPrice();  
   string ordersymbol = orderinfo.GetSymbol();
   
   int retrycnt = 0;
   while (true) {
      
      if (OrderCloseBy(ticket1,ticket2,getcolor(orderinfo.GetType(),true))) {
         if(m_log_level>LOG_LEVEL_ERRORS) Print("Order CloseBy Succeed, finding new ticket");
         for (int i = OrdersTotal()-1; i >= 0; i--) {
            if (orderinfo.SelectByIndex(i,MODE_TRADES)) {
               if (orderinfo.GetSymbol() == ordersymbol && orderinfo.GetOpenTime() == orderopentime && orderinfo.GetOpenPrice() == orderopenprice) {
                  if(m_log_level>LOG_LEVEL_ERRORS) Print("New ticket found:",orderinfo.Ticket());
                  return(orderinfo.Ticket());
               }
            }         
         }
         if(m_log_level>LOG_LEVEL_NO) Print("New ticket not found :(");
         return(-1);
      } else {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order CloseBy Failed (",ticket1,",",ticket2,") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_CLOSEBY,retrycnt)) { continue; }
         return(-1);
      }
   }
   return(-1);
}

//+------------------------------------------------------------------+
//| Checks forced shutdown of MQL5-program.                          |
//| INPUT:  function - name of the caller.                           |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrade::IsStopped(string function)
  {
   if(!IsStopped()) return(false);
//--- MQL5 program is stopped
   printf("%s: MQL5 program is stopped. Trading is disabled",function);
   return(true);
  }
  
int CTrade::SleepIfBusy = 500;
int CTrade::SleepIfTooMuch = 2000;
int CTrade::SleepIfBrokerError = 0;
int CTrade::SleepIfPriceError = 0;

int CTrade::MaxRetryIfBusy = 19;
int CTrade::MaxRetryIfTooMuch = 4;
int CTrade::MaxRetryIfBrokerError = 2;
int CTrade::MaxRetryIfPriceError = 2;
  
bool CTrade::CheckRetry(int errcode, ENUM_TRADE_ACTION action, int& retrycnt)
{
   //Print("checkretry "+retrycnt);
   int sleep = 0;
   int maxretry = 0;
   retrycnt++;
   switch (errcode) {
      // temporary problem (something is busy)
      case ERR_SERVER_BUSY:
      case ERR_NO_CONNECTION:
      case ERR_TRADE_CONTEXT_BUSY:
      case ERR_BROKER_BUSY:
         sleep = CTrade::SleepIfBusy;
         maxretry = CTrade::MaxRetryIfBusy;
         break;

      case ERR_TOO_FREQUENT_REQUESTS:
      case ERR_TOO_MANY_REQUESTS:
         sleep = CTrade::SleepIfTooMuch;
         maxretry = CTrade::MaxRetryIfTooMuch;
         break;
      
      case ERR_TRADE_TIMEOUT:
      case ERR_TRADE_MODIFY_DENIED:
         sleep = CTrade::SleepIfBrokerError;
         maxretry = CTrade::MaxRetryIfBrokerError;
         break;
      
      // retry with no sleep
      case ERR_INVALID_PRICE:
         switch (action) { case TRADE_ACTION_PENDING: case TRADE_ACTION_MODIFY: return(false); }
         
      case ERR_OFF_QUOTES:
      case ERR_PRICE_CHANGED:
      case ERR_REQUOTE:
         sleep = CTrade::SleepIfPriceError;
         maxretry = CTrade::MaxRetryIfPriceError;
         break;

      default:
         return(false);
   }
   
   //Print(maxretry," ",retrycnt);
   if (maxretry >= retrycnt) {
      if (sleep > 0) Sleep(sleep);
      if (m_log_level>LOG_LEVEL_ERRORS) Print("Retrying (",retrycnt+1,"/",maxretry+1,")");
      return(true);
   } else return(false);
}
  
  
string ErrorDescription(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- codes returned from trade server
      case 0:
      case 1:   error_string="no error";                                                  break;
      case 2:   error_string="common error";                                              break;
      case 3:   error_string="invalid trade parameters";                                  break;
      case 4:   error_string="trade server is busy";                                      break;
      case 5:   error_string="old version of the client terminal";                        break;
      case 6:   error_string="no connection with trade server";                           break;
      case 7:   error_string="not enough rights";                                         break;
      case 8:   error_string="too frequent requests";                                     break;
      case 9:   error_string="malfunctional trade operation (never returned error)";      break;
      case 64:  error_string="account disabled";                                          break;
      case 65:  error_string="invalid account";                                           break;
      case 128: error_string="trade timeout";                                             break;
      case 129: error_string="invalid price";                                             break;
      case 130: error_string="invalid stops";                                             break;
      case 131: error_string="invalid trade volume";                                      break;
      case 132: error_string="market is closed";                                          break;
      case 133: error_string="trade is disabled";                                         break;
      case 134: error_string="not enough money";                                          break;
      case 135: error_string="price changed";                                             break;
      case 136: error_string="off quotes";                                                break;
      case 137: error_string="broker is busy (never returned error)";                     break;
      case 138: error_string="requote";                                                   break;
      case 139: error_string="order is locked";                                           break;
      case 140: error_string="long positions only allowed";                               break;
      case 141: error_string="too many requests";                                         break;
      case 145: error_string="modification denied because order too close to market";     break;
      case 146: error_string="trade context is busy";                                     break;
      case 147: error_string="expirations are denied by broker";                          break;
      case 148: error_string="amount of open and pending orders has reached the limit";   break;
      case 149: error_string="hedging is prohibited";                                     break;
      case 150: error_string="prohibited by FIFO rules";                                  break;
      //---- mql4 errors
      case 4000: error_string="no error (never generated code)";                          break;
      case 4001: error_string="wrong function pointer";                                   break;
      case 4002: error_string="array index is out of range";                              break;
      case 4003: error_string="no memory for function call stack";                        break;
      case 4004: error_string="recursive stack overflow";                                 break;
      case 4005: error_string="not enough stack for parameter";                           break;
      case 4006: error_string="no memory for parameter string";                           break;
      case 4007: error_string="no memory for temp string";                                break;
      case 4008: error_string="not initialized string";                                   break;
      case 4009: error_string="not initialized string in array";                          break;
      case 4010: error_string="no memory for array\' string";                             break;
      case 4011: error_string="too long string";                                          break;
      case 4012: error_string="remainder from zero divide";                               break;
      case 4013: error_string="zero divide";                                              break;
      case 4014: error_string="unknown command";                                          break;
      case 4015: error_string="wrong jump (never generated error)";                       break;
      case 4016: error_string="not initialized array";                                    break;
      case 4017: error_string="dll calls are not allowed";                                break;
      case 4018: error_string="cannot load library";                                      break;
      case 4019: error_string="cannot call function";                                     break;
      case 4020: error_string="expert function calls are not allowed";                    break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)";                   break;
      case 4050: error_string="invalid function parameters count";                        break;
      case 4051: error_string="invalid function parameter value";                         break;
      case 4052: error_string="string function internal error";                           break;
      case 4053: error_string="some array error";                                         break;
      case 4054: error_string="incorrect series array using";                             break;
      case 4055: error_string="custom indicator error";                                   break;
      case 4056: error_string="arrays are incompatible";                                  break;
      case 4057: error_string="global variables processing error";                        break;
      case 4058: error_string="global variable not found";                                break;
      case 4059: error_string="function is not allowed in testing mode";                  break;
      case 4060: error_string="function is not confirmed";                                break;
      case 4061: error_string="send mail error";                                          break;
      case 4062: error_string="string parameter expected";                                break;
      case 4063: error_string="integer parameter expected";                               break;
      case 4064: error_string="double parameter expected";                                break;
      case 4065: error_string="array as parameter expected";                              break;
      case 4066: error_string="requested history data in update state";                   break;
      case 4099: error_string="end of file";                                              break;
      case 4100: error_string="some file error";                                          break;
      case 4101: error_string="wrong file name";                                          break;
      case 4102: error_string="too many opened files";                                    break;
      case 4103: error_string="cannot open file";                                         break;
      case 4104: error_string="incompatible access to a file";                            break;
      case 4105: error_string="no order selected";                                        break;
      case 4106: error_string="unknown symbol";                                           break;
      case 4107: error_string="invalid price parameter for trade function";               break;
      case 4108: error_string="invalid ticket";                                           break;
      case 4109: error_string="trade is not allowed in the expert properties";            break;
      case 4110: error_string="longs are not allowed in the expert properties";           break;
      case 4111: error_string="shorts are not allowed in the expert properties";          break;
      case 4200: error_string="object is already exist";                                  break;
      case 4201: error_string="unknown object property";                                  break;
      case 4202: error_string="object is not exist";                                      break;
      case 4203: error_string="unknown object type";                                      break;
      case 4204: error_string="no object name";                                           break;
      case 4205: error_string="object coordinates error";                                 break;
      case 4206: error_string="no specified subwindow";                                   break;
      default:   error_string="unknown error";
     }
//----
   return(error_string);
  }