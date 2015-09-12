//#include "OrderBase.mqh"

#include "OrderBase.mqh"
#include "AttachedOrderArray.mqh"

#include <Arrays\ArrayObj.mqh>

// *** COrder ***

class COrder : public COrderBase
{
private:
   static string attachedtoticket;
   static string stoploss_name;
   static string takeprofit_name;
   bool disable_vstops;
   
public:
   static bool sl_virtual_default;
   static bool tp_virtual_default;

   CAttachedOrderArray attachedorders;
   bool attachedorder_place_on_pending;

   bool closed;
   
   bool do_not_archive;
   bool do_not_delete;
   //bool in_history;

   COrder(int existing_ticket) ; 
   
   COrder() {            
      closetime = 0;
      attachedorder_place_on_pending = false;
      //do_not_delete = false;
      //in_history = false;
      disable_vstops = false;
      
      sl_virtual = sl_virtual_default;
      tp_virtual = tp_virtual_default;
      
   };
   COrder(string in_symbol,int _ordertype,double _volume,double _price,double _stoploss,double _takeprofit,string _comment="",datetime _expiration=0) 
   { 
      closetime = 0;
      attachedorder_place_on_pending = false;
      //do_not_delete = false;
      //in_history = false;
      disable_vstops = false;
      
      sl_virtual = sl_virtual_default;
      tp_virtual = tp_virtual_default;
      
      NewOrder(in_symbol,_ordertype,_volume,_price,_stoploss,_takeprofit,_comment,_expiration);      
   }
    
   ~COrder() { delete this.orderinfo; }
      
   bool NewOrder(const string in_symbol,const int _ordertype,const double _volume,const double _price,
      const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);     
   static bool ExistingOrder(int ticket, COrderBase*& orderbase, COrderBase*& order, COrderBase*& attachedorder);
   
   bool CreateAttached(int _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment);   
   bool AddStopLoss(double in_price, double stopvolume = 0, string name = "");
   bool AddTakeProfit(double in_price, double stopvolume = 0, string name = "");

   virtual void OnTick();
   
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      Print(__FUNCTION__+" Start Saving pos: "+file.Tell());

      if (!file.WriteBool(disable_vstops)) return file.Error("disable_vstops",__FUNCTION__);
      if (!file.WriteBool(closed)) return file.Error("closed",__FUNCTION__);
      //if (!file.WriteObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);
      
      Print(__FUNCTION__+" Start Saving OrderBase pos: "+file.Tell());
      
      if (!COrderBase::Save(handle)) return file.Error("COrderBase",__FUNCTION__);

      Print(__FUNCTION__+" End Saving pos: "+file.Tell());

      return(true);
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return file.Error("invalid file",__FUNCTION__);           

      Print(__FUNCTION__+" Start Loading pos: "+file.Tell());

      if (!file.ReadBool(disable_vstops)) return file.Error("disable_vstops",__FUNCTION__);
      if (!file.ReadBool(closed)) return file.Error("closed",__FUNCTION__);
      //if (!file.ReadObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);
      
      Print(__FUNCTION__+" Start Loading OrderBase pos: "+file.Tell());
      
      if (!COrderBase::Load(handle)) return file.Error("COrderBase",__FUNCTION__);

      Print(__FUNCTION__+" End Loading pos: "+file.Tell());

      return(true);
   }

protected:    
   virtual CAttachedOrder* NewAttachedOrderObject() { return(new CAttachedOrder()); } 
   
};

bool COrder::sl_virtual_default = false;
bool COrder::tp_virtual_default = false;

string COrder::attachedtoticket = "a=";
string COrder::stoploss_name = "sl";
string COrder::takeprofit_name = "tp";

// *** COrderArray ***

// TODO: add event

class COrderArray : public CArrayObj
{
   public:
      COrderManagerBase* OM;
        
      COrderArray()
      {
         m_free_mode = false;
      }
      COrder* Order(int nIndex){ if (!isset(CArrayObj::At(nIndex))) return(NULL); else return((COrder*)CArrayObj::At(nIndex)); }     
      
      virtual bool  CreateElement(const int index) {
         if (isset(OM)) {
            m_data[index] = (CObject*)(OM.NewOrderObject());
         } else {
            m_data[index] = (CObject*)(new COrder());
         }
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
      
      double TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
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
      
      
      bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)
      {
         //if ( event.Debug ()) event.Debug ("Close All",__FUNCTION__);
         bool ret = false;
         COrder *_order;
         for (int i = this.Total()-1; i >= 0; i--) {
            _order = this.At(i);
            //_order.Update();
            if (isset(_order)) {
               if (!state_select(stateselect,_order.State())) { continue; }
               if (in_symbol != "" && _order.symbol != in_symbol) { continue; }
               if (in_magic != -1 && _order.magic != in_magic) { continue; }
               if (!ordertype_select(orderselect,_order.GetType())) { continue; }
               if (_order.executestate == ES_EXECUTED || _order.executestate == ES_VIRTUAL) {
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

// ********************************************************************************************
// |---------------------------------------- COrder ------------------------------------------|
// ********************************************************************************************






   COrder::COrder(int existing_ticket) {      
      ExistingOrder(existing_ticket);
      
   };   
   
   //static COrder* COrder::NewOrder(string in_symbol,int _ordertype,double _volume,double _price,double _stoploss,double _takeprofit,string _comment="",datetime _expiration=0)
   
   bool COrder::NewOrder(const string in_symbol,const int _ordertype,const double _volume,const double _price,
      const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
   {
      //if ( event.Debug ()) event.Debug ("New Order",__FUNCTION__);
      symbol = in_symbol;
      SetOrderType(_ordertype);
      SetLots(_volume);
      SetPrice(_price);
      if (use_normal_stops) {
         SetStopLoss(_stoploss);
         SetTakeProfit(_takeprofit);  
      }          
      comment = _comment;
      SetExpiration(_expiration);

      if (!Execute()) {
         //if (event.Warning ()) event.Warning ("Failed to execute retcode:"+(string)retcode,__FUNCTION__);
         return(false);
      }
      
      if (!use_normal_stops) {
         if (_stoploss > 0) AddStopLoss(_stoploss);
         if (_takeprofit > 0) AddTakeProfit(_takeprofit);
      }

      return(Execute());          
   }
   
   static bool COrder::ExistingOrder(int ticket, COrderBase*& orderbase, COrderBase*& _order, COrderBase*& attachedorder) {
      if (orderbase.ExistingOrder(ticket)) {
         if (CAttachedOrder::IsAttached(orderbase.comment)) {
            if (attachedorder == NULL) attachedorder = new CAttachedOrder();
            orderbase.Copy(attachedorder);
            delete _order;
         } else {
            if (_order == NULL) _order = new COrder(); 
            orderbase.Copy(_order);   
            delete attachedorder;
         }
         return(true);         
      } else {
         return(false);
      }
   };   

   bool COrder::CreateAttached(int _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment)
   {
      CAttachedOrder *attachedorder;
      //if (_price > 0) {
         attachedorder = NewAttachedOrderObject();
         //attachedorder.ordermanager = this.ordermanager;
         //attachedorder.event = this.event;
         attachedorder.symbol = this.symbol;
         attachedorder.SetOrderType(_ordertype);
         attachedorder.SetLots(_volume);
         attachedorder.SetPrice(_price);
         attachedorder.name = _name;
         attachedorder.comment = _comment;
         
         if (!attachedorders.Add(attachedorder)) {
            if (event.Info ()) event.Info ("Failed to add attached order",__FUNCTION__);
            delete attachedorder;
            return(false);
         }
         if (executestate == ES_EXECUTED && state_filled(state)) {
            if (event.Info ()) event.Info ("Execute Attached Order name:"+_name,__FUNCTION__);
            if (!attachedorder.Execute()) {
               if (event.Warning ()) event.Warning ("attached order failed, closing main order "+this.ticket,__FUNCTION__);
               this.Close();               
            }
            //attachedorder.Update();
         } else {
            if (event.Info ()) event.Info ("Main order "+(string)this.ticket+" not filled yet (state:"+state+"), waiting with executing attached order "+_name,__FUNCTION__);
         }
         return(true);
      //}
      return(false);
   }
   
   bool COrder::AddStopLoss(double in_price, double stopvolume = 0, string name = "")
   {
      if (name == "") name = stoploss_name;
      if (stopvolume == 0) stopvolume = GetLots();
      int attachedordertype;
      switch(GetType()) {
         case ORDER_TYPE_BUY:
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
            attachedordertype = ORDER_TYPE_SELL_STOP;
            break;
         case ORDER_TYPE_SELL:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
            attachedordertype = ORDER_TYPE_BUY_STOP;
            break;
         default:
            return(false);
      }
      if (!CreateAttached(attachedordertype,stopvolume,in_price,0,name,"a="+(string)ticket+" n="+name)) return(false);
      return(true);
   }
   
    bool COrder::AddTakeProfit(double in_price, double stopvolume = 0, string name = "")
   {
      if (name == "") name = takeprofit_name;
      if (stopvolume == 0) stopvolume = GetLots();
      int attachedordertype;

      switch(GetType()) {
         case ORDER_TYPE_BUY:
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
            attachedordertype = ORDER_TYPE_SELL_LIMIT;
            break;
         case ORDER_TYPE_SELL:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
            attachedordertype = ORDER_TYPE_BUY_LIMIT;
            break;
         default:
            return(false);
      }      
      if (!CreateAttached(attachedordertype,stopvolume,in_price,0,name,"a="+(string)ticket+" n="+name)) return(false);
      return(true);
   }      
    
   void COrder::OnTick()
   {
      //if ( event.Debug ()) event.Debug ("Update Order "+ticket,__FUNCTION__);
      if (this.closed) return;
      
      COrderBase::OnTick();

      if (this.state == ORDER_STATE_CLOSED && this.closetime == 0) {               
         this.closetime = this.orderinfo.GetCloseTime();
      }
            
      if (executestate == ES_EXECUTED) {
         //if ( event.Debug ()) event.Debug ("State: "+state+" executestate: "+executestate,__FUNCTION__);
         int i;    
         CAttachedOrder *attachedorder;        
         //if (executestate == ES_EXECUTED) { 
           
            switch (this.state) {  
            case ORDER_STATE_PLACED:
               if (!attachedorder_place_on_pending) break;
            case ORDER_STATE_FILLED:               
               //BEGIN Checking Attached
               for (i = 0; i < attachedorders.Total(); i++) {
                  attachedorder = attachedorders.AttachedOrder(i);
                  
                  switch (attachedorder.executestate) {
                     
                  case ES_NOT_EXECUTED:
                     if ( event.Info ()) event.Info ("main order "+(string)this.ticket+" executed, executing attached order",__FUNCTION__);
                     if (!attachedorder.Execute()) {
                        if (event.Warning ()) event.Warning ("attached order failed, closing main order "+this.ticket,__FUNCTION__);
                        this.Close();               
                     }
                     break;
                                          
                  case ES_EXECUTED:
                  case ES_VIRTUAL:
                     
                     attachedorder.Update();
                     //TODO: Switch
                     switch(attachedorder.State()) {
                        case ORDER_STATE_FILLED:
                           //CTrade* trade = ordermanager.trade;
                           bool closeresult = (GetLots() < attachedorder.GetLots());
                           bool thisclosed = (GetLots() <= attachedorder.GetLots());
                           int newticket = trade.CloseBy(this.ticket,attachedorder.ticket);
                           if (newticket >= 0) {
                              if ( event.Info ()) event.Info ("Order "+this.ticket+" closed by "+attachedorder.ticket+" new ticket: "+newticket,__FUNCTION__);
                              DeleteVStopLines();
                              this.ticket = newticket;
                              Update();                              
                              attachedorder.Update();   
                              if (closeresult) {
                                 if ( event.Info ()) event.Info ("Closing found ticket after CloseBy",__FUNCTION__);
                                 this.Close();
                              }        
                           } else if (thisclosed) {
                              attachedorder.Update();   
                              //this.OnTick();
                           }
                           break;
                        
                        case ORDER_STATE_PLACED:
                           if (GetLots() < attachedorder.GetLots()) {
                              //Print(this.orderinfo.GetLots()," ",attachedorder.orderinfo.GetLots());
                              //if ( event.Verbose ()) event.Verbose ("adjust volume from "+(string)attachedorder.volume+" to "+string(volume),__FUNCTION__);                           
                              if (CreateAttached(attachedorder.GetType(),GetLots(),attachedorder.Price(),0,attachedorder.name,attachedorder.comment)) {
                                 attachedorder.Cancel();
                              }
                           }                           
                     }
                     break;
                  }
               }      
               //END Checking Attached  
                                        
               break;
            case ORDER_STATE_CLOSED:
            case ORDER_STATE_DELETED:
            case ORDER_STATE_UNKNOWN:
               if (!this.closed) {   
                  //if ( event.Verbose ()) event.Verbose ("Order Closed",__FUNCTION__);
                  bool has_open_attached = false;
                  
                  //BEGIN Checking Attached
                  for (i = 0; i < attachedorders.Total(); i++) {
                     attachedorder = attachedorders.AttachedOrder(i);
                     if (attachedorder.executestate == ES_EXECUTED || attachedorder.executestate == ES_VIRTUAL) {                        
                        attachedorder.Update();
                        //TODO: Switch
                        if (attachedorder.State() == ORDER_STATE_PLACED) {
                           if ( event.Info ()) event.Info ("cancel order (main order fully closed)",__FUNCTION__);
                           if (!attachedorder.Cancel()) {
                              has_open_attached = true;
                           }
                        } else if (attachedorder.State() == ORDER_STATE_FILLED) {
                           if ( event.Info ()) event.Info ("close order (main order fully closed)",__FUNCTION__);
                           if (!attachedorder.Close()) {
                              has_open_attached = true;
                           }
                        }
                     }
                  }
                  //END Checking Attached
                                    
                  if (!has_open_attached) this.closed = true;
               }
               break;
               
            }
         //}
      }

   }
     