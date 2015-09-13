#include "Loader.mqh"

enum ENUM_EXECUTE_STATE
{
   ES_NOT_EXECUTED,
   ES_EXECUTED,
   ES_CANCELED
};

enum ENUM_ACTIVITY {
   ACTIVITY_EXECUTE = 1,
   ACTIVITY_MODIFY = 2,
   ACTIVITY_CLOSE = 4,
   ACTIVITY_DELETE = 8, 
   ACTIVITY_STATECHANGE = 16,
   ACTIVITY_NOTHING = 32,
   ACTIVITY_CUSTOM1 = 64,
   ACTIVITY_CUSTOM2 = 128,
   ACTIVITY_CUSTOM3 = 256,
};

// *** COrderBase ***

class COrderBase : public COrderBaseBase
{
public:
   static ushort activity; //not implemented
  
   static CTrade* trade_default;
   
   static int magic_default; //not implemented
   
   static bool delete_stoploss_objects;
   static bool delete_takeprofit_objects;
   static bool delete_entry_objects;
   static bool delete_mm_objects;

   //static bool lotround_execute;
   
   static int maxid;

   static bool waitforexecute;
   static int waitforexecute_max;
   static int waitforexecute_sleep;
   
   CTrade* trade;

   ENUM_EXECUTE_STATE executestate;

   ENUM_ORDER_STATE state;

public:
   ulong ticket;
   string symbol;
   
   ENUM_ORDER_TYPE ordertype;
   double volume;
   double price;
   datetime expiration;

public:
   int id;
   string comment;
   int magic; // magic is not sent to server, if "restore orders from server" is developed, it will be needed

   bool selectedishistory;
   COrderInfoBase *orderinfo;
   COrderInfoV *orderinfov;
   CHistoryOrderInfoV *historyorderinfov;
   
   uint retcode;
   datetime executetime;   
   datetime filltime;

   bool price_set;
   bool expiration_set;
   bool typetime_set;

   double openprice;
   double limit_price;
   ENUM_ORDER_TYPE_TIME type_time;   

public:
   
   COrderBase() {
    
      this.id = maxid+1;
      maxid = this.id;     

      if (trade_default == NULL) trade_default = new CTrade();

      trade = trade_default;
      
      ticket = -1;
      executestate = ES_NOT_EXECUTED;
      state = NULL;

      magic = magic_default;

  };
  
   ~COrderBase() {
     delete this.orderinfo;
     delete this.orderinfov;
     delete this.historyorderinfov;
  };
   
   bool Isset() { return(executestate != ES_NOT_EXECUTED); }
      
   COrderInfoBase* GetOrderInfo();
   bool GetOrderInfo(COrderInfoBase *_orderinfo);
   bool GetOrderInfoB();
   bool CheckOrderInfo() { if (CheckPointer(orderinfo) == POINTER_INVALID) return(false); else return(true); }   

   bool Execute();
   bool WaitForExecute();
   bool Cancel();
   
   virtual bool Modify();
   bool Modify(double m_price, ENUM_ORDER_TYPE_TIME m_type_time, datetime m_expiration);
   bool ModifyPrice(double m_price);
   virtual bool Update();
   virtual void OnTick();

   ulong GetTicket() { return(this.ticket); }
   int GetMagicNumber() { return(this.magic); }
   string GetSymbol() { return(this.symbol); }
   string GetComment() { return(this.comment); }
      
   bool Select() { if (this.executestate == ES_EXECUTED) return(GetOrderInfoB()); else return(false); } 
   
   ENUM_ORDER_STATE State();
   //void State(ENUM_ORDER_STATE newstate);
   
   double Price();
   double CurrentPrice();
   datetime GetOpenTime() { return(MathMax(this.executetime,this.filltime)); }
   double GetOpenPrice() { return(this.price); }
   
   void SetOrderType(const ENUM_ORDER_TYPE value) { if (executestate == ES_NOT_EXECUTED) ordertype=value; else Print("Cannot change executed order data (ordertype)"); }
   void SetMagic(const int value) { if (executestate == ES_NOT_EXECUTED) magic=value; else Print("Cannot change executed order data (magic)"); }
   void SetSymbol(const string value) { if (executestate == ES_NOT_EXECUTED) symbol=value; else Print("Cannot change executed order data (symbol)"); }
   void SetComment(const string value) { if (executestate == ES_NOT_EXECUTED) comment=value; else Print("Cannot change executed order data (comment)"); }
   void SetLots(const double value) { if (executestate == ES_NOT_EXECUTED) volume=value; else Print("Cannot change executed order data (lots)"); }
   
   void SetExpiration(const datetime value) { expiration_set = true; if (executestate != ES_CANCELED) expiration = value; else Print("Cannot change canceled order data (expiration)"); }
   void SetPrice(const double value) { price_set = true; if (executestate != ES_CANCELED) price = value; else Print("Cannot change canceled order data (price)"); }
   void SetTypeTime(const ENUM_ORDER_TYPE_TIME value) { typetime_set = true; if (executestate != ES_CANCELED) type_time = value; else Print("Cannot change canceled order data (typetime)"); }
   
   static void DeleteIf(CStopLoss* obj) { if (delete_stoploss_objects) delete obj; }
   static void DeleteIf(CTakeProfit* obj) { if (delete_takeprofit_objects) delete obj; }
   static void DeleteIf(CEntry* obj) { if (delete_entry_objects) delete obj; }
   static void DeleteIf(CMoneyManagement* obj) { if (delete_mm_objects) delete obj; }

};

CTrade* COrderBase::trade_default = NULL;

ushort COrderBase::activity = ACTIVITY_NOTHING;
int COrderBase::magic_default = 0;
int COrderBase::maxid = 0;

bool COrderBase::delete_stoploss_objects = true;
bool COrderBase::delete_takeprofit_objects = true;
bool COrderBase::delete_entry_objects = true;
bool COrderBase::delete_mm_objects = false;

bool COrderBase::waitforexecute = true;
int COrderBase::waitforexecute_max = 600;
int COrderBase::waitforexecute_sleep = 100;

// *** CAttachedOrder ***

class CAttachedOrder : public COrderBase
{
public:
   string name;
   bool filling_updated;
   static CAttachedOrder* Null() { return(new CAttachedOrder()); }
};

// *** CAttachedOrderArray ***

class CAttachedOrderArray : public CArrayObj
{
public:
   CAttachedOrderArray() {};
   ~CAttachedOrderArray() {};
   CAttachedOrder    *AttachedOrder(int nIndex){return((CAttachedOrder*)CArrayObj::At(nIndex));}   
};

// *** COrder ***

class COrder : public COrderBase
{
protected:
   string attachedtoticket;
   string stoploss_name;
   string takeprofit_name;

public:
   CAttachedOrderArray attachedorders;

   bool closed;
   bool do_not_archive;
   bool do_not_delete;

   double closedvolume;
   datetime closetime;
   datetime lastclosetime;
   
   double lastcloseprice;

   COrder() {
      attachedtoticket = "attachedtoticket=";
      stoploss_name = "stoploss";
      takeprofit_name = "takeprofit";
      closetime = 0;
      lastclosetime = 0;
   };
   ~COrder() {};
   
   bool CheckOrderInfo() { if (CheckPointer(orderinfo) == POINTER_INVALID) return(false); else return(true); }   
   ENUM_ORDER_TYPE GetType() { return(this.ordertype); }
   int GetProfitTicks() { if (State() == ORDER_STATE_PLACED) return(0); else return(gettakeprofitticks(this.symbol, this.GetType(), this.CurrentPrice(), this.Price())); }
   
   bool COrder::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price, const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);
   
   bool CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment);
   
   bool AddStopLoss(double _price, double stopvolume = 0);
   bool AddTakeProfit(double _price, double stopvolume = 0);
   
   bool AddStopLoss(CStopLoss* _stoploss, double stopvolume = 0);
   
   bool ModifyStopLoss(double _price);
   bool ModifyTakeProfit(double _price);
   bool RemoveStopLoss(); // TODO: not suitable for removing and then replacing the SL
   double GetLots() {  return(volume-closedvolume);  }

   bool RemoveTakeProfit();
   int GetStopLossTicks();
   double GetStopLoss();
   CAttachedOrder* GetStopLossOrder();
   int GetTakeProfitTicks();
   double GetTakeProfit();
   CAttachedOrder *GetTakeProfitOrder();
   bool Close(double closevolume = 0, double closeprice = 0);
   virtual void OnTick();
   
   
};



/*class COrderManagerBase : public CObject
{
public:
    virtual COrder* NewOrderObject() { return(new COrder()); }
    virtual CAttachedOrder* NewAttachedOrderObject() { return(new CAttachedOrder()); }  
};*/

class COrderArray : public CArrayObj
{
public:
   COrderArray() {};
   ~COrderArray() {};
   COrder    *Order(int nIndex){
      CObject *at;
      at = CArrayObj::At(nIndex);
      if (at == NULL) return(NULL);
      else return((COrder*)at);
   }
};






// ***********************************************
// |--------------- COrderBase ------------------|
// ***********************************************



ENUM_ORDER_STATE COrderBase::State()
{
   if (this.executestate == ES_EXECUTED && state_undone(this.state)) {
      ENUM_ORDER_STATE oldstate = state;            
      this.state = CheckOrderInfo()?this.orderinfo.State():(ENUM_ORDER_STATE)-1;
      if (oldstate != state) {
         activity = activity | (ushort)ACTIVITY_STATECHANGE;
      }
   }
   return(this.state);
}

/*void COrderBase::State(ENUM_ORDER_STATE newstate)
{
   this.state = newstate;
}*/

double COrderBase::Price()
{      
   if (this.executestate == ES_EXECUTED) {
      double _price = 0;
      if (CheckOrderInfo()) {
         _price = this.orderinfo.PriceOpen();
      }
      return(_price);
   } else {
      return(this.price);
   }
}

double COrderBase::CurrentPrice()
{
   if (!state_filled(this.state)) return(0);
   loadsymbol(symbol,__FUNCTION__);
   if (ordertype_long(this.ordertype)) return(_symbol.Bid());
   if (ordertype_short(this.ordertype)) return(_symbol.Ask());
   return(0);
}

COrderInfoBase* COrderBase::GetOrderInfo()
{
   if (!isset(this.orderinfov)) this.orderinfov = new COrderInfoV();
   if (this.orderinfov.Select(ticket)) {
      selectedishistory = false;
      orderinfo = (COrderInfoBase*)(this.orderinfov);
      return(orderinfo);
   }

   if (!isset(this.historyorderinfov)) this.historyorderinfov = new CHistoryOrderInfoV();
   if (this.historyorderinfov.Ticket(ticket)) {         
      selectedishistory = true;
      orderinfo = (COrderInfoBase*)(this.historyorderinfov);
      return(orderinfo);
   }
   this.orderinfo = NULL;
   return(NULL);
}

bool COrderBase::GetOrderInfo(COrderInfoBase *_orderinfo)
{
   _orderinfo = GetOrderInfo();
   return(orderinfo != NULL);
}

bool COrderBase::GetOrderInfoB()
{
   GetOrderInfo();
   //if (event.Verbose ()) event.Verbose ("orderinfo != NULL:"+(orderinfo != NULL),__FUNCTION__);
   return(orderinfo != NULL);
}


bool COrderBase::Execute()
{
   activity = activity | (ushort)ACTIVITY_EXECUTE;
   //if (event.Info ()) event.Info ("Execute order "+(string)this.id+" type="+(string)ordertype,__FUNCTION__);
   //CTrade trade;
   CHistoryOrderInfo historyorder;
   if (executestate == ES_NOT_EXECUTED) {
      bool success;
      if (ordertype_market(ordertype)) {
         if (price == 0) {
            loadsymbol(symbol,__FUNCTION__);
            if (ordertype == ORDER_TYPE_SELL) { price = _symbol.Bid(); }
            else if (ordertype == ORDER_TYPE_BUY) { price = _symbol.Ask(); }
         }
         success = trade.PositionOpen(symbol,ordertype,volume,price,0,0,comment);
      } else if (ordertype_pending(ordertype)) {
         if (price > 0) {
            success = trade.OrderOpen(symbol,ordertype,volume,limit_price,price,0,0,type_time,expiration,comment);
         } else {
            if (event.Warning ()) event.Warning ("No Price",__FUNCTION__);
         }
      }
      if (success) {
         if (trade.ResultOrder() > 0) {
            ticket = trade.ResultOrder();
            this.retcode = trade.ResultRetcode();
            if (event.Info ()) event.Info ("Order "+(string)this.id+" Executed. Ticket:"+(string)ticket,__FUNCTION__);
            executestate = ES_EXECUTED;   
            Update();
            return(true);
         } else {
            retcode = trade.ResultRetcode();
            if (event.Warning ()) event.Warning ("No Ticket in trade result retcode: "+(string)trade.ResultRetcode(),__FUNCTION__);
         } 
      } else {
         retcode = trade.ResultRetcode();
         if (event.Warning ()) event.Warning ("Order "+(string)this.id+" Open Failed - ordertype:"+(string)ordertype+", volume:"+(string)volume+", price:"+(string)price,__FUNCTION__);         
      }
      
   } else {
      if (executestate == ES_CANCELED) {
         if (event.Info ()) event.Info ("Order "+(string)this.id+" Already Canceled");
      } else if (executestate == ES_EXECUTED) {
         if (event.Info ()) event.Info ("Order "+(string)this.id+" Already Executed");
      }
   }
   return(false);
}

bool COrderBase::WaitForExecute()
{
   if (executestate == ES_EXECUTED && ordertype_market(this.ordertype)) {
      for (int i = 0; i < waitforexecute_max; i++) {
         this.State();
         if (event.Info ()) event.Info ("Waiting for execute: "+(string)this.id,__FUNCTION__);
         if (state_filled(state)) return(true);
         if (state_canceled(state)) return(false);
         Sleep(waitforexecute_sleep);
      }
      return(false);
   } else {
      return(false);
   }
}

bool COrderBase::Cancel()
{
   activity = activity | (ushort)ACTIVITY_DELETE;      
   if (event.Verbose ()) event.Verbose ("Cancel ticket="+(string)ticket,__FUNCTION__);
   //CTrade trade;
   if (executestate == ES_EXECUTED) {
      if (state <= ORDER_STATE_PLACED) {
         if (trade.OrderDelete(ticket)) {
            Update();
         } else {
            if (event.Warning ()) event.Warning ("Order Delete Failed",__FUNCTION__);
         }
      } else if (state == ORDER_STATE_CANCELED || state == ORDER_STATE_REJECTED || state == ORDER_STATE_EXPIRED) {
         if (event.Info ()) event.Info ("Order Already Canceled, state:"+(string)state,__FUNCTION__);
      } else if (state == ORDER_STATE_PARTIAL || state == ORDER_STATE_FILLED) {
         if (event.Info ()) event.Info ("Order Already Filled, state:"+(string)state,__FUNCTION__);
      } else {
         if (event.Info ()) event.Info ("Invalid Order State",__FUNCTION__);
      }
   } else if (executestate == ES_NOT_EXECUTED) {
      executestate = ES_CANCELED;
      if (event.Info ()) event.Info ("Order Not Yet Executed, Execution Canceled",__FUNCTION__);
   } else if (executestate == ES_CANCELED) {
      if (event.Info ()) event.Info ("Order Not Executed, Execution Already Canceled",__FUNCTION__);
   } else {
      if (event.Error ()) event.Error ("Invalid Execute State",__FUNCTION__);
      return(false);
   }
   return(true);
}

bool COrderBase::Modify()
{
   activity = activity | (ushort)ACTIVITY_MODIFY;
   if (Select()) {
      loadsymbol(this.symbol,__FUNCTION__);
      if (!price_set) price = this.Price();
      else price = _symbol.PriceRound(price);
      if (!expiration_set) expiration = orderinfo.TimeExpiration();
      if (!typetime_set) type_time = orderinfo.TypeTime();
      if ((price_set && price != this.Price()) || (expiration_set && expiration != orderinfo.TimeExpiration()) || (typetime_set && type_time != orderinfo.TypeTime())) {
         price_set = false;
         expiration_set = false;
         typetime_set = false;
         if (trade.OrderModify(ticket,price,0,0,type_time,expiration)) {
            Update();
            return(true);
         } else return(false);
      } else {
         price_set = false;
         expiration_set = false;
         typetime_set = false;
         return false;
      }
   } 
   return false;
}

bool COrderBase::Modify(double m_price, ENUM_ORDER_TYPE_TIME m_type_time, datetime m_expiration)
{
   SetPrice(m_price);
   SetExpiration(m_expiration);
   SetTypeTime(m_type_time);
   return(Modify());
}

bool COrderBase::ModifyPrice(double m_price)
{
   return(Modify(m_price,type_time,expiration));      
}      

bool COrderBase::Update()
{
   if (executestate == ES_EXECUTED) {      
      if (GetOrderInfoB()) {      
         //if (event.Verbose ()) event.Verbose ("order info got: ticket:"+this.ticket,__FUNCTION__);
         this.State();
         //this.state = this.orderinfo.State();
         if (executetime == 0 && state != ORDER_STATE_STARTED && state != ORDER_STATE_REJECTED) executetime = orderinfo.TimeSetup();
         if (filltime == 0 && state == ORDER_STATE_FILLED) {
            filltime = orderinfo.TimeDone();                          
         }
         return(true);
      } else {
         if (event.Verbose ()) event.Verbose ("Failed to get OrderInfo ticket:"+(string)this.ticket,__FUNCTION__);
         return(false);
      }
   } else if (executestate == ES_NOT_EXECUTED) {
      if (event.Info ()) event.Info ("Execute order",__FUNCTION__);
      if (Execute()) {
         return(true);
      } else {
         if (event.Warning ()) event.Warning ("Failed to execute order",__FUNCTION__);
         // ToDo: Add Counter to retry
         executestate = ES_CANCELED;
         return(false);
      }
   } else {
      return(false);
   }
}

void COrderBase::OnTick()
{
   this.Update();
}





// ***********************************************
// |--------------- COrder ----------------------|
// ***********************************************





bool COrder::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
   const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{

   symbol = in_symbol;
   SetOrderType(_ordertype);
   SetLots(_volume);
   SetPrice(_price);
   SetComment(_comment);
   SetExpiration(_expiration);

   //if (event.Info ()) event.Info ("Execute New Order",__FUNCTION__);
   if (!Execute()) {
      if (event.Warning ()) event.Warning ("Failed to execute retcode:"+(string)retcode,__FUNCTION__);
      return(false);
   }
   
   if (_stoploss > 0) AddStopLoss(_stoploss);
   if (_takeprofit > 0) AddTakeProfit(_takeprofit);
   
   if (COrderBase::waitforexecute) {
      WaitForExecute();
   }
   
   return(true);          
}

bool COrder::CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment)
{
   CAttachedOrder *attachedorder;
   if (_price > 0 || ordertype_market(_ordertype)) {
      attachedorder = new CAttachedOrder();
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

bool COrder::ModifyStopLoss(double _price)
{
   COrderBase* slorder = GetStopLossOrder();
   if (slorder != NULL) return(slorder.ModifyPrice(_price));
   else return(AddStopLoss(_price));
}

bool COrder::ModifyTakeProfit(double _price)
{
   COrderBase* tporder = GetTakeProfitOrder();
   if (tporder != NULL) return(tporder.ModifyPrice(_price));
   else return(AddTakeProfit(_price));
}

bool COrder::RemoveStopLoss() // TODO: not suitable for removing and then replacing the SL
{
   CAttachedOrder *attachedorder;
   for (int i = 0; i < attachedorders.Total(); i++) {
      attachedorder = attachedorders.AttachedOrder(i);
      if (attachedorder.name == stoploss_name) {
         attachedorder.Cancel();
         attachedorders.Delete(i);
         return(true);
      }
   }
   return(false);
}

bool COrder::RemoveTakeProfit()
{
   CAttachedOrder *attachedorder;
   for (int i = 0; i < attachedorders.Total(); i++) {
      attachedorder = attachedorders.AttachedOrder(i);
      if (attachedorder.name == takeprofit_name) {
         attachedorder.Cancel();
         attachedorders.Delete(i);
         return(true);
      }
   }
   return(false); 
}

int COrder::GetStopLossTicks()
{
   return(getstoplossticks(this.symbol, this.ordertype, this.GetStopLoss(), this.Price()));
}

double COrder::GetStopLoss()
{
   CAttachedOrder *attachedorder = GetStopLossOrder();
   if (attachedorder.Isset()) return(attachedorder.Price());
   return(0);
}

CAttachedOrder* COrder::GetStopLossOrder()
{
   CAttachedOrder *attachedorder;
   for (int i = 0; i < attachedorders.Total(); i++) {
      attachedorder = attachedorders.AttachedOrder(i);
      //Print("sl ticket:"+attachedorder.ticket);
      if (attachedorder.name == stoploss_name) return(attachedorder);
   }
   return(CAttachedOrder::Null());
}
int COrder::GetTakeProfitTicks()
{
   return(gettakeprofitticks(this.symbol, this.ordertype, this.GetTakeProfit(), this.Price()));
}

double COrder::GetTakeProfit()
{
   CAttachedOrder *attachedorder = GetTakeProfitOrder();
   if (attachedorder.Isset()) return(attachedorder.Price());
   return(0);
}

CAttachedOrder* COrder::GetTakeProfitOrder()
{
   CAttachedOrder *attachedorder;
   for (int i = 0; i < attachedorders.Total(); i++) {
      attachedorder = attachedorders.AttachedOrder(i);
      //Print("tp ticket:"+attachedorder.ticket);
      if (attachedorder.name == takeprofit_name) return(attachedorder);
   }
   return(CAttachedOrder::Null());
}

bool COrder::Close(double closevolume = 0, double closeprice = 0)
{
   activity = activity | (ushort)ACTIVITY_CLOSE;
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
      loadsymbol(symbol,__FUNCTION__);
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
      
      this.Update(); 
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
               if (!attachedorder.Execute()) {
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
            if (NormalizeDouble(volume-closedvolume,8) == 0) this.closed = true;
            else if (volume-closedvolume < 0) {
               loadsymbol(symbol,__FUNCTION__);
               if (_symbol.LotRound(closedvolume-volume) == closedvolume-volume) {
                  event.Warning("Too many attached order triggered, opening balance order",__FUNCTION__);
                  ENUM_ORDER_TYPE balancetype = ordertype_long(this.ordertype)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
                  CreateAttached(balancetype,closedvolume-volume,0,0,"balance","");
                  closed = true;
               }
            }
         }
      }
      
   }
   
}