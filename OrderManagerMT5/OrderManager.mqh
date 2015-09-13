//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "Order.mqh"

class COrderManager : public COrderManagerBase
{
   string ticket_prefix;
   string stoploss_comment;
   string takeprofit_comment;
   string mtp_comment;

protected:
   CEventHandlerBase* event;

public:
   COrderArray orders;
   COrderArray historyorders;

   COrder* selectedorder;
   COrderInfoBase* orderinfo;

   bool selectedishistory;

   // Custom Order Defaults
   bool custom_order_defaults;
   CTrade* trade;
   int magic;
   
   int retrainhistory;
   
   COrderManager()
   {
     use_ontick = true;
   
     event = this.app.GetService(srvEvent);

     custom_order_defaults = false;

     ticket_prefix = "ticket=";
     stoploss_comment = "stoploss"; //TODO: Remove
     takeprofit_comment = "takeprofit";
     mtp_comment = "mtp";
     retrainhistory = 2592000;
   };

   virtual COrderBaseBase* NewOrderObject() { return(new COrder()); }
   virtual COrderBaseBase* NewAttachedOrderObject() { return(new CAttachedOrder()); }

   COrder* NewOrder(string in_symbol,ENUM_ORDER_TYPE _ordertype,double _volume,double _price,double _stoploss,double _takeprofit,string _comment="",datetime _expiration=0);
   COrder* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,double volume,CEntry* _price,
                                    CStopLoss* _stoploss,CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0);
   COrder* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagement* _mm,CEntry* _price,
                                    CStopLoss* _stoploss,CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0);
   virtual void OnTick();
   void UpdateState();
   void CleanUp();
   void CleanUpUntil(int idx);
   void RemoveOrder(ulong ticket);
   int GetIdxByTicket(ulong ticket);
   int GetIdxByTicketHistory(ulong ticket);
   bool CloseOrderByIdx(int idx, double closevolume = 0);
   bool CloseOrderByTicket(ulong ticket, double closevolume = 0);
   bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   int CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   bool CancelOrderByIdx(int idx);
   bool CancelOrderByTicket(ulong ticket);
   int OrdersTotal() { return(orders.Total()); }
   int HistoryOrdersTotal() { return(historyorders.Total()); }
   int OrdersHistoryTotal() { return(this.HistoryOrdersTotal()); }
   ENUM_ORDER_TYPE OrderType() { return((ENUM_ORDER_TYPE)((selectedorder==NULL)?-1:selectedorder.ordertype)); }
   string OrderSymbol() { return((selectedorder==NULL)?"":selectedorder.symbol); }
   int OrderMagicNumber() { return((selectedorder==NULL)?(-1):selectedorder.magic); }
   double OrderTakeProfit() { return((selectedorder==NULL)?0:selectedorder.GetTakeProfit()); }
   double OrderStopLoss() { return((selectedorder==NULL)?0:selectedorder.GetStopLoss()); }
   datetime OrderCloseTime() { return((selectedorder==NULL)?0:selectedorder.closetime); }
   double OrderClosePrice();
   datetime OrderOpenTime() { return((selectedorder==NULL)?0:selectedorder.filltime); }
   string OrderComment() { return((selectedorder==NULL)?"":selectedorder.comment); }
   ENUM_ORDER_STATE OrderState() { return((selectedorder==NULL)?ORDER_STATE_REJECTED:selectedorder.state); }
   COrder *GetOrderByIdx(int idx) { return(orders.Order(idx)); }
   COrder *GetHistoryOrderByIdx(int idx) { return(historyorders.Order(idx)); }
   bool GetOrderByIdx(int idx, COrder*& order) { order = orders.Order(idx); return(order != NULL); }
   bool SelectOrderByIdx(int idx);  
   bool SelectHistoryOrderByIdx(int idx);
   bool SelectOrderInfo();
   bool SelectOrderByTicket(uint ticket);
   COrder* GetOrderByTicket(ulong ticket);
   bool SelectHistoryOrderByTicket(uint ticket);
   
   ~COrderManager()
   {
   
   };
};

COrder* COrderManager::NewOrder(string in_symbol,ENUM_ORDER_TYPE _ordertype,double _volume,double _price,double _stoploss,double _takeprofit,string _comment="",datetime _expiration=0)
{

   COrder* _order = NewOrderObject();
   
   if (custom_order_defaults) {
      _order.magic = this.magic;
      if (isset(this.trade)) {
         _order.trade = trade;
      }
   }

   _order.NewOrder(
      in_symbol,
 _ordertype,
 _volume,
      _price,
      _stoploss,
      _takeprofit,
      _comment,
 _expiration
   );
   
   orders.Add(_order);
   return(_order);
}

COrder* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,double _volume,CEntry* _price,
                                 CStopLoss* _stoploss,CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0)
{
   COrder* _order = NewOrderObject();
   
   if (custom_order_defaults) {
      _order.magic = this.magic;
      if (isset(trade)) _order.trade = trade;
   }

   if (_price == NULL) _price = new CEntryPrice(0);
   if (_stoploss == NULL) _stoploss = new CStopLossPrice(0);
   if (_takeprofit == NULL) _takeprofit = new CTakeProfitPrice(0);
   
   _price.SetOrderType(_ordertype).SetSymbol(in_symbol);
   _stoploss.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.GetPrice());
   _takeprofit.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.GetPrice());

   _order.NewOrder(
      in_symbol,_ordertype,_volume,
      _price.GetPrice(),
      _stoploss.GetPrice(),
      _takeprofit.GetPrice(),
      _comment,_expiration
   );
   
   COrderBase::DeleteIf(_price);
   COrderBase::DeleteIf(_stoploss);
   COrderBase::DeleteIf(_takeprofit);
      
   orders.Add(_order); 

   return(_order);

}

COrder* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagement* _mm,CEntry* _price,
                                 CStopLoss* _stoploss,CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0)
{
   COrder* _order = NewOrderObject();
   
   if (custom_order_defaults) {
      _order.magic = this.magic;
      if (isset(trade)) _order.trade = trade;
   }

   if (_price == NULL) _price = new CEntryPrice(0);
   if (_stoploss == NULL) _stoploss = new CStopLossPrice(0);
   if (_takeprofit == NULL) _takeprofit = new CTakeProfitPrice(0);
   
   _price.SetOrderType(_ordertype).SetSymbol(in_symbol);
   _stoploss.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.GetPrice());
   _takeprofit.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.GetPrice());
   _mm.SetSymbol(in_symbol).SetStopLoss(_stoploss);

   _order.NewOrder(
      in_symbol,_ordertype,_mm.GetLotsize(),
      _price.GetPrice(),
      _stoploss.GetPrice(),
      _takeprofit.GetPrice(),
      _comment,_expiration
   );
   
   COrderBase::DeleteIf(_price);
   COrderBase::DeleteIf(_stoploss);
   COrderBase::DeleteIf(_takeprofit);
   COrderBase::DeleteIf(_mm);
      
   orders.Add(_order); 

   return(_order);

}

void COrderManager::OnTick()
{
   COrder* order;
   //addcomment("total:",(string)orders.Total());
   for (int i = 0; i < orders.Total(); i++) {
      order = orders.Order(i);
      if (!isset(order)) continue;
      //addcomment("main order ",(string)i," ticket=",(string)order.ticket," ",(string)order.placed," ",(string)order.executed," ",(string)order.canceled," ",(string)order.closed,"\n");
      order.OnTick();
      if (order.closed || order.executestate == ES_CANCELED) {
         
         if ((retrainhistory>1 || retrainhistory==0) && !order.do_not_archive) {
            historyorders.Add(orders.Detach(i));
            i--;
         } else if (retrainhistory == 1 && !order.do_not_delete && !order.do_not_archive) {
            orders.Delete(i);
            i--;
         }    
      
      }
   }
}

void COrderManager::UpdateState()
{
   COrder* _order;
   for (int i = 0; i < orders.Total(); i++) {
      if (!isset(orders.At(i))) {
         if (event.Warning ()) event.Warning("order object deleted at orders["+(string)i+"]",__FUNCTION__);
         continue;
      }
      _order = orders.At(i);
      if (_order.Select()) _order.State();
      for (int i1 = 0; i1 < _order.attachedorders.Total(); i1++) {
         CAttachedOrder* attachedorder = _order.attachedorders.AttachedOrder(i1);
         if (attachedorder.Select()) attachedorder.State();
      }
   }
}

void COrderManager::CleanUp()
{
   if (retrainhistory > 0) {
      for (int i = 0; i < historyorders.Total(); i++) {
         COrder* order = historyorders.Order(i);
         if (order.closetime < TimeCurrent()-retrainhistory) {
            historyorders.Delete(i);            
         }
      }
   }
}

void COrderManager::CleanUpUntil(int idx)
{
   if (retrainhistory > 0) {
      for (int i = 0; i < historyorders.Total() && i <= idx; i++) {
         historyorders.Delete(i);            
      }
   }
}

void COrderManager::RemoveOrder(ulong ticket)
{
   int idx = GetIdxByTicketHistory(ticket);
   if (idx >= 0) historyorders.Delete(idx);
}

int COrderManager::GetIdxByTicket(ulong ticket)
{
   COrder* order;
   for (int i = 0; i < orders.Total(); i++) {
      order = orders.Order(i);
      if (order.ticket == ticket) return(i);
   }
   return(-1);
}

int COrderManager::GetIdxByTicketHistory(ulong ticket)
{
   COrder* order;
   for (int i = 0; i < historyorders.Total(); i++) {
      order = historyorders.Order(i);
      if (order.ticket == ticket) return(i);
   }
   return(-1);
}

bool COrderManager::CloseOrderByIdx(int idx, double closevolume = 0)
{
   //if (event.Verbose ()) event.Verbose("call idx="+(string)idx+" closevolume="+(string)closevolume,__FUNCTION__);
   COrder* order;
   if (orders.At(idx) != NULL) {
      order = orders.Order(idx);
      if (order.Close(closevolume)) {
         event.Info("Order Closed",__FUNCTION__);
         return(true);
      } else {
         if (event.Warning ()) event.Warning("Close Failed",__FUNCTION__);
      }
   } else {
      if (event.Warning ()) event.Warning("order index not found",__FUNCTION__);
   }
   return(false);
}

bool COrderManager::CloseOrderByTicket(ulong ticket, double closevolume = 0)
{
   //if (event.Verbose ()) event.Verbose("call ticket: "+(string)ticket+" closevolume="+(string)closevolume,__FUNCTION__);
   int idx = GetIdxByTicket(ticket);
   if (idx < 0) {
      if (event.Warning ()) event.Warning("ticket not found",__FUNCTION__);
      return(false);
   }
   return(CloseOrderByIdx(idx,closevolume));
}

bool COrderManager::CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
{
   bool ret = false;
   COrder *order;
   for (int i = orders.Total()-1; i >= 0; i--) {
      order = orders.Order(i);
      //order.Update();
      if (order != NULL) {
         if (in_symbol != "" && order.symbol != in_symbol) { continue; }
         if (in_magic != -1 && order.magic != in_magic) { continue; }
         if (!ordertype_select(orderselect,order.ordertype)) { continue; }
         if (!state_select(stateselect,order.state)) { continue; }
         if (state_filled(order.state)) {
            order.Close();
            ret = true;
         }
         else if (state_undone(order.state)) {
            order.Cancel();
            ret = true;
         }
      }
   }
   return(ret);
}

int COrderManager::CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
{
   int cnt = 0;
   COrder *order;
   for (int i = orders.Total()-1; i >= 0; i--) {
      order = orders.Order(i);
      //order.Update();
      if (order != NULL) {
         if (in_symbol != "" && order.symbol != in_symbol) { continue; }
         if (in_magic != -1 && order.magic != in_magic) { continue; }
         if (!ordertype_select(orderselect,order.ordertype)) { continue; }
         if (!state_select(stateselect,order.state)) { continue; }
         cnt++;
      }
   }    
   return(cnt);
}

bool COrderManager::CancelOrderByIdx(int idx)
{
   COrder* order;
   if (orders.At(idx) != NULL) {
      order = orders.Order(idx);
      if (order.Cancel()) return(true);
      else {
         if (event.Warning ()) event.Warning("Cancel Order Failed idx="+(string)idx,__FUNCTION__);
      }
   } else {
      if (event.Warning ()) event.Warning("order index not found",__FUNCTION__);
   }
   return(false);
}

bool COrderManager::CancelOrderByTicket(ulong ticket)
{
   int idx = GetIdxByTicket(ticket);
   if (idx < 0) {
      if (event.Warning ()) event.Warning("ticket not found",__FUNCTION__);
      return(false);
   }
   return(CancelOrderByIdx(idx));
}
   

double COrderManager::OrderClosePrice()
{
   if (selectedorder==NULL) return(0);
   else {
      if (selectedorder.closed) return(selectedorder.lastcloseprice);
      else {
         if (state_filled(selectedorder.state)) {
            loadsymbol(selectedorder.symbol,__FUNCTION__);
            if (ordertype_long(selectedorder.ordertype)) {
               return(_symbol.Bid());
            }
            if (ordertype_short(selectedorder.ordertype)) {
               return(_symbol.Ask());
            }
            return(0);
         } else {
            return(0);
         }
      }
   }
}


bool COrderManager::SelectOrderByIdx(int idx)
{
   selectedorder = NULL;
   delete orderinfo;
   if (orders.At(idx) != NULL) {
      selectedorder = orders.Order(idx);
      SelectOrderInfo();         
      return(true);
   } else {
      return(false);
   }
}

bool COrderManager::SelectHistoryOrderByIdx(int idx)
{
   selectedorder = NULL;
   delete orderinfo;
   if (historyorders.At(idx) != NULL) {
      selectedorder = historyorders.Order(idx);
      if (selectedorder == NULL) {
         if (event.Warning ()) event.Warning("invalid selected order",__FUNCTION__);
         return(false);
      }
      SelectOrderInfo();
      /*
      //Print(selectedorder);
      orderinfo = selectedorder.GetOrderInfo();
      selectedishistory = selectedorder.selectedishistory;
      if (orderinfo == NULL) {
         if (event.Warning ()) event.Warning("No OrderInfo (history) idx:"+(string)idx,__FUNCTION__);
      }*/
      return(true);
   } else {
      //if (event.Verbose ()) event.Verbose("Failed to select history idx"+(string)idx,__FUNCTION__);
      return(false);
   }
}

bool COrderManager::SelectOrderInfo()
{
   if (selectedorder == NULL) {
      if (event.Warning ()) event.Warning("no selected order",__FUNCTION__);
      return(false);
   }      
   orderinfo = selectedorder.GetOrderInfo();
   selectedishistory = selectedorder.selectedishistory;
   if (orderinfo == NULL) {
      if (event.Warning ()) event.Warning("No OrderInfo (history)",__FUNCTION__);
   }
   return(true);
}

bool COrderManager::SelectOrderByTicket(uint ticket)
{
   int idx = GetIdxByTicket(ticket);
   if (idx >= 0) return(SelectOrderByIdx(idx));
   return(false);
}

COrder* COrderManager::GetOrderByTicket(ulong ticket)
{
   int idx = GetIdxByTicket(ticket);
   if (idx >= 0) return(GetOrderByIdx(idx));
   return(NULL);
}

bool COrderManager::SelectHistoryOrderByTicket(uint ticket)
{
   int idx = GetIdxByTicketHistory(ticket);
   if (idx >= 0) return(SelectHistoryOrderByIdx(idx));
   return(false);
}
