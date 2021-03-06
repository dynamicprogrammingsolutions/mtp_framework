//
#include "Loader.mqh"

#ifndef ORDER_H
#define ORDER_H
class COrder : public COrderBase
{
public:
   TraitGetType(classMT4Order)
   TraitNewObject(COrder)
   TraitAppAccess
   //TraitRefCount
   static int EventAttachedOrderFilled;
   
   /*int reference_count;
   
   virtual bool ReferenceCountActive()
   {
      return true;
   }
   
   virtual CAppObject* RefAdd()
   {
      reference_count++;
      //Print(__FUNCTION__,": reference count: "+reference_count+" ticket "+this.ticket+" id: "+id);
      return GetPointer(this);
   }

   virtual CAppObject* RefDel()
   {
      reference_count--;
      //Print(__FUNCTION__,": reference count: "+reference_count+" ticket "+this.ticket+" id: "+id);
      return GetPointer(this);
   }

   virtual void RefClean()
   {
      if (reference_count == 0) {
         //Print(__FUNCTION__,": no references for ticket: "+this.ticket+" id: "+id+" deleting...");
         delete GetPointer(this);
      }
   }*/
       
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
   
   virtual bool DoNotArchive() { return do_not_archive; }
   virtual bool DoNotDelete() { return do_not_delete; }
   
   //bool in_history;

   //COrder(int existing_ticket) ; 
   
   COrder() {            
      closetime = 0;
      attachedorder_place_on_pending = false;
      disable_vstops = false;
      sl_virtual = sl_virtual_default;
      tp_virtual = tp_virtual_default;
   };
   
   ~COrder() { delete this.orderinfo; }
   
   virtual void Initalize()
   {
      COrderBase::Initalize();
      Prepare(GetPointer(attachedorders));
   }
      
   virtual bool NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
      const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);     
      
   //static bool ExistingOrder(int ticket, COrderBase*& orderbase, COrderBase*& order, COrderBase*& attachedorder);
   
   virtual bool Closed() { return State()==ORDER_STATE_CLOSED && this.closed; }
   virtual bool Deleted() { return State()==ORDER_STATE_DELETED && this.closed; }
   virtual bool ClosedOrDeleted() { return Closed() || Deleted(); }
   
   virtual bool CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment);   
   bool CreateAttachedWithStops(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double sl, double tp, string _name, string _comment);
   virtual bool AddStopLoss(double in_price, double stopvolume = 0, string name = "");
   virtual bool AddTakeProfit(double in_price, double stopvolume = 0, string name = "");

   virtual bool AddStopLoss(CStopLoss* _sl, double stopvolume = 0, string name = "");
   virtual bool AddTakeProfit(CTakeProfit* _tp, double stopvolume = 0, string name = "");

   virtual void OnTick();
   
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      if (!file.WriteBool(disable_vstops)) return file.Error("disable_vstops",__FUNCTION__);
      if (!file.WriteBool(closed)) return file.Error("closed",__FUNCTION__);
      //if (!file.WriteObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);
      
      if (!COrderBase::Save(handle)) return file.Error("COrderBase",__FUNCTION__);

      return(true);
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return file.Error("invalid file",__FUNCTION__);           

      if (!file.ReadBool(disable_vstops)) return file.Error("disable_vstops",__FUNCTION__);
      if (!file.ReadBool(closed)) return file.Error("closed",__FUNCTION__);
      //if (!file.ReadObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);
      
      if (!COrderBase::Load(handle)) return file.Error("COrderBase",__FUNCTION__);

      return(true);
   }

protected:    
   virtual CAttachedOrder* NewAttachedOrderObject() { return(App().GetDependency(classOrder,classAttachedOrder)); } 
   
};

bool COrder::sl_virtual_default = false;
bool COrder::tp_virtual_default = false;

string COrder::attachedtoticket = "a=";
string COrder::stoploss_name = "sl";
string COrder::takeprofit_name = "tp";

int COrder::EventAttachedOrderFilled = 0;


bool COrder::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
   const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{
   //if ( event().Debug ()) event().Debug ("New Order",__FUNCTION__);
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
      //if (event().Warning ()) event().Warning ("Failed to execute retcode:"+(string)retcode,__FUNCTION__);
      return(false);
   }
   
   if (!use_normal_stops) {
      if (_stoploss > 0) AddStopLoss(_stoploss);
      if (_takeprofit > 0) AddTakeProfit(_takeprofit);
   }

   return(true);          
}

bool COrder::CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment)
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
         if (event().Info ()) event().Info ("Failed to add attached order",__FUNCTION__);
         delete attachedorder;
         return(false);
      }
      if (executestate == ES_EXECUTED && state_filled(state)) {
         if (event().Info ()) event().Info ("Execute Attached Order name:"+_name+" lot: "+(string)_volume+" price: "+(string)_price,__FUNCTION__);
         if (!attachedorder.Execute()) {
            if (event().Warning ()) event().Warning ("attached order failed, closing main order "+(string)this.ticket,__FUNCTION__);
            this.Close();               
         }
         //attachedorder.Update();
      } else {
         if (event().Info ()) event().Info ("Main order "+(string)this.ticket+" not filled yet (state:"+EnumToString(state)+"), waiting with executing attached order "+_name,__FUNCTION__);
      }
      return(true);
   //}
   return(false);
}


bool COrder::CreateAttachedWithStops(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _sl, double _tp, string _name, string _comment)
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
      attachedorder.SetStopLoss(_sl);
      attachedorder.SetTakeProfit(_tp);
      attachedorder.name = _name;
      attachedorder.comment = _comment;
      
      if (!attachedorders.Add(attachedorder)) {
         if (event().Info ()) event().Info ("Failed to add attached order",__FUNCTION__);
         delete attachedorder;
         return(false);
      }
      if (executestate == ES_EXECUTED && state_filled(state)) {
         if (event().Info ()) event().Info ("Execute Attached Order name:"+_name+" lot: "+(string)_volume+" price: "+(string)_price,__FUNCTION__);
         if (!attachedorder.Execute()) {
            if (event().Warning ()) event().Warning ("attached order failed, closing main order "+(string)this.ticket,__FUNCTION__);
            this.Close();               
         }
         //attachedorder.Update();
      } else {
         if (event().Info ()) event().Info ("Main order "+(string)this.ticket+" not filled yet (state:"+EnumToString(state)+"), waiting with executing attached order "+_name,__FUNCTION__);
      }
      return(true);
   //}
   return(false);
}

bool COrder::AddStopLoss(double in_price, double stopvolume = 0, string name = "")
{
   if (name == "") name = stoploss_name;
   if (stopvolume == 0) stopvolume = GetLots();
   ENUM_ORDER_TYPE attachedordertype;
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
   ENUM_ORDER_TYPE attachedordertype;

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

bool COrder::AddStopLoss(CStopLoss* _sl, double stopvolume = 0, string name = "")
{
   loadsymbol(this.symbol);
   _sl.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice());
   _sl.Reset();
   double thissl = _symbol.PriceRound(_sl.GetPrice());
   bool ret = AddStopLoss(thissl,stopvolume,name);
   //DeleteIf(_sl);
   return ret;
}

 bool COrder::AddTakeProfit(CTakeProfit* _tp, double stopvolume = 0, string name = "")
{
   loadsymbol(this.symbol);
   _tp.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice());
   _tp.Reset();
   double thistp = _symbol.PriceRound(_tp.GetPrice());
   bool ret = AddTakeProfit(thistp,stopvolume,name);
   //DeleteIf(_tp);
   return ret;
}

void COrder::OnTick()
{
   //if ( event().Debug ()) event().Debug ("Update Order "+ticket,__FUNCTION__);
   if (this.closed) return;
   
   COrderBase::OnTick();

   if (this.state == ORDER_STATE_CLOSED && this.closetime == 0) {               
      this.closetime = this.orderinfo.GetCloseTime();
   }
         
   if (executestate == ES_EXECUTED) {
      //if ( event().Debug ()) event().Debug ("State: "+state+" executestate: "+executestate,__FUNCTION__);
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
                  if ( event().Info ()) event().Info ("main order "+(string)this.ticket+" executed, executing attached order",__FUNCTION__);
                  if (!attachedorder.Execute()) {
                     if (event().Warning ()) event().Warning ("attached order failed, closing main order "+(string)this.ticket,__FUNCTION__);
                     this.Close();               
                  }
                  break;
                                       
               case ES_EXECUTED:
               case ES_VIRTUAL:
                  
                  attachedorder.Update();
                  //TODO: Switch
                  switch(attachedorder.State()) {
                     case ORDER_STATE_FILLED:
                        {
                           //CTrade* trade = ordermanager.trade;
                           bool closeresult = (GetLots() < attachedorder.GetLots());
                           bool thisclosed = (GetLots() <= attachedorder.GetLots());
                           int newticket = trade.CloseBy(this.ticket,attachedorder.ticket);
                           if (newticket >= 0) {
                              if ( event().Info ()) event().Info ("Order "+(string)this.ticket+" closed by "+(string)attachedorder.ticket+" new ticket: "+(string)newticket,__FUNCTION__);
                              DeleteVStopLines();
                              this.ticket = newticket;
                              Update();                              
                              attachedorder.Update();   
                              if (closeresult) {
                                 if ( event().Info ()) event().Info ("Closing found ticket after CloseBy",__FUNCTION__);
                                 this.Close();
                              }        
                           } else if (thisclosed) {
                              attachedorder.Update();   
                              //this.OnTick();
                           }
                           TRIGGER(COrder::EventAttachedOrderFilled);
                        }
                        break;
                     
                     case ORDER_STATE_PLACED:
                        if (GetLots() < attachedorder.GetLots()) {
                           //Print(this.orderinfo.GetLots()," ",attachedorder.orderinfo.GetLots());
                           //if ( event().Verbose ()) event().Verbose ("adjust volume from "+(string)attachedorder.volume+" to "+string(volume),__FUNCTION__);                           
                           if (CreateAttached(attachedorder.GetType(),GetLots(),attachedorder.GetOpenPrice(),0,attachedorder.name,attachedorder.comment)) {
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
               //if ( event().Verbose ()) event().Verbose ("Order Closed",__FUNCTION__);
               bool has_open_attached = false;
               
               //BEGIN Checking Attached
               for (i = 0; i < attachedorders.Total(); i++) {
                  attachedorder = attachedorders.AttachedOrder(i);
                  if (attachedorder.executestate == ES_EXECUTED || attachedorder.executestate == ES_VIRTUAL) {                        
                     attachedorder.Update();
                     //TODO: Switch
                     if (attachedorder.State() == ORDER_STATE_PLACED) {
                        if ( event().Info ()) event().Info ("cancel order (main order fully closed)",__FUNCTION__);
                        if (!attachedorder.Cancel()) {
                           has_open_attached = true;
                        }
                     } else if (attachedorder.State() == ORDER_STATE_FILLED) {
                        if ( event().Info ()) event().Info ("close order (main order fully closed)",__FUNCTION__);
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
  
#endif