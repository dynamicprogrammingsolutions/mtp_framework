//+------------------------------------------------------------------+
//|                                                   mql4orders.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "..\ordermanager\OrderManager.mqh"

#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1

void ordersontick()
{
   om.OnTick();
}

bool OrderSelect(int idx, int select, int mode = MODE_TRADES)
{
   //Print("OrderSelect");
   if (select == SELECT_BY_POS) {
      if (mode == MODE_TRADES) {
         return(om.SelectOrderByIdx(idx));
      }
      if (mode == MODE_HISTORY) {
         return(om.SelectHistoryOrderByIdx(idx));         
      } 
   }
   if (select == SELECT_BY_TICKET) {
      if (mode == MODE_TRADES) {
         return(om.SelectOrderByTicket(idx));         
      }
      if (mode == MODE_HISTORY) {
         return(om.SelectHistoryOrderByTicket(idx));                  
      } 
   }
   return(false);
}

int OrdersTotalOM()
{
   //Print("OrdersTotalOM");
   return(om.OrdersTotal());
}


int OrdersHistoryTotal()
{
   //Print("HistoryOrdersTotalOM");
   return(om.HistoryOrdersTotal());
}

string OrderSymbol()
{
   return(om.OrderSymbol());
}

int OrderMagicNumber()
{
   return(om.OrderMagicNumber());
}

ENUM_ORDER_TYPE OrderType()
{
   if (om.selectedorder == NULL) return(-1);
   if (state_filled(om.OrderState())) {
      if (ordertype_pendinglong(om.selectedorder.ordertype)) return(ORDER_TYPE_BUY);
      if (ordertype_pendingshort(om.selectedorder.ordertype)) return(ORDER_TYPE_SELL);
   }
   return(om.selectedorder.ordertype);
}

double OrderOpenPrice()
{
   if (om.selectedorder == NULL) return(0);   
   return(om.selectedorder.Price());
}

double OrderLots()
{
   if (om.selectedorder == NULL) return(0);
   return(om.selectedorder.Lots());
}

ulong OrderTicket()
{
   if (om.selectedorder == NULL) return(0);
   return(om.selectedorder.ticket);
}

double OrderStopLoss()
{
   double _price = om.OrderStopLoss();
   return(_price);
}

double OrderTakeProfit()
{
   double _price = om.OrderTakeProfit();
   return(_price);
}

datetime OrderCloseTime()
{
   return(om.OrderCloseTime());
}

double OrderClosePrice()
{
   return(om.OrderClosePrice());
}

datetime OrderOpenTime()
{
   return(om.OrderOpenTime());
}

string OrderComment()
{
   return(om.OrderComment());
}

double OrderCommission()
{
   if (om.selectedorder==NULL) return(0);
   COrderInfoBase* orderinfo;
   if (om.selectedorder.GetOrderInfoB()) {
      orderinfo = om.selectedorder.orderinfo;
      CPositionInfo positioninfo;
      positioninfo.SelectByIndex((uint)orderinfo.PositionId());
      return(positioninfo.Commission());
   } else {
      return(0);
   }
}

double OrderSwap()
{
   if (om.selectedorder==NULL) return(0);
   COrderInfoBase* orderinfo;
   if (om.selectedorder.GetOrderInfoB()) {
      orderinfo = om.selectedorder.orderinfo;
      CPositionInfo positioninfo;
      positioninfo.SelectByIndex((uint)orderinfo.PositionId());
      return(positioninfo.Swap());
   } else {
      return(0);
   }
}

double OrderProfit()
{
   om.SelectOrderInfo();
   if (om.selectedorder == NULL) return(0);
   double openprice = om.selectedorder.Price();
   double closeprice = 0;
   loadsymbol(om.selectedorder.symbol,__FUNCTION__);
   if (!om.selectedorder.closed) {
      if (ordertype_long(om.selectedorder.ordertype)) closeprice = _symbol.Bid();
      if (ordertype_short(om.selectedorder.ordertype)) closeprice = _symbol.Ask();
   } else {
      closeprice = om.selectedorder.lastcloseprice;
   }
   if (closeprice > 0) {
      double move = closeprice-openprice;
      double profit = 0;
      if (ordertype_long(om.selectedorder.ordertype)) profit = _symbol.InTicks(move)*om.selectedorder.volume*_symbol.TickValue();
      return(profit);
   }
   return(0);
}

COrderBase* lastorder;
uint lastordererror;

long OrderSend(string symbol,ENUM_ORDER_TYPE cmd,double volume,double price,int slippage,double stoploss,double takeprofit,string comment="",int magic=0,datetime expiration=0,color cl=0)
{
   loadsymbol(symbol,__FUNCTION__);
   
   bool error = false;   

   if (stoploss > 0) {
      int slticks = getstoplossticks(symbol,cmd,stoploss,price);
      if (slticks < _symbol.StopsLevelInTicks()) {
         om.event.Error("Invalid Stoploss ("+(string)slticks+")",__FUNCTION__);
         lastordererror = OM_RETCODE_INVALID_STOPLOSS;
         error = true;
      }
   }
   
   if (takeprofit > 0) {   
      int tpticks = gettakeprofitticks(symbol,cmd,takeprofit,price);
      if (tpticks < _symbol.StopsLevelInTicks()) {
         om.event.Error("Invalid Takerpofit ("+(string)tpticks+")",__FUNCTION__);
         lastordererror = OM_RETCODE_INVALID_TAKEPROFIT;
         error = true;
      }
   }
         
   if (error) {
      om.event.Info("ordertype="+(string)cmd+" price="+(string)price+" stoploss="+(string)stoploss+" takeprofit="+(string)takeprofit);
      return(-1);
   }
   
   om.magic = magic;      
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
   //Print("OrderClose");
   return(om.CloseOrderByTicket(ticket, closevolume));
}

bool OrderDelete(ulong orderticket, color cl_unused = 0)
{
   return(om.CancelOrderByTicket(orderticket));
}

// ONLY FOR TRADES
bool OrderModify(ulong ticket, double price, double stoploss, double takeprofit, datetime expiration_unused = 0, color cl_unused = 0)
{
   int idx = om.GetIdxByTicket(ticket);
   if (idx < 0) return(false);
   COrder *order;
   CAttachedOrder *attachedorder;
   order = om.orders.Order(idx);
   
   if (order == NULL) {
      om.event.Info("order not found",__FUNCTION__);
      return(false);
   }
   
   if (state_canceled(order.state)) {
      return(false);
   }

   loadsymbol(order.symbol,__FUNCTION__);

   if (ordertype_market(order.ordertype)) {         
   
      bool error = false;   
   
      if (stoploss > 0) {
         int slticks = getstoplossticks(order.symbol,order.ordertype,stoploss,0);
         if (slticks < _symbol.StopsLevelInTicks()) {
            om.event.Error("Invalid Stoploss ("+(string)slticks+") "+"ticket="+(string)ticket+"ordertype="+(string)order.ordertype+" price="+(string)price+" stoploss="+(string)stoploss+" takeprofit="+(string)takeprofit,__FUNCTION__);
            error = true;
         }
      }
      
      if (takeprofit > 0) {   
         int tpticks = gettakeprofitticks(order.symbol,order.ordertype,takeprofit,0);
         if (tpticks < _symbol.StopsLevelInTicks()) {
            om.event.Error("Invalid Takerpofit ("+(string)tpticks+") "+"ticket="+(string)ticket+"ordertype="+(string)order.ordertype+" price="+(string)price+" stoploss="+(string)stoploss+" takeprofit="+(string)takeprofit,__FUNCTION__);
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
         om.event.Info("Modify EntryPrice of ticket:"+(string)ticket+" new price:"+(string)stoploss,__FUNCTION__);
         successprice = order.ModifyPrice(price);
      }
   }
   
   bool successstoploss = true;
   attachedorder = order.GetStopLossOrder();
   if (attachedorder != NULL) {
      if (attachedorder.Price() != stoploss) {
         om.event.Info("Modify StopLoss of ticket:"+(string)ticket+" new stoploss:"+(string)stoploss,__FUNCTION__);
         successstoploss = attachedorder.ModifyPrice(stoploss);
      }
   } else {
      om.event.Info("Add StopLoss to ticket "+(string)ticket+" new stoploss:"+(string)stoploss,__FUNCTION__);
      successstoploss = order.AddStopLoss(stoploss);
   }
   
   bool successtakeprofit = true;
   attachedorder = order.GetTakeProfitOrder();
   if (attachedorder != NULL) {
      if (attachedorder.Price() != takeprofit) {
         om.event.Info("Modify TakeProfit of ticket:"+(string)ticket+" new takeprofit:"+(string)takeprofit,__FUNCTION__);
         successtakeprofit = attachedorder.ModifyPrice(takeprofit);
      }
   } else {
      om.event.Info("Add TakeProfit to ticket "+(string)ticket+" new takeprofit:"+(string)takeprofit,__FUNCTION__);
      successtakeprofit = order.AddTakeProfit(takeprofit);
   }
   
   return(successprice && successstoploss && successtakeprofit);
}