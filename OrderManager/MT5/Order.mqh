#include "Loader.mqh"

#define ORDER_H
class COrder : public COrderBase
{
public:
   virtual int Type() const { return classMT5Order; }
   TraitNewObject(COrder())
   //TraitRefCount
   /*
   int reference_count;
   
   virtual bool ReferenceCountActive()
   {
      return true;
   }
   
   virtual CAppObject* RefAdd()
   {
      reference_count++;
      Print("reference count: "+(string)reference_count+" ticket "+(string)this.ticket);
      return GetPointer(this);
   }

   virtual CAppObject* RefDel()
   {
      reference_count--;
      Print("reference count: "+(string)reference_count+" ticket "+(string)this.ticket);
      return GetPointer(this);
   }

   virtual void RefClean()
   {
      if (reference_count == 0) {
         Print("no references for ticket: "+this.ticket+" deleting...");
         delete GetPointer(this);
      }
   }
   */
protected:
   static string attachedtoticket;
   static string stoploss_name;
   static string takeprofit_name;
   
   double sl;
   double tp;
   bool sl_set;
   bool tp_set;

public:
   CAttachedOrderArray attachedorders;

   bool closed;
   bool close_attempted;
   
   bool do_not_archive;
   bool do_not_delete;

   double closedvolume;
   datetime closetime;
   datetime lastclosetime;
   
   double lastcloseprice;
   
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      Print(__FUNCTION__+" Start Saving pos: "+(string)file.Tell());
      
      file.WriteDouble(sl);
      file.WriteDouble(tp);
      file.WriteBool(sl_set);
      file.WriteBool(tp_set);
      file.WriteBool(closed);
      file.WriteBool(close_attempted);
      file.WriteBool(do_not_archive);
      file.WriteBool(do_not_delete);
      file.WriteDouble(closedvolume);
      file.WriteDateTime(closetime);
      file.WriteDateTime(lastclosetime);
      file.WriteDouble(lastcloseprice);

      Print(__FUNCTION__+" Start Saving AttachedOrders pos: "+(string)file.Tell());

      if (!file.WriteObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);
      
      Print(__FUNCTION__+" Start Saving OrderBase pos: "+(string)file.Tell());
      
      if (!COrderBase::Save(handle)) return file.Error("COrderBase",__FUNCTION__);

      Print(__FUNCTION__+" End Saving pos: "+(string)file.Tell());

      return(true);
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return file.Error("invalid file",__FUNCTION__);           

      Print(__FUNCTION__+" Start Loading pos: "+(string)file.Tell());

      file.ReadDouble(sl);
      file.ReadDouble(tp);
      file.ReadBool(sl_set);
      file.ReadBool(tp_set);
      file.ReadBool(closed);
      file.ReadBool(close_attempted);
      file.ReadBool(do_not_archive);
      file.ReadBool(do_not_delete);
      file.ReadDouble(closedvolume);
      file.ReadDateTime(closetime);
      file.ReadDateTime(lastclosetime);
      file.ReadDouble(lastcloseprice);

      Print(__FUNCTION__+" Start Loading AttachedOrders pos: "+(string)file.Tell());
      
      if (!file.ReadObject(GetPointer(attachedorders))) return file.Error("attachedorders",__FUNCTION__);

      Print(__FUNCTION__+" Start Loading OrderBase pos: "+(string)file.Tell());
      
      if (!COrderBase::Load(handle)) return file.Error("COrderBase",__FUNCTION__);

      Print(__FUNCTION__+" End Loading pos: "+(string)file.Tell());

      return(true);
   }

   COrder() {
      closetime = 0;
      lastclosetime = 0;
   };
   ~COrder() {};   
   
   virtual void Initalize()
   {
      COrderBase::Initalize();
      Prepare(GetPointer(attachedorders));
   }
   
   bool CheckOrderInfo() { if (CheckPointer(orderinfo) == POINTER_INVALID) return(false); else return(true); }   
   
   virtual int GetProfitTicks() { if (State() == ORDER_STATE_PLACED) return(0); else return(gettakeprofitticks(this.symbol, this.GetType(), this.GetClosePrice(), this.GetOpenPrice())); }
   
   virtual double GetClosePrice() {
      if (lastcloseprice != 0) return lastcloseprice;
      else return CurrentPrice();
   }
   
   virtual datetime GetCloseTime() { return lastclosetime; }
   
   virtual bool NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price, const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);
   
   virtual bool CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment);
   
   virtual bool AddStopLoss(double _price, double stopvolume = 0);
   virtual bool AddTakeProfit(double _price, double stopvolume = 0);
   bool AddStopLoss(CStopLoss* _stoploss, double stopvolume = 0);
   
   virtual bool Closed() { return State()==ORDER_STATE_FILLED && this.closed; }
   virtual bool Deleted() { return State()==ORDER_STATE_CANCELED && this.closed; }
   virtual bool ClosedOrDeleted() { return Closed() || Deleted(); }

   // This doesn't result the same as in MT4 for partially closed orders
   virtual double GetLots() { return(volume); }

   virtual bool Close(double closevolume = 0, double closeprice = 0);
   virtual void OnTick();
   
   virtual void OnTradeTransaction(
      const MqlTradeTransaction&    trans,     // trade transaction structure 
      const MqlTradeRequest&        request,   // request structure 
      const MqlTradeResult&         result     // response structure 
   ) {
      CDealInfo deal;
      if (trans.type == TRADE_TRANSACTION_DEAL_ADD) {
         if (HistoryDealSelect(trans.deal)) {
            deal.Ticket(trans.deal);
            string str;
            long positionId;
            ENUM_ORDER_TYPE orderType;
            if (GetOrderInfoB()) {
               positionId = orderinfo.PositionId();
               orderType = orderinfo.OrderType();
            }
            CHistoryOrderInfo dealOrderInfo;
            if (HistoryOrderSelect(deal.Order())) {
               dealOrderInfo.Ticket(deal.Order());
               if (dealOrderInfo.PositionId() == positionId) {
                  if ((ordertype_long(orderType) && ordertype_short(dealOrderInfo.OrderType())) || (ordertype_short(orderType) && ordertype_long(dealOrderInfo.OrderType()))) {
                     Print("ticket ",this.ticket," closed by deal: ",deal.Ticket()," volume: ",deal.Volume());
                     this.lastclosetime = TimeCurrent();
                     this.lastcloseprice = deal.Price();
                     this.closedvolume+=deal.Volume();
                  }
               }
            }
         }
      }
   }
   
   
};

string COrder::attachedtoticket = "attachedtoticket=";
string COrder::stoploss_name = "stoploss";
string COrder::takeprofit_name = "takeprofit";

bool COrder::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
   const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{

   symbol = in_symbol;
   SetOrderType(_ordertype);
   SetLots(_volume);
   SetPrice(_price);
   SetComment(_comment);
   SetExpiration(_expiration);
   SetStopLoss(_stoploss);
   SetTakeProfit(_takeprofit);

   //if (event.Info ()) event.Info ("Execute New Order",__FUNCTION__);
   if (!Execute()) {
      if (event.Warning ()) event.Warning ("Failed to execute retcode:"+(string)retcode,__FUNCTION__);
      return(false);
   }
   
   //if (_stoploss > 0) AddStopLoss(_stoploss);
   //if (_takeprofit > 0) AddTakeProfit(_takeprofit);
   
   if (COrderBase::waitforexecute) {
      WaitForExecute();
   }
   
   return(true);          
}

bool COrder::CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment)
{
   CAttachedOrder *attachedorder;
   if (_price > 0 || ordertype_market(_ordertype)) {
      attachedorder = App().GetDependency(classOrder,classAttachedOrder);
      //attachedorder.ordermanager = this.ordermanager;
      attachedorder.symbol = this.symbol;
      attachedorder.ordertype = _ordertype;
      attachedorder.volume = _volume;
      attachedorder.price = _price;
      attachedorder.limit_price = _limit_price;
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
            if (event.Warning ()) event.Warning ("attached order failed, closing main order "+(string)this.ticket,__FUNCTION__);
            this.Close(volume);               
         }
         attachedorder.Update();
      } else {
         if (event.Info ()) event.Info ("Main order "+(string)this.ticket+" not filled yet, waiting with executing attached order "+_name,__FUNCTION__);
      }
      return(true);
   }
   if (event.Info ()) event.Info ("Failed to add attached order: price is 0",__FUNCTION__);
   return(false);
}

bool COrder::AddStopLoss(double _price, double stopvolume = 0)
{
   if (_price == 0) return false;
   if (stopvolume == 0) stopvolume = volume;
   ENUM_ORDER_TYPE attachedordertype;
   if (ordertype == ORDER_TYPE_BUY || ordertype == ORDER_TYPE_BUY_LIMIT || ordertype == ORDER_TYPE_BUY_STOP) attachedordertype = ORDER_TYPE_SELL_STOP;
   else if (ordertype == ORDER_TYPE_SELL || ordertype == ORDER_TYPE_SELL_LIMIT || ordertype == ORDER_TYPE_SELL_STOP) attachedordertype = ORDER_TYPE_BUY_STOP;
   else return(false);
   if (!CreateAttached(attachedordertype,stopvolume,_price,0,stoploss_name,attachedtoticket+(string)ticket)) return(false);
   return(true);
}

bool COrder::AddTakeProfit(double _price, double stopvolume = 0)
{
   if (_price == 0) return false;
   if (stopvolume == 0) stopvolume = volume;
   ENUM_ORDER_TYPE attachedordertype;
   if (ordertype == ORDER_TYPE_BUY || ordertype == ORDER_TYPE_BUY_LIMIT || ordertype == ORDER_TYPE_BUY_STOP) attachedordertype = ORDER_TYPE_SELL_LIMIT;
   else if (ordertype == ORDER_TYPE_SELL || ordertype == ORDER_TYPE_SELL_LIMIT || ordertype == ORDER_TYPE_SELL_STOP) attachedordertype = ORDER_TYPE_BUY_LIMIT;
   else return(false);
   if (!CreateAttached(attachedordertype,stopvolume,_price,0,takeprofit_name,attachedtoticket+(string)ticket)) return(false);
   return(true);
}

bool COrder::AddStopLoss(CStopLoss* _stoploss, double stopvolume = 0)
{
   ENUM_ORDER_TYPE attachedordertype;
   if (ordertype == ORDER_TYPE_BUY || ordertype == ORDER_TYPE_BUY_LIMIT || ordertype == ORDER_TYPE_BUY_STOP) attachedordertype = ORDER_TYPE_SELL_STOP;
   else if (ordertype == ORDER_TYPE_SELL || ordertype == ORDER_TYPE_SELL_LIMIT || ordertype == ORDER_TYPE_SELL_STOP) attachedordertype = ORDER_TYPE_BUY_STOP;
   else return(false);

   _stoploss.SetOrderType(this.ordertype).SetSymbol(this.symbol).SetEntryPrice(this.Price());
   //Print(this.Price()," ",_stoploss.GetPrice()," ",EnumToString(attachedordertype));
   AddStopLoss(_stoploss.GetPrice(),stopvolume);
   return(true);
}

/*bool COrder::AddTakeProfit(CTakeProfit* _takeprofit, double stopvolume = 0)
{
   if (_price == 0) return false;
   if (stopvolume == 0) stopvolume = volume;
   ENUM_ORDER_TYPE attachedordertype;
   if (ordertype == ORDER_TYPE_BUY || ordertype == ORDER_TYPE_BUY_LIMIT || ordertype == ORDER_TYPE_BUY_STOP) attachedordertype = ORDER_TYPE_SELL_LIMIT;
   else if (ordertype == ORDER_TYPE_SELL || ordertype == ORDER_TYPE_SELL_LIMIT || ordertype == ORDER_TYPE_SELL_STOP) attachedordertype = ORDER_TYPE_BUY_LIMIT;
   else return(false);
   if (!CreateAttached(attachedordertype,stopvolume,_price,0,takeprofit_name,attachedtoticket+(string)ticket)) return(false);
   return(true);
}*/


bool COrder::Close(double closevolume = 0, double closeprice = 0)
{
   activity = activity | (ushort)ACTIVITY_CLOSE;
   close_attempted = true;
   
   if (event.Verbose ()) event.Verbose ("Closing Order closevolume="+(string)closevolume+" closeprice="+(string)closeprice,__FUNCTION__);
   //CTrade trade;
   ENUM_ORDER_TYPE closeordertype;
   
   if (ordertype_pending(ordertype)) {
      if (!state_filled(state)) {            
         if (event.Notice ()) event.Notice ("Order to close is not filled",__FUNCTION__);
         return(this.Cancel());
      }
   }
   
   if (ordertype_long(ordertype)) { closeordertype = ORDER_TYPE_SELL; }
   else if (ordertype_short(ordertype)) { closeordertype = ORDER_TYPE_BUY; }
   else {
      if (event.Error ()) event.Error ("Invalid Order Type",__FUNCTION__);
      return(false);
   }
   
   //if (event.Verbose ()) event.Verbose ("closeordertype: "+(string)closeordertype,__FUNCTION__);
   
   if (closeprice == 0) {
      loadsymbol(symbol);
      if (closeordertype == ORDER_TYPE_SELL) { closeprice = _symbol.Bid(); }
      else if (closeordertype == ORDER_TYPE_BUY) { closeprice = _symbol.Ask(); }
   }
   
   //if (event.Verbose ()) event.Verbose ("closeprice: "+(string)closeprice,__FUNCTION__);
   
   if (closevolume == 0) closevolume = volume-closedvolume;
   if (closevolume > volume-closedvolume) closevolume = volume-closedvolume;
   
   //if (event.Verbose ()) event.Verbose ("closevolume="+(string)closevolume+" volume="+(string)volume+" closedvolume="+(string)closedvolume,__FUNCTION__);
   
   if (this.CreateAttached(closeordertype, closevolume, closeprice, 0, "close", attachedtoticket+(string)ticket)) {
      if (event.Info ()) event.Info ("attached order \"close\" is created");

      lastcloseprice = closeprice;
      lastclosetime = TimeCurrent();
      
      this.OnTick();
      
      return(true);
   } else {
      if (event.Error ()) event.Error ("Failed to create attached order type:"+(string)closeordertype+" volume:"+(string)closevolume+" price:"+(string)closeprice,__FUNCTION__);
   }
   
   return(false);
}

void COrder::OnTick()
{
   if (this.closed) return;

   COrderBase::OnTick();
   
   if (executestate == ES_EXECUTED) {
       
      CAttachedOrder *attachedorder;     
      
      bool mainclosed = false;
      
      switch (this.state) {
      case ORDER_STATE_PLACED:
         break;
      case ORDER_STATE_PARTIAL:
      case ORDER_STATE_FILLED:
         for (int i = 0; i < attachedorders.Total(); i++) {
            attachedorder = attachedorders.AttachedOrder(i);
            switch (attachedorder.executestate) {
            case ES_NOT_EXECUTED:
               if (event.Info ()) event.Info ("main order "+(string)this.ticket+" executed, executing attached order "+(string)attachedorder.ticket,__FUNCTION__);
               if (!attachedorder.Execute() && !close_attempted) {
                  if (event.Warning ()) event.Warning ("attached order failed, closing main order "+(string)this.ticket,__FUNCTION__);
                  this.Close(volume);               
               }
               break;
            case ES_EXECUTED:
               attachedorder.Update();
               switch(attachedorder.State()) {
               case ORDER_STATE_FILLED:
               case ORDER_STATE_PARTIAL:
                  if (!attachedorder.filling_updated) {
                     // if (event.Verbose ()) event.Verbose ("closedvolume increased: "+(string)attachedorder.volume);
                     if ((ordertype_long(this.ordertype) && ordertype_short(attachedorder.ordertype)) || (ordertype_short(this.ordertype) && ordertype_long(attachedorder.ordertype)))
                        closedvolume += attachedorder.volume;
                     else
                        closedvolume -= attachedorder.volume;
                     // UNCOMPLETE CALCULATION OF CLOSE PRICE!!! DOESN'T WORK WITH PARTIAL EXITS
                     // Simple solution would be to calculate average close price
                     // Other inaccuracy is that it calculates with the projected close price
                     lastcloseprice = attachedorder.price;
                     lastclosetime = attachedorder.filltime;
                     //lastclosetime = attachedorder.
                     attachedorder.filling_updated = true;                     
                  }
                  break;
               case ORDER_STATE_PLACED:
                  if (NormalizeDouble(volume-closedvolume,8) > 0 && volume-closedvolume < attachedorder.volume) {
                     // Adjust attached orders' volume after partial close
                     // if (event.Verbose ()) event.Verbose ("adjust volume from "+(string)attachedorder.volume+" to "+string(volume-closedvolume),__FUNCTION__);
                     attachedorder.Cancel();
                     CreateAttached(attachedorder.ordertype,volume-closedvolume,attachedorder.price,attachedorder.limit_price,attachedorder.name,attachedorder.comment);
                  }
                  break;
               }
            }
         }
         
         if (!mainclosed && NormalizeDouble(volume-closedvolume,8) <= 0) {
            // if (event.Verbose ()) event.Verbose ("closed=true");
            closetime = lastclosetime;
            mainclosed = true;
            event.Info("Main Order Closed",__FUNCTION__);
         }
         
         break;
      case ORDER_STATE_CANCELED:
      case ORDER_STATE_EXPIRED:
      case ORDER_STATE_REJECTED:
         mainclosed = true;
         break;
      }
      
      if (mainclosed) {
         bool has_open_attached = false;
         for (int i = 0; i < attachedorders.Total(); i++) {
            attachedorder = attachedorders.AttachedOrder(i);
            if (state_undone(attachedorder.State())) {
               // if (event.Verbose ()) event.Verbose ("cancel order (main order fully closed)",__FUNCTION__);
               if (!attachedorder.Cancel()) {
                  has_open_attached = true;
               } 
            }
         }
         if (!has_open_attached) {
            if (NormalizeDouble(volume-closedvolume,8) == 0) {
               this.closed = true;
               event.Info("Order Closed: "+(string)this.Id(),__FUNCTION__);
            } else if (volume-closedvolume < 0) {
               loadsymbol(symbol);
               if (_symbol.LotRound(closedvolume-volume) == closedvolume-volume) {
                  event.Warning("Too many attached order triggered, opening balance order",__FUNCTION__);
                  ENUM_ORDER_TYPE balancetype = ordertype_long(this.ordertype)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
                  CreateAttached(balancetype,closedvolume-volume,0,0,"balance","");
                  closed = true;
                  event.Info("Order Closed: "+(string)this.Id(),__FUNCTION__);
               }
            }
         }
      }
      
   }
   
}
