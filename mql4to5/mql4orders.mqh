//+------------------------------------------------------------------+
//|                                                   mql4orders.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "..\OrderManager\Loader.mqh"

COrderManagerInterface* om;
COrderRepositoryInterface* or;

#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1

#define OM_RETCODE_INVALID_STOPLOSS 10101
#define OM_RETCODE_INVALID_TAKEPROFIT 10101

void ordersontick()
{
   om.OnTick();
}

bool OrderSelect(int idx, int select, int mode = MODE_TRADES)
{
   //Print("OrderSelect");
   if (select == SELECT_BY_POS) {
      if (mode == MODE_TRADES) {
         return(or.SelectOrderByIdx(idx));
      }
      if (mode == MODE_HISTORY) {
         return(or.SelectHistoryOrderByIdx(idx));         
      } 
   }
   if (select == SELECT_BY_TICKET) {
      if (mode == MODE_TRADES) {
         return(or.SelectOrderByTicket(idx));         
      }
      if (mode == MODE_HISTORY) {
         return(or.SelectHistoryOrderByTicket(idx));                  
      } 
   }
   return(false);
}

int OrdersTotalOM()
{
   //Print("OrdersTotalOM");
   return(or.Total());
}


int OrdersHistoryTotal()
{
   //Print("HistoryOrdersTotalOM");
   return(or.HistoryTotal());
}

string OrderSymbol()
{
   return(or.Selected().GetSymbol());
}

int OrderMagicNumber()
{
   return(or.Selected().GetMagicNumber());
}

ENUM_ORDER_TYPE OrderType()
{
   if (or.Selected() == NULL) return(-1);
   if (state_filled(or.Selected().State())) {
      if (ordertype_pendinglong(or.Selected().GetType())) return(ORDER_TYPE_BUY);
      if (ordertype_pendingshort(or.Selected().GetType())) return(ORDER_TYPE_SELL);
   }
   return(or.Selected().GetType());
}

double OrderOpenPrice()
{
   if (or.Selected() == NULL) return(0);   
   return(or.Selected().GetOpenPrice());
}

double OrderLots()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetLots());
}

ulong OrderTicket()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetTicket());
}

double OrderStopLoss()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetStopLoss());
}

double OrderTakeProfit()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetTakeProfit());
}

datetime OrderCloseTime()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetCloseTime());
}

double OrderClosePrice()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetClosePrice());
}

datetime OrderOpenTime()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetOpenTime());
}

string OrderComment()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetComment());
}

double OrderCommission()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetCommission());
}

double OrderSwap()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetSwap());
}

double OrderProfit()
{
   if (or.Selected() == NULL) return(0);
   return(or.Selected().GetProfitMoney());
}

COrderBase* lastorder;
uint lastordererror;

long OrderSend(string symbol,ENUM_ORDER_TYPE cmd,double volume,double price,int slippage,double stoploss,double takeprofit,string comment="",int magic=0,datetime expiration=0,color cl=0)
{
   CSymbolInfoInterface* _symbol;
   global_app().symbolloader.LoadSymbol(symbol,_symbol);
   
   CEventHandlerInterface* event = global_app().eventhandler;
   
   bool error = false;   

   if (stoploss > 0) {
      int slticks = getstoplossticks(symbol,cmd,stoploss,price);
      if (slticks < _symbol.StopsLevelInTicks()) {
         event.Error("Invalid Stoploss ("+(string)slticks+")",__FUNCTION__);
         lastordererror = OM_RETCODE_INVALID_STOPLOSS;
         error = true;
      }
   }
   
   if (takeprofit > 0) {   
      int tpticks = gettakeprofitticks(symbol,cmd,takeprofit,price);
      if (tpticks < _symbol.StopsLevelInTicks()) {
         event.Error("Invalid Takerpofit ("+(string)tpticks+")",__FUNCTION__);
         lastordererror = OM_RETCODE_INVALID_TAKEPROFIT;
         error = true;
      }
   }
         
   if (error) {
      event.Info("ordertype="+(string)cmd+" price="+(string)price+" stoploss="+(string)stoploss+" takeprofit="+(string)takeprofit);
      return(-1);
   }
   
   COrderBase::magic_default = magic;
   
   COrder* order;            
   order = om.NewOrder(symbol,cmd,volume,price,stoploss,takeprofit,comment,expiration);
   if (order != NULL) {
      lastorder = order;
      lastordererror = order.retcode;
      /*if (order.executestate != ES_EXECUTED) return(-1);
      else */return((long)order.ticket);
   } else {
      return(-1);
   }

   //return(om.OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,expiration));  
}

bool OrderClose(ulong ticket, double closevolume, double price_unused=0, double slippage_unused=0, color cl_unused=0)
{
   COrderInterface* order = or.GetByTicketOrder(ticket);
   if (order != NULL) {
      return order.Close(closevolume);
   } else return false;
}

bool OrderDelete(ulong orderticket, color cl_unused = 0)
{
   COrderInterface* order = or.GetByTicketOrder(orderticket);
   return(order.Cancel());
}

// ONLY FOR TRADES
bool OrderModify(ulong ticket, double price, double stoploss, double takeprofit, datetime expiration_unused = 0, color cl_unused = 0)
{

   CEventHandlerInterface* event = global_app().eventhandler;
   
   COrder *order;
   CAttachedOrder *attachedorder;

   order = or.GetByTicket(ticket);
   if (order == NULL) return false;
   
   if (order == NULL) {
      event.Info("order not found",__FUNCTION__);
      return(false);
   }
   
   if (state_canceled(order.state)) {
      return(false);
   }

   CSymbolInfoInterface* _symbol;
   global_app().symbolloader.LoadSymbol(order.GetSymbol(),_symbol);
   
   if (ordertype_market(order.ordertype)) {         
   
      bool error = false;   
   
      if (stoploss > 0) {
         int slticks = getstoplossticks(order.symbol,order.ordertype,stoploss,0);
         if (slticks < _symbol.StopsLevelInTicks()) {
            event.Error("Invalid Stoploss ("+(string)slticks+") "+"ticket="+(string)ticket+"ordertype="+(string)order.ordertype+" price="+(string)price+" stoploss="+(string)stoploss+" takeprofit="+(string)takeprofit,__FUNCTION__);
            error = true;
         }
      }
      
      if (takeprofit > 0) {   
         int tpticks = gettakeprofitticks(order.symbol,order.ordertype,takeprofit,0);
         if (tpticks < _symbol.StopsLevelInTicks()) {
            event.Error("Invalid Takerpofit ("+(string)tpticks+") "+"ticket="+(string)ticket+"ordertype="+(string)order.ordertype+" price="+(string)price+" stoploss="+(string)stoploss+" takeprofit="+(string)takeprofit,__FUNCTION__);
            error = true;
         }
      }
            
      if (error) {
         //event.Info("ticket="+(string)ticket+"ordertype="+(string)order.ordertype+" price="+(string)price+" stoploss="+(string)stoploss+" takeprofit="+(string)takeprofit);
         return(false);
      }
      
   }

   //TODO: Add Entry Price Check just like as TP and SL checked

   bool successprice = true;
   if (ordertype_pending(order.ordertype) && state_placed(order.state) && !state_canceled(order.state)) {
      if (order.Price() != price) {
         event.Info("Modify EntryPrice of ticket:"+(string)ticket+" new price:"+(string)stoploss,__FUNCTION__);
         successprice = order.ModifyPrice(price);
      }
   }
   
   bool successstoploss = true;
   attachedorder = order.GetStopLossOrder();
   if (attachedorder != NULL) {
      if (attachedorder.Price() != stoploss) {
         event.Info("Modify StopLoss of ticket:"+(string)ticket+" new stoploss:"+(string)stoploss,__FUNCTION__);
         successstoploss = attachedorder.ModifyPrice(stoploss);
      }
   } else {
      event.Info("Add StopLoss to ticket "+(string)ticket+" new stoploss:"+(string)stoploss,__FUNCTION__);
      successstoploss = order.AddStopLoss(stoploss);
   }
   
   bool successtakeprofit = true;
   attachedorder = order.GetTakeProfitOrder();
   if (attachedorder != NULL) {
      if (attachedorder.Price() != takeprofit) {
         event.Info("Modify TakeProfit of ticket:"+(string)ticket+" new takeprofit:"+(string)takeprofit,__FUNCTION__);
         successtakeprofit = attachedorder.ModifyPrice(takeprofit);
      }
   } else {
      event.Info("Add TakeProfit to ticket "+(string)ticket+" new takeprofit:"+(string)takeprofit,__FUNCTION__);
      successtakeprofit = order.AddTakeProfit(takeprofit);
   }
   
   return(successprice && successstoploss && successtakeprofit);
}