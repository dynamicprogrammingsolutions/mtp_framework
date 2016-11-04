//

#include "Loader.mqh"

#ifndef ORDER_REPOSITORY_H
#define ORDER_REPOSITORY_H

class COrderRepository : public COrderRepositoryInterface
{
private:
   COrderInterface* selected;   
   COrderArray* orders;
   COrderArray* historyorders;
   int retainhistory;
   
public:
   TraitAppAccess
   TraitLoadSymbolFunction
   TraitGetType(classMT5OrderRepository)
   TraitServiceAlias(CEventHandlerInterface*,eventhandler,event)
   
   COrderRepository(CAppObject* neworder)
   {
      orders = new COrderArray(neworder);
      historyorders = new COrderArray(neworder);   
      retainhistory = 2592000;
   }
   
   ~COrderRepository()
   {
      delete orders;
      delete historyorders;   
   }
   
   virtual void Initalize()
   {
      Prepare(GetPointer(orders)); 
      Prepare(GetPointer(historyorders));   
   }
   
   virtual void Clear() {
      orders.Clear();
      historyorders.Clear();
   }

   
   virtual CArrayObject<COrderInterface>* Orders() { return orders; }
   
   virtual bool Save(const int handle);
   virtual bool Load(const int handle);
   
   virtual void OnTick();
   
   virtual COrderInterface* Selected() { return selected; }  
   
   virtual void Add(COrderInterface* order) { this.orders.Add(order); }

   virtual int Total() { return(orders.Total()); }
   virtual int HistoryTotal() { return(historyorders.Total()); }

   virtual COrderInterface* GetByIdx(int idx) { return(orders.At(idx)); }
   virtual COrderInterface* GetByIdxHistory(int idx) { return(historyorders.At(idx)); }

   virtual int GetIdxByTicket(int ticket);   
   virtual int GetIdxByTicketHistory(int ticket);

   virtual COrderInterface* GetByTicketOrder(uint ticket) { int idx;  return(((idx = GetIdxByTicket(ticket)) >= 0)?GetByIdx(idx):NULL); }
   virtual COrderInterface* GetByTicketHistory(uint ticket) { int idx;  return(((idx = GetIdxByTicketHistory(ticket)) >= 0)?GetHistoryByIdx(idx):NULL); }
   virtual COrderInterface* GetByTicket(int ticket) { int idx; return(((idx = GetIdxByTicket(ticket)) >= 0) ? GetByIdx(idx) : ( ((idx = GetIdxByTicketHistory(ticket)) >= 0) ? GetHistoryByIdx(idx) : ( NULL ) )); }
   virtual COrderInterface* GetById(int id);
   
   virtual bool SelectByIdxOrder(int idx) { return(isset(selected = (COrder*)orders.At(idx))); }
   virtual bool SelectByIdxHistory(int idx) { return(isset(selected = (COrder*)historyorders.At(idx))); }   
   virtual bool SelectByTicketOrder(uint ticket) { int idx; return(((idx = GetIdxByTicket(ticket)) >= 0)?SelectByIdxOrder(idx):false); }
   
   virtual bool GetOrders(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1);
   virtual bool GetOrders(COrderInterface* &order, ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1);
   virtual bool GetOrders(int &index, COrderInterface* &order, ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1);

   virtual bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   //virtual bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect, string in_symbol, int in_magic, CAppObject*);
   virtual int CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);

   virtual double AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   virtual double TotalLots(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   virtual double TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1);
   virtual double TotalProfitMoney(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1, bool _commission = true, bool swap = true);
   
   void RetainHistory(int _retainhistory) { this.retainhistory = _retainhistory; }
   
};

bool COrderRepository::Save(const int handle)
{
   MTPFileBin file;
   file.Handle(handle);            
   if (file.Invalid()) return false;

   //Print("saving orders");
   if (!file.WriteObject(GetPointer(orders))) return file.Error("orders",__FUNCTION__);

   //Print("saving historyorders");
   if (!file.WriteObject(GetPointer(historyorders))) return file.Error("historyorders",__FUNCTION__);

   return(true);
}

bool COrderRepository::Load(const int handle)
{
   MTPFileBin file;
   file.Handle(handle);            
   if (file.Invalid()) return false;                 

   //Print("loading orders");
   if (!file.ReadObject(GetPointer(orders))) return file.Error("orders",__FUNCTION__);

   //Print("loading historyorders");
   if (!file.ReadObject(GetPointer(historyorders))) return file.Error("historyorders",__FUNCTION__);

   return(true);
}

void COrderRepository::OnTick()
{
   COrderInterface* _order;

   for (int i = 0; i < orders.Total(); i++) {
      if (!isset(orders.At(i))) continue;
      _order = orders.At(i);
      _order.OnTick();
      
      // TODO: adding a use_history variable, and the retrainhistory would also work on the main orders array, if the use_history is false.         
      if (_order.ClosedOrDeleted() || _order.ExecuteState() == ES_CANCELED) {
         if ((retainhistory>1 || retainhistory==0) && !_order.DoNotArchive()) {
            event().Info("Adding order id "+(string)_order.Id()+" ticket "+(string)_order.GetTicket()+" to history",__FUNCTION__);
            historyorders.Add(orders.Detach(i));
            i--;
         } else if (retainhistory == 1 && !_order.DoNotDelete() && !_order.DoNotArchive()) {
            event().Info("Deleting order id "+(string)_order.Id()+" ticket "+(string)_order.GetTicket(),__FUNCTION__);
            orders.Delete(i);
            i--;
         }            
      }
   }

}

int COrderRepository::GetIdxByTicket(int ticket)
{
   for (int i = 0; i < orders.Total(); i++) {
      COrderInterface* _order = orders.At(i);             
      if (isset(_order) && _order.GetTicket() == ticket) return(i);
   }
   return(-1);
}

int COrderRepository::GetIdxByTicketHistory(int ticket)
{
   COrderInterface* _order;
   for (int i = 0; i < historyorders.Total(); i++) {
      _order = historyorders.At(i);         
      if (isset(_order) && _order.GetTicket() == ticket) return(i);
   }
   return(-1);
}

COrderInterface* COrderRepository::GetById(int id)
{
   COrderInterface* _order;
   int i;
   for (i = 0; i < orders.Total(); i++) {
      if (!isset(orders.At(i))) continue;
      _order = orders.At(i);         
      if (_order.Id() == id) return(_order);
   }
   for (i = 0; i < historyorders.Total(); i++) {
      if (!isset(historyorders.At(i))) continue;
      _order = historyorders.At(i);         
      if (_order.Id() == id) return(_order);
   }
   return(NULL);
}

/*bool COrderRepository::GetOrders(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1, bool no_loop_and_reset = false)
   {
      static int get_orders_i = -1;
      int total = this.Total();
      if (get_orders_i < 0) {
         get_orders_i = 0;
      }
      bool gotorder = false;
      for (; get_orders_i < total; get_orders_i++) {
         if (!this.SelectByIdxOrder(get_orders_i)) continue;
         if (!ordertype_select(type,selected.GetType())) continue;
         if (!state_select(state,selected.State())) continue;
         if (in_symbol != "" && selected.GetSymbol() != in_symbol) continue;
         if (in_magic >= 0 && selected.GetMagicNumber() != in_magic) continue;
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
   }*/
   
bool COrderRepository::GetOrders(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1)
{
   while(orders.ForEach(this.selected)) {
      if (!ordertype_select(type,selected.GetType())) continue;
      if (!state_select(state,selected.State())) continue;
      if (in_symbol != "" && selected.GetSymbol() != in_symbol) continue;
      if (in_magic >= 0 && selected.GetMagicNumber() != in_magic) continue;
      return true;
   }
   return false;
}
   
bool COrderRepository::GetOrders(COrderInterface* &order, ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1)
{
   while(orders.ForEach(order)) {
      if (!ordertype_select(type,order.GetType())) continue;
      if (!state_select(state,order.State())) continue;
      if (in_symbol != "" && order.GetSymbol() != in_symbol) continue;
      if (in_magic >= 0 && order.GetMagicNumber() != in_magic) continue;
      return true;
   }
   return false;
}

bool COrderRepository::GetOrders(int &index, COrderInterface* &order, ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1)
{
   while(orders.ForEach(order,index)) {
      if (!ordertype_select(type,order.GetType())) continue;
      if (!state_select(state,order.State())) continue;
      if (in_symbol != "" && order.GetSymbol() != in_symbol) continue;
      if (in_magic >= 0 && order.GetMagicNumber() != in_magic) continue;
      return true;
   }
   return false;
}


bool COrderRepository::CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
{
   return orders.CloseAll(orderselect,stateselect,in_symbol,in_magic);
   //if ( event.Debug ()) event.Debug ("Close All",__FUNCTION__);
   /*bool ret = false;
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
            if (App().eventhandler.Info()) App().eventhandler.Info("Closing Order "+(string)_order.ticket+" selection:"+EnumToString(orderselect),__FUNCTION__);
            if (_order.State() == ORDER_STATE_FILLED) {
               if (_order.Close()) {
                  ret = true;
               } else {
                  //if (event.Error ()) event.Error("Failed to close order",__FUNCTION__);
               }
            }
            else if (_order.State() == ORDER_STATE_PLACED) {
               if (!_order.Cancel()) {
                  if (App().eventhandler.Error ()) App().eventhandler.Error("Failed to cancel order",__FUNCTION__);
               }
               ret = true;
            }
         }
      }
   }
   return(ret);*/
}

/*bool COrderRepository::CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect, string in_symbol, int in_magic, CAppObject* callbackobj)
{
   //if ( event.Debug ()) event.Debug ("Close All",__FUNCTION__);
   bool ret = false;
   COrderInterface *_order;
   for (int i = orders.Total()-1; i >= 0; i--) {
      _order = orders.At(i);
      //_order.Update();
      if (isset(_order)) {
         if (!state_select(stateselect,_order.State())) { continue; }
         if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
         if (in_magic != -1 && _order.GetMagicNumber() != in_magic) { continue; }
         if (!ordertype_select(orderselect,_order.GetType())) { continue; }
         if (_order.ExecuteState() == ES_EXECUTED || _order.ExecuteState() == ES_VIRTUAL) {
            if (!callbackobj.callback(0,_order)) continue;
            if (App().eventhandler.Info()) App().eventhandler.Info("Closing Order "+(string)_order.GetTicket()+" selection:"+EnumToString(orderselect),__FUNCTION__);
            if (_order.State() == ORDER_STATE_FILLED) {
               if (_order.Close()) {
                  ret = true;
               } else {
                  //if (event.Error ()) event.Error("Failed to close order",__FUNCTION__);
               }
            }
            else if (_order.State() == ORDER_STATE_PLACED) {
               if (!_order.Cancel()) {
                  if (App().eventhandler.Error ()) App().eventhandler.Error("Failed to cancel order",__FUNCTION__);
               }
               ret = true;
            }
         }
      }
   }
   return(ret);
}*/

int COrderRepository::CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
{
   return orders.CntOrders(orderselect,stateselect,in_symbol,in_magic);
   //if ( event.Debug ()) event.Debug ("Cnt Orders",__FUNCTION__);
   /*int cnt = 0;
   COrderInterface *_order;
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
   return(cnt);*/
}

double COrderRepository::AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
{
   return orders.AvgPrice(orderselect,stateselect,in_symbol,in_magic);
   /*double sum_price_buy = 0;
   double sum_lots_buy = 0;
   double sum_price_sell = 0;
   double sum_lots_sell = 0;
   COrderInterface *_order;
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
   return 0;*/
}

double COrderRepository::TotalLots(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
{
   return orders.TotalLots(orderselect,stateselect,in_symbol,in_magic);
   /*double sum_lots_buy = 0;
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
   return sum_lots_buy+sum_lots_sell;*/
}

double COrderRepository::TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
{
   return orders.TotalProfit(orderselect,stateselect,in_symbol,in_magic);
   /*double sum_price_buy = 0;
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
         
         if (in_symbol == "") in_symbol = _order.symbol;
         
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
   
   if (in_symbol != "") loadsymbol(in_symbol);
   else loadsymbol(Symbol());
   
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
   
   return 0;*/
}

double COrderRepository::TotalProfitMoney(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1, bool _commission = true, bool swap = true)
{
   return orders.TotalProfitMoney(orderselect,stateselect,in_symbol,in_magic,_commission,swap);
   /*double totalprofit = 0;
   COrderInterface *_order;
   int i;
   for (i = orders.Total()-1; i >= 0; i--) {
      _order = orders.At(i);
      if (isset(_order)) {
         if (!state_select(stateselect,_order.State())) { continue; }
         if (!ordertype_select(orderselect,_order.GetType())) { continue; }
         if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
         if (in_magic != -1 && _order.GetMagicNumber() != in_magic) { continue; }
         totalprofit += _order.GetProfitMoney()-(_commission?_order.GetCommission():0)+(swap?_order.GetSwap():0);
      }
   }
   if (state_select(stateselect,ORDER_STATE_CLOSED)) {
      for (i = historyorders.Total()-1; i >= 0; i--) {
         _order = historyorders.At(i);
         if (isset(_order)) {
            if (!state_select(stateselect,_order.State())) { continue; }
            if (!ordertype_select(orderselect,_order.GetType())) { continue; }
            if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
            if (in_magic != -1 && _order.GetMagicNumber() != in_magic) { continue; }
            totalprofit += _order.GetProfitMoney()-(_commission?_order.GetCommission():0)+(swap?_order.GetSwap():0);
         }
      }
   }
   return totalprofit;*/
}

#endif