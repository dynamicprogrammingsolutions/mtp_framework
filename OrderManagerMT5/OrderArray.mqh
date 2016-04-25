//

class COrderArray : public CAppObjectArrayObjManaged
{
public:
   TraitAppAccess
   virtual int Type() const { return classMT5OrderArray; }
public:
   CAppObject* neworder;   
   COrderArray(CAppObject* _neworder)
   {
      neworder = _neworder;
      m_free_mode = true;
   }
   COrder* Order(int nIndex){ if (!isset(At(nIndex))) return(NULL); else return((COrder*)At(nIndex)); }   
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(App().NewObject(neworder));
      return(true);
   }
   
   int CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
   {
      //if ( event.Debug ()) event.Debug ("Cnt Orders",__FUNCTION__);
      int cnt = 0;
      COrder *_order;
      for (int i = this.Total()-1; i >= 0; i--) {
         _order = this.At(i);
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
   
   double AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
      {
         double sum_price_buy = 0;
         double sum_lots_buy = 0;
         double sum_price_sell = 0;
         double sum_lots_sell = 0;
         COrder *_order;
         for (int i = this.Total()-1; i >= 0; i--) {
            _order = this.At(i);
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
      
   
};