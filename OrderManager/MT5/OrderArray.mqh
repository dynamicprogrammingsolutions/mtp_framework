//
#include "Loader.mqh"

#ifndef ORDER_ARRAY_H
#define ORDER_ARRAY_H
class COrderArray : public CArrayObject<COrderInterface>
{
public:
   virtual int Type() const { return classMT5OrderArray; }

public:
      CApplication* App() { return (CApplication*)AppBase(); }
      CSymbolInfoInterface* _symbol;
      void loadsymbol(string __symbol)
      {
         _symbol = App().symbolloader.LoadSymbol(__symbol);
      }
      
      COrderArray()
      {
         this.NewElement(new COrder());
      }
      
      ~COrderArray()
      {
         //delete neworder;
      }

      //CAppObject* neworder;   
      COrderArray(CAppObject* _neworder)
      {
         this.NewElement(_neworder);
      }
      COrder* Order(int nIndex){ if (!isset(At(nIndex))) return(NULL); else return((COrder*)At(nIndex)); }     
      
      /*virtual bool  CreateElement(const int index) {
         m_data[index] = (CObject*)(App().NewObject(neworder));
         return(true);
      }*/
      
      int CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
      {
         //if ( event.Debug ()) event.Debug ("Cnt Orders",__FUNCTION__);
         int cnt = 0;
         COrderInterface *_order;
         for (int i = this.Total()-1; i >= 0; i--) {
            _order = this.At(i);
            //_order.Update();
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               // Temporarily exluding all Closed orders as it cannot be exluded by state select
               if (_order.Closed()) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
               if (in_magic != -1 && _order.GetMagicNumber() != in_magic) { continue; }
               cnt++;
            }
         }    
         return(cnt);
      }
      
      double TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
      {
         double sum_price_buy = 0;
         double sum_lots_buy = 0;
         double sum_price_sell = 0;
         double sum_lots_sell = 0;
         COrderInterface *_order;
         for (int i = this.Total()-1; i >= 0; i--) {
            _order = this.At(i);
            //_order.Update();
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               // Temporarily exluding all Closed orders as it cannot be exluded by state select
               if (_order.Closed()) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
               if (in_magic != -1 && _order.GetMagicNumber()  != in_magic) { continue; }
               
               loadsymbol(_order.GetSymbol());

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
      
      double TotalProfitMoney(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1, bool _commission = true, bool swap = true)
      {
         double totalprofit = 0;
         COrderInterface *_order;
         int i;
         for (i = this.Total()-1; i >= 0; i--) {
            _order = this.At(i);
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               // Temporarily exluding all Closed orders as it cannot be exluded by state select
               if (_order.Closed()) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
               if (in_magic != -1 && _order.GetMagicNumber()  != in_magic) { continue; }
               totalprofit += _order.GetProfitMoney()-(_commission?_order.GetCommission():0)+(swap?_order.GetSwap():0);
            }
         }
         return totalprofit;
      }   
      
      double AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
      {
         double sum_price_buy = 0;
         double sum_lots_buy = 0;
         double sum_price_sell = 0;
         double sum_lots_sell = 0;
         COrderInterface *_order;
         for (int i = this.Total()-1; i >= 0; i--) {
            _order = this.At(i);
            //_order.Update();
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               // Temporarily exluding all Closed orders as it cannot be exluded by state select
               if (_order.Closed()) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
               if (in_magic != -1 && _order.GetMagicNumber()  != in_magic) { continue; }
               
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
      
      double TotalLots(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
      {
         double sum_lots_buy = 0;
         double sum_lots_sell = 0;
         COrderInterface *_order;
         for (int i = this.Total()-1; i >= 0; i--) {
            _order = this.At(i);
            //_order.Update();
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               // Temporarily exluding all Closed orders as it cannot be exluded by state select
               if (_order.Closed()) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
               if (in_magic != -1 && _order.GetMagicNumber() != in_magic) { continue; }
               
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
      
      bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
      {
         //if ( event.Debug ()) event.Debug ("Close All",__FUNCTION__);
         bool ret = false;
         COrderInterface *_order;
         for (int i = this.Total()-1; i >= 0; i--) {
	      if (!isset(this.At(i))) continue;
            _order = this.At(i);
            //_order.Update();
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               // Temporarily exluding all Closed orders as it cannot be exluded by state select
               if (_order.Closed()) { continue; }
               if (in_symbol != "" && _order.GetSymbol() != in_symbol) { continue; }
               if (in_magic != -1 && _order.GetMagicNumber()  != in_magic) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (_order.ExecuteState() == ES_EXECUTED || _order.ExecuteState() == ES_VIRTUAL) {
                  //if (event.Info()) event.Info("Closing Order "+_order.ticket+" selection:"+orderselect,__FUNCTION__);
                  if (_order.State() == ORDER_STATE_FILLED) {
                     if (_order.Close()) {
                        ret = true;
                     } else {
                        //if (event.Error ()) event.Error("Failed to close order",__FUNCTION__);
                     }
                  }
                  else if (_order.State() == ORDER_STATE_PLACED) {
                     if (!_order.Cancel()) {
                        //if (event.Error ()) event.Error("Failed to cancel order",__FUNCTION__);
                     }
                     ret = true;
                  }
               }
            }
         }
         return(ret);
      }
      
};

#endif