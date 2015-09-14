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

//TODO: VPrice, Attached Order Virtual Capability
//Trailing Stop On Virtual Order
//Compare to MT5 version and port the modifications that are applicable there
//If removed or MT4 closed: handle the attached orders: cannot have attached SL if have hard SL.

#include "Loader.mqh"

#include "..\libraries\file.mqh"
//#include "Order.mqh"

class COrderManager : public COrderManagerBase
{

private:

public:

   bool ontick_has_run;

   COrderArray orders;
   COrderArray historyorders;
   CAttachedOrderArray attachedorders;

   COrder* selectedorder;
   
   bool selectedishistory;
   
   int retrainhistory;
   
   bool move_to_history_on_update;
   
   // Custom Order Defaults
   bool custom_order_defaults;
   CTrade* trade;
   int magic;
   bool sl_virtual;
   bool tp_virtual;
   bool price_virtual;
      
   COrderManager()
   {
      trade = NULL;
      custom_order_defaults = false;
      retrainhistory = 2592000;
      move_to_history_on_update = false;
      sl_virtual = false;
      tp_virtual = false;
      price_virtual = false;
      ontick_has_run = true;
      use_ontick = true;
   };
   
   CApplication* app;
   
   void InitalizeService()
   {
      app = COrderManagerBase::app;
      event = app.GetService(srvEvent);
      symbolloader = app.GetService(srvSymbolLoader);   
   }
   
   CEventHandlerBase* event;
   CSymbolLoaderBase* symbolloader;
   CSymbolInfoBase* _symbol;
   
   void loadsymbol(string symbol)
   {
      _symbol = symbolloader.LoadSymbol(symbol);
   }
   
   void loadsymbol(string symbol, string function)
   {
      _symbol = symbolloader.LoadSymbol(symbol);
   }
   
      
   //COrder* NullOrder() { return(new COrder()); };

   virtual bool Save(const int handle);
   virtual bool Load(const int handle);

   virtual COrder* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
      const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);   
   virtual COrder* NewOrder(COrder* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                    const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);
   virtual COrder* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume, CEntry* _price,
                                    CStopLoss* _stoploss, CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0);

   virtual COrder* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagement* mm, CEntry* _price,
                                    CStopLoss* _stoploss, CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0);
  
   COrder* ExistingOrder(int ticket, bool add = true);
   
   void AssignAttachedOrders(bool remove_if_not_found = true);
   
   virtual void OnTick();   
   void UpdateAll();   
   void UpdateState();
   void MoveToHistoryAll();
   
   virtual void CleanUp(bool cleanall=false);   
   void CleanUpUntil(int idx);   
   void RemoveOrder(ulong ticket);
   
   int GetIdxByTicket(ulong ticket);   
   int GetIdxByTicketHistory(ulong ticket);
   bool CloseOrderByIdx(int idx, double closevolume = 0);
   bool CloseOrderByTicket(ulong ticket, double closevolume = 0);
   bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   int CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   bool CancelOrderByIdx(int idx) ;
   bool CancelOrderByTicket(ulong ticket);
   int OrdersTotal() { return(orders.Total()); }
   int HistoryOrdersTotal() { return(historyorders.Total()); }
   int OrdersHistoryTotal() { return(this.HistoryOrdersTotal()); }
   COrder *GetOrderByIdx(int idx) { return(orders.At(idx)); }
   COrder *GetHistoryOrderByIdx(int idx) { return(historyorders.At(idx)); }
   bool GetOrderByIdx(int idx, COrder*& in_order) { in_order = orders.At(idx); return(in_order != NULL); }
   bool SelectOrderByIdx(int idx) { return(isset(selectedorder = (COrder*)orders.At(idx))); }
   bool SelectHistoryOrderByIdx(int idx) { return(isset(selectedorder = (COrder*)historyorders.At(idx))); }   
   bool SelectOrderByTicket(uint ticket) { int idx; return(((idx = GetIdxByTicket(ticket)) >= 0)?SelectOrderByIdx(idx):false); }
   COrder* GetOrderByTicket(uint ticket) { int idx;  return(((idx = GetIdxByTicket(ticket)) >= 0)?GetOrderByIdx(idx):NULL); }
   COrder* GetByTicket(uint ticket) { int idx; return(((idx = GetIdxByTicket(ticket)) >= 0) ? GetOrderByIdx(idx) : ( ((idx = GetIdxByTicketHistory(ticket)) >= 0) ? GetHistoryOrderByIdx(idx) : ( NULL ) )); }
   COrder* GetById(int ticket);
   bool SelectHistoryOrderByTicket(uint ticket) { int idx; return(((idx = GetIdxByTicketHistory(ticket)) >= 0)?SelectHistoryOrderByIdx(idx):false); }
   
   double COrderManager::AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   double COrderManager::TotalLots(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   double COrderManager::TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   double COrderManager::TotalProfitMoney(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1, bool _commission = true, bool swap = true);
   
   virtual COrderBaseBase* NewOrderObject() { return app.orderfactory.Create(); }
   virtual COrderBaseBase* NewAttachedOrderObject() { return app.attachedorderfactory.Create(); }
   
   bool GetOrders(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1, bool no_loop_and_reset = false)
   {
      static int get_orders_i = -1;
      int total = this.OrdersTotal();
      Print(total);
      if (get_orders_i < 0) {
         get_orders_i = 0;
      }
      bool gotorder = false;
      for (; get_orders_i < total; get_orders_i++) {
         if (!this.SelectOrderByIdx(get_orders_i)) continue;
         if (!ordertype_select(type,selectedorder.GetType())) continue;
         if (!state_select(state,selectedorder.State())) continue;
         if (in_symbol != "" && selectedorder.GetSymbol() != in_symbol) continue;
         if (in_magic >= 0 && selectedorder.GetMagicNumber() != in_magic) continue;
         if (!no_loop_and_reset) {
            get_orders_i++;
            return true;
         } else {
            gotorder = true;
            break;
         }
      }
      get_orders_i = -1;
      return gotorder;
   }

};

//COrderManager* om;

   bool COrderManager::Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      Print(__FUNCTION__+" Start Saving pos: "+file.Tell());

      Print(__FUNCTION__+" Saving Orders pos: "+file.Tell());

      if (!file.WriteObject(GetPointer(orders))) return file.Error("orders",__FUNCTION__);

      Print(__FUNCTION__+" Saving History Orders pos: "+file.Tell());

      if (!file.WriteObject(GetPointer(historyorders))) return file.Error("historyorders",__FUNCTION__);

      Print(__FUNCTION__+" Saving Attached Orders pos: "+file.Tell());

      if (!file.WriteObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);         

      Print(__FUNCTION__+" End Saving pos: "+file.Tell());

      return(true);
   }
   
   bool COrderManager::Load(const int handle)
   {      
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;                 

      Print(__FUNCTION__+" Start Loading pos: "+file.Tell());

      Print(__FUNCTION__+" Loading Orders pos: "+file.Tell());

      if (!file.ReadObject(GetPointer(orders))) return file.Error("orders",__FUNCTION__);

      Print(__FUNCTION__+" Loading HistoryOrders pos: "+file.Tell());

      if (!file.ReadObject(GetPointer(historyorders))) return file.Error("historyorders",__FUNCTION__);

      Print(__FUNCTION__+" Loading AttachedOrders pos: "+file.Tell());

      if (!file.ReadObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);

      Print(__FUNCTION__+" End Loading pos: "+file.Tell());

      return(true);
   }

   COrder* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                    const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
   {
      COrder* _order = NewOrderObject();
      
      if (custom_order_defaults) {
         _order.sl_virtual = this.sl_virtual;
         _order.tp_virtual = this.tp_virtual;
         _order.price_virtual = this.price_virtual;
         _order.magic = this.magic;
         if (isset(trade)) _order.trade = trade;
      }

      _order.NewOrder(in_symbol,_ordertype,_volume,_price,_stoploss,_takeprofit,_comment,_expiration);
      orders.Add(_order);
      return(_order);
   }
   
   COrder* COrderManager::NewOrder(COrder* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                    const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
   {
      if (custom_order_defaults) {
         _order.sl_virtual = this.sl_virtual;
         _order.tp_virtual = this.tp_virtual;
         _order.price_virtual = this.price_virtual;
         _order.magic = this.magic;
         if (isset(trade)) _order.trade = trade;
      }

      _order.NewOrder(in_symbol,_ordertype,_volume,_price,_stoploss,_takeprofit,_comment,_expiration);
      orders.Add(_order);
      return(_order);
   }
   
   COrder* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,CEntry* _price,
                                    CStopLoss* _stoploss,CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0)
   {
      COrder* _order = NewOrderObject();
      
      if (custom_order_defaults) {
         _order.sl_virtual = this.sl_virtual;
         _order.tp_virtual = this.tp_virtual;
         _order.price_virtual = this.price_virtual;
         _order.magic = this.magic;
         if (isset(trade)) _order.trade = trade;
      }

      if (_price == NULL) _price = new CEntryPrice(0);
      if (_stoploss == NULL) _stoploss = new CStopLossPrice(0);
      if (_takeprofit == NULL) _takeprofit = new CTakeProfitPrice(0);

      _order.NewOrder(
         in_symbol,_ordertype,_volume,
         _price.SetOrderType(_ordertype).SetSymbol(in_symbol).GetPrice(),
         _stoploss.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.GetPrice()).GetPrice(),
         _takeprofit.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.GetPrice()).GetPrice(),
         _comment,_expiration);
         
      orders.Add(_order);
      
      COrderBase::DeleteIf(_price);
      COrderBase::DeleteIf(_stoploss);
      COrderBase::DeleteIf(_takeprofit);
      
      return(_order);
   }
   
   COrder* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagement* _mm,CEntry* _price,
                                    CStopLoss* _stoploss,CTakeProfit* _takeprofit,const string _comment="",const datetime _expiration=0)
   {
      COrder* _order = NewOrderObject();
      
      if (custom_order_defaults) {
         _order.sl_virtual = this.sl_virtual;
         _order.tp_virtual = this.tp_virtual;
         _order.price_virtual = this.price_virtual;
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
         _comment,_expiration);
         
      orders.Add(_order);

      COrderBase::DeleteIf(_price);
      COrderBase::DeleteIf(_stoploss);
      COrderBase::DeleteIf(_takeprofit);
      COrderBase::DeleteIf(_mm);

      return(_order);
   }
   
   COrder* COrderManager::ExistingOrder(int ticket, bool add = true)
   {
      COrderBase* _order = new COrderBase();

      if (custom_order_defaults) {
         _order.sl_virtual = this.sl_virtual;
         _order.tp_virtual = this.tp_virtual;
         _order.price_virtual = this.price_virtual;
         _order.magic = this.magic;
         if (isset(trade)) _order.trade = trade;
      }
            
      COrder* mainorder = NewOrderObject();
      CAttachedOrder* attachedorder = NewAttachedOrderObject();
      
      if (!COrder::ExistingOrder(ticket,_order,mainorder,attachedorder)) {
         delete _order;
         return(NULL);
      }
      delete _order;
      if (CheckPointer(attachedorder) != POINTER_INVALID) {
         attachedorders.Add(attachedorder);
         return(NULL);
      } else if (CheckPointer(mainorder) != POINTER_INVALID) {
         bool found = false;
         COrder* order1;
         for (int i = orders.Total()-1; i >= 0; i--) {
            order1 = (COrder*)orders.At(i);
            if (order1.ticket == mainorder.ticket) {
               found = true;
               break;
            }
         }
         if (!found) {
            orders.Add(mainorder);
            return(mainorder);
         } else {
            delete mainorder;
            return(NULL);
         }
      } else {
         return(NULL);
      }
      
   }
   
   void COrderManager::AssignAttachedOrders(bool remove_if_not_found = true)
   {
      CAttachedOrder* attachedorder;
      CAttachedOrder* attachedorder1;
      COrder* _order;
      int i;
      for (i = attachedorders.Total()-1; i >= 0; i--) {
         attachedorder = (CAttachedOrder*)attachedorders.At(i);        
         int attachedtoticket = str_getvalue(attachedorder.comment,"a="," ");
         string _name = str_getvalue(attachedorder.comment,"n=");
         
         if (event.Info ()) event.Info ("Checking Attached Order "+attachedorder.ticket+" comment: "+attachedorder.comment+" parent:"+attachedtoticket+" name:"+_name,__FUNCTION__);
         
         //Looking for the main order
         if (event.Info ()) event.Info ("Looking for main order ",__FUNCTION__);
         for (int i1 = orders.Total()-1; i1 >= 0; i1--) {
            _order = (COrder*)orders.At(i1);  
            if (event.Info ()) event.Info ("Looking in "+_order.ticket,__FUNCTION__);
            if (_order.ticket == attachedtoticket) {
               // Find out if the order is already attached
               bool found = false;               
               for (int i2 = _order.attachedorders.Total()-1; i2>=0; i2++) {
                  attachedorder1 = (CAttachedOrder*)_order.attachedorders.At(i2);
                  if (attachedorder1.ticket == attachedorder.ticket) {
                     if (event.Info ()) event.Info ("Already Attached to order "+_order.ticket,__FUNCTION__);
                     found = true;
                     break;
                  }
               }
               
               // If not found, adding
               if (!found) {
                  if (event.Info ()) event.Info ("Not Found, Attaching",__FUNCTION__);
                  attachedorder.name = _name;
                  _order.attachedorders.Add(attachedorder);
               }
               
               // Remove from the unassigned attached order               
               attachedorders.Detach(i);
               break;
            }          
         }
      }
      
      if (remove_if_not_found) {
         
         for (i = attachedorders.Total()-1; i >= 0; i--) {
            attachedorder = (CAttachedOrder*)attachedorders.At(i);
            if (event.Info ()) event.Info ("Remove unassigned attached order "+attachedorder.ticket,__FUNCTION__);
            attachedorder.Close();
            attachedorders.Delete(i);
         }
      }
      
   }
   
   void COrderManager::OnTick()
   {
      this.ontick_has_run = true;
      //UpdateAll();
      //MoveToHistoryAll();
      
      COrder* _order;
      
      //addcomment("total:",(string)orders.Total());
      for (int i = 0; i < orders.Total(); i++) {
         _order = orders.At(i);
         if (!isset(_order)) continue;
         //addcomment("main order ",(string)i," ticket=",(string)_order.ticket," ",(string)_order.placed," ",(string)_order.executed," ",(string)_order.canceled," ",(string)_order.closed,"\n");
         _order.OnTick();
         
         // TODO: adding a use_history variable, and the retrainhistory would also work on the main orders array, if the use_history is false.         
         if (_order.closed || _order.executestate == ES_CANCELED) {
            if ((retrainhistory>1 || retrainhistory==0) && !_order.do_not_archive) {
               historyorders.Add(orders.Detach(i));
               i--;
            } else if (retrainhistory == 1 && !_order.do_not_delete && !_order.do_not_archive) {
               orders.Delete(i);
               i--;
            }            
         }
      }
   }
   
   void COrderManager::UpdateAll()
   {
      COrder* _order;
      for (int i = 0; i < orders.Total(); i++) {
         _order = orders.At(i);
         if (!isset(_order)) continue;
         _order.OnTick();         
      }
   }
   
   void COrderManager::UpdateState()
   {
      COrder* _order;
      for (int i = 0; i < orders.Total(); i++) {
         if (!isset(orders.At(i))) {
            event.Warning("order object deleted at orders["+i+"]",__FUNCTION__);
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
   
   void COrderManager::MoveToHistoryAll()
   {
      this.ontick_has_run = true;
      COrder* _order;
      for (int i = 0; i < orders.Total(); i++) {
         _order = orders.At(i);
         if (!isset(_order)) continue;
         if (_order.closed || _order.executestate == ES_CANCELED) {
            //_order.in_history = true;
            historyorders.Add(orders.Detach(i));
            i--; 
         }
      }
   }
   
   void COrderManager::CleanUp(bool cleanall = false)
   {
      if (retrainhistory > 0 || cleanall) {
         for (int i = historyorders.Total()-1; i >= 0; i--) {
            COrder* _order = historyorders.At(i);
            if (!isset(_order)) continue;
            if ((cleanall || _order.closetime < TimeCurrent()-retrainhistory) && !_order.do_not_delete) {
               historyorders.Delete(i);            
            }
         }
      }
   }
   
   void COrderManager::CleanUpUntil(int idx)
   {
      if (retrainhistory > 0) {
         for (int i = historyorders.Total()-1; i >= 0 && i <= idx; i--) {            
            COrder* _order = historyorders.At(i);
            if (!isset(_order)) continue;
            if (!_order.do_not_delete) historyorders.Delete(i);            
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
      for (int i = 0; i < orders.Total(); i++) {
         COrder* _order = orders.At(i);             
         if (isset(_order) && _order.ticket == ticket) return(i);
      }
      return(-1);
   }
   
   int COrderManager::GetIdxByTicketHistory(ulong ticket)
   {
      COrder* _order;
      for (int i = 0; i < historyorders.Total(); i++) {
         _order = historyorders.At(i);         
         if (isset(_order) && _order.ticket == ticket) return(i);
      }
      return(-1);
   }
   
   COrder* COrderManager::GetById(int id)
   {
      COrder* _order;
      for (int i = 0; i < orders.Total(); i++) {
         if (!isset(orders.At(i))) continue;
         _order = orders.At(i);         
         if (_order.id == id) return(_order);
      }
      for (i = 0; i < historyorders.Total(); i++) {
         if (!isset(historyorders.At(i))) continue;
         _order = historyorders.At(i);         
         if (_order.id == id) return(_order);
      }
      return(NULL);
   }
   
   
   bool COrderManager::CloseOrderByIdx(int idx, double closevolume = 0)
   {
      //if ( event.Verbose ()) event.Verbose("call idx="+(string)idx+" closevolume="+(string)closevolume,__FUNCTION__);
      COrder* _order;
      if (isset(orders.At(idx))) {
         _order = orders.At(idx);
         if (_order.Close(closevolume)) {
            if (event.Info ()) event.Info ("Order Closed",__FUNCTION__);
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
      //if ( event.Verbose ()) event.Verbose("call ticket: "+(string)ticket+" closevolume="+(string)closevolume,__FUNCTION__);
      int idx = GetIdxByTicket(ticket);
      if (idx < 0) {
         if (event.Warning ()) event.Warning("ticket not found",__FUNCTION__);
         return(false);
      }
      return(CloseOrderByIdx(idx,closevolume));
   }
   
   bool COrderManager::CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
   {
      //if ( event.Debug ()) event.Debug ("Close All",__FUNCTION__);
      bool ret = false;
      COrder *_order;
      for (int i = orders.Total()-1; i >= 0; i--) {
         _order = orders.At(i);
         //_order.Update();
         if (isset(_order)) {
            if (!state_select(stateselect,_order.State())) { continue; }
            if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
            if (in_magic != -1 && _order.magic != in_magic) { continue; }
            if (!ordertype_select(orderselect,_order.GetType())) { continue; }
            if (_order.executestate == ES_EXECUTED || _order.executestate == ES_VIRTUAL) {
               if (event.Info()) event.Info("Closing Order "+_order.ticket+" selection:"+orderselect,__FUNCTION__);
               if (_order.State() == ORDER_STATE_FILLED) {
                  if (_order.Close()) {
                     ret = true;
                  } else {
                     //if (event.Error ()) event.Error("Failed to close order",__FUNCTION__);
                  }
               }
               else if (_order.State() == ORDER_STATE_PLACED) {
                  if (!_order.Cancel()) {
                     if (event.Error ()) event.Error("Failed to cancel order",__FUNCTION__);
                  }
                  ret = true;
               }
            }
         }
      }
      return(ret);
   }

   int COrderManager::CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
   {
      //if ( event.Debug ()) event.Debug ("Cnt Orders",__FUNCTION__);
      int cnt = 0;
      COrder *_order;
      for (int i = orders.Total()-1; i >= 0; i--) {
         _order = orders.At(i);
         //_order.Update();
         if (isset(_order)) {
            if (!state_select(stateselect,_order.State())) { continue; }
            if (!ordertype_select(orderselect,_order.GetType())) { continue; }
            if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
            if (in_magic != -1 && _order.magic != in_magic) { continue; }
            cnt++;
         }
      }    
      return(cnt);
   }
   
   double COrderManager::AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
   {
      double sum_price_buy = 0;
      double sum_lots_buy = 0;
      double sum_price_sell = 0;
      double sum_lots_sell = 0;
      COrder *_order;
      for (int i = orders.Total()-1; i >= 0; i--) {
         _order = orders.At(i);
         //_order.Update();
         if (isset(_order)) {
            if (!state_select(stateselect,_order.State())) { continue; }
            if (!ordertype_select(orderselect,_order.GetType())) { continue; }
            if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
            if (in_magic != -1 && _order.magic != in_magic) { continue; }
            
            if (ordertype_select(ORDERSELECT_LONG,_order.GetType())) {
               sum_lots_buy += _order.GetLots();
               sum_price_buy += _order.GetOpenPrice()*_order.GetLots();
            }
            if (ordertype_select(ORDERSELECT_SHORT,_order.GetType())) {
               sum_lots_sell += _order.GetLots();
               sum_price_sell += _order.GetOpenPrice()*_order.GetLots();
            }
         }
      }    
      double avg_price_buy = 0;
      double avg_price_sell = 0;
      
      if (sum_lots_buy > 0) avg_price_buy = sum_price_buy/sum_lots_buy;
      if (sum_lots_sell > 0) avg_price_sell = sum_price_sell/sum_lots_sell;
   
      if (sum_lots_buy > sum_lots_sell) return(avg_price_buy+(sum_lots_sell==0?0:(avg_price_buy-avg_price_sell)*(sum_lots_sell/(sum_lots_buy-sum_lots_sell))));
      if (sum_lots_buy < sum_lots_sell) return(avg_price_sell-(sum_lots_buy==0?0:(avg_price_buy-avg_price_sell)*(sum_lots_buy/(sum_lots_sell-sum_lots_buy))));
      return 0;
   }
   
   double COrderManager::TotalLots(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
   {
      double sum_lots_buy = 0;
      double sum_lots_sell = 0;
      COrder *_order;
      for (int i = orders.Total()-1; i >= 0; i--) {
         _order = orders.At(i);
         //_order.Update();
         if (isset(_order)) {
            if (!state_select(stateselect,_order.State())) { continue; }
            if (!ordertype_select(orderselect,_order.GetType())) { continue; }
            if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
            if (in_magic != -1 && _order.magic != in_magic) { continue; }
            
            if (ordertype_select(ORDERSELECT_LONG,_order.GetType())) {
               sum_lots_buy += _order.GetLots();
            }
            if (ordertype_select(ORDERSELECT_SHORT,_order.GetType())) {
               sum_lots_sell += _order.GetLots();
            }
         }
      }    
      return sum_lots_buy+sum_lots_sell;
   }
   
   double COrderManager::TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
   {
      double sum_price_buy = 0;
      double sum_lots_buy = 0;
      double sum_price_sell = 0;
      double sum_lots_sell = 0;
      COrder *_order;
      for (int i = orders.Total()-1; i >= 0; i--) {
         _order = orders.At(i);
         //_order.Update();
         if (isset(_order)) {
            if (!state_select(stateselect,_order.State())) { continue; }
            if (!ordertype_select(orderselect,_order.GetType())) { continue; }
            if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
            if (in_magic != -1 && _order.magic != in_magic) { continue; }
            
            if (ordertype_select(ORDERSELECT_LONG,_order.GetType())) {
               sum_lots_buy += _order.GetLots();
               sum_price_buy += _order.GetOpenPrice()*_order.GetLots();
            }
            if (ordertype_select(ORDERSELECT_SHORT,_order.GetType())) {
               sum_lots_sell += _order.GetLots();
               sum_price_sell += _order.GetOpenPrice()*_order.GetLots();
            }
         }
      }    
      double avg_price_buy = 0;
      double avg_price_sell = 0;
      
      double avg_price = 0;
      
      if (in_symbol != "") loadsymbol(in_symbol,__FUNCTION__);
      
      if (sum_lots_buy > 0) avg_price_buy = sum_price_buy/sum_lots_buy;
      if (sum_lots_sell > 0) avg_price_sell = sum_price_sell/sum_lots_sell;
   
      if (sum_lots_buy > sum_lots_sell) {
         avg_price = avg_price_buy+(sum_lots_sell==0?0:(avg_price_buy-avg_price_sell)*(sum_lots_sell/(sum_lots_buy-sum_lots_sell)));
         return _symbol.InTicks(_symbol.Bid()-avg_price_buy);
      }
      if (sum_lots_buy < sum_lots_sell) {
         avg_price = avg_price_sell-(sum_lots_buy==0?0:(avg_price_buy-avg_price_sell)*(sum_lots_buy/(sum_lots_sell-sum_lots_buy)));
         return _symbol.InTicks(avg_price-_symbol.Ask());
      }
      
      return 0;
   }

   double COrderManager::TotalProfitMoney(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1, bool _commission = true, bool swap = true)
   {
      double totalprofit = 0;
      COrder *_order;
      for (int i = orders.Total()-1; i >= 0; i--) {
         _order = orders.At(i);
         if (isset(_order)) {
            if (!state_select(stateselect,_order.State())) { continue; }
            if (!ordertype_select(orderselect,_order.GetType())) { continue; }
            if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
            if (in_magic != -1 && _order.magic != in_magic) { continue; }
            if (_order.Select()) {
               totalprofit += OrderProfit()+(_commission?OrderCommission():0)-(swap?OrderSwap():0);
            }
         }
      }
      if (state_select(stateselect,ORDER_STATE_CLOSED)) {
         for (i = historyorders.Total()-1; i >= 0; i--) {
            _order = historyorders.At(i);
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
               if (in_magic != -1 && _order.magic != in_magic) { continue; }
               if (_order.Select())
                  totalprofit += OrderProfit()+(_commission?OrderCommission():0)-(swap?OrderSwap():0);
            }
         }
      }
      return totalprofit;
   }   
   /*
   double TotalProfitMoney(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1)
   {
      int total = this.OrdersTotal();
      double totalprofit = 0;
      int i;
      for (i = total-1; i >= 0; i--) {
         if (!om.SelectOrderByIdx(i)) continue;
         if (!ordertype_select(type,selectedorder.GetType())) continue;
         if (!state_select(state,selectedorder.State())) continue;
         if (in_symbol != "" && selectedorder.GetSymbol() != in_symbol) continue;
         if (in_magic >= 0 && selectedorder.GetMagicNumber() != in_magic) continue;
         if (selectedorder.Select()) {
            totalprofit += OrderProfit()+(OrderCommission())-(OrderSwap());
         }
      }    
      return(totalprofit);   
   }      

*/
   
   bool COrderManager::CancelOrderByIdx(int idx)
   {
      COrder* _order;
      if (isset(orders.At(idx))) {
         _order = orders.At(idx);
         if (!isset(_order)) { event.Warning("Order object to cancel doesn't exists",__FUNCTION__); return(false);}
         if (_order.Cancel()) {return(true);}
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
         if (event.Warning ()) event.Warning ("ticket not found",__FUNCTION__);
         return(false);
      }
      return(CancelOrderByIdx(idx));
   }