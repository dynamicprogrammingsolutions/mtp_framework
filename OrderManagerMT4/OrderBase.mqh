//
//
/*
#include "MoneyManagement.mqh"
#include "Trade.mqh"
#include "MT4OrderInfo.mqh"
#include "..\ServiceProviderBase\OrderBaseBase.mqh"
#include "..\ServiceProviderBase\OrderManagerBase.mqh"
#include "EnumActivity.mqh"
#include "EnumExecuteState.mqh"
*/

#include "Loader.mqh"
#include "..\libraries\objectfunctions.mqh"
#include "..\libraries\commonfunctions.mqh"

class COrderBase : public COrderInterface
{
public:
   virtual int Type() const { return classMT4OrderBase; }
protected:
   CEventHandlerInterface* event;
   
   // Used Traits:
   TraitAppAccess
   TraitLoadSymbolFunction

public:
   static ushort activity;

public:      
   static CTrade* trade_default;
   
   static int magic_default;

   static bool price_virtual_default;

   static bool vstops_draw_line;
   static bool vprice_draw_line;
   static bool realstops_draw_line;
   static bool realprice_draw_line;
   static color vsl_color;
   static color vtp_color;
   static color vprice_color;
   static string vsl_objname;
   static string vtp_objname;
   static string vprice_objname;
   static bool vstops_use_bid;
   
   static bool delete_stoploss_objects;
   static bool delete_takeprofit_objects;
   static bool delete_entry_objects;
   static bool delete_mm_objects;
   
   static bool lotround_execute;
   
   static int max_virtual_ticket;
   
   static int maxid;
   
   static bool use_normal_stops;
   
private:
   double last_vsl;
   double last_vtp;
   double last_vprice;

public:      
   CTrade* trade;
   
   ENUM_EXECUTE_STATE executestate;
   
protected:
   ENUM_ORDER_STATE state;

public:
   int ticket;
   string symbol;
   
protected: // order parameters that may change by other parties
   ENUM_ORDER_TYPE ordertype;
   double volume;   
   double price;
   double sl;
   double tp;
   datetime expiration;

public:
   int id;
   string comment;
   int magic;
   
   datetime closetime;

   bool sl_virtual;
   bool tp_virtual;
   bool price_virtual;
      
   COrderInfo *orderinfo;

protected:
   uint retcode;   
   datetime executetime;   
   datetime filltime;

   bool sl_set;
   bool tp_set;
   
   bool price_set;
   bool expiration_set;

public:

   COrderBase() {
      this.id = maxid+1;
      maxid = this.id;
      
      if (trade_default == NULL) trade_default = new CTrade;
      
      trade = trade_default;
      
      ticket = -1;
      executestate = ES_NOT_EXECUTED;
      state = NULL;
      sl = 0;
      tp = 0;      
      
      sl_virtual = false;
      tp_virtual = false;
      
      price_virtual = price_virtual_default;      
      magic = magic_default;
   };
   
   ~COrderBase() {
      delete this.orderinfo;
   };
   
   virtual void Initalize()
   {
      event = App().eventhandler;
   }
   
   void Copy(COrderBase*& target);
   bool ExistingOrder(int existing_ticket);
   
   bool Isset() { return(executestate != ES_NOT_EXECUTED); }  
   
   COrderInfo* GetOrderInfo();
   bool GetOrderInfo(COrderInfo *_orderinfo);
   bool GetOrderInfoB();
   bool CheckOrderInfo() { if (CheckPointer(orderinfo) == POINTER_INVALID) return(false); else return(true); }   
   
   virtual bool Execute();
   virtual bool Cancel();
   virtual bool Close(double closevolume = 0, double closeprice = 0);
   virtual bool Modify();
   bool CheckForSimulation(double currentprice);
   virtual bool Update();
   virtual void OnTick();

   void DeleteVPriceLine();
   void UpdateVPriceLine();
   void UpdateRealPriceLine();

   void DeleteVStopLines();
   void UpdateVStopLines();
   
   virtual long GetTicket() { return((long)this.ticket); }
   virtual int GetMagicNumber() { return(this.magic); }
   virtual string GetSymbol() { return(this.symbol); }
   virtual string GetComment() { return(this.comment); }
   
   
   bool Select() { if (this.executestate != ES_NOT_EXECUTED) return(GetOrderInfoB()); else return(false); } 
     
   ENUM_ORDER_STATE State()
   {
      if (this.executestate != ES_NOT_EXECUTED && this.executestate != ES_VIRTUAL && this.state != ORDER_STATE_CLOSED && this.state != ORDER_STATE_DELETED) {
         ENUM_ORDER_STATE oldstate = state;            
         this.state = CheckOrderInfo()?this.orderinfo.State():ORDER_STATE_UNKNOWN;
         if (oldstate != state) {
            activity = activity | ACTIVITY_STATECHANGE;
         }
      }
      return(this.state);
   }
   
   void State(ENUM_ORDER_STATE newstate)
   {
      this.state = newstate;
   }
   
   double Price() {
         if (!CheckOrderInfo()) return(price);
         else return(this.orderinfo.GetOpenPrice());
   }   
   
   double CurrentPrice() {
         if (CheckOrderInfo()) return(this.orderinfo.GetClosePrice());
         else return(0);
   }
   
   // Change After State Change:
   virtual ENUM_ORDER_TYPE GetType() { if (!CheckOrderInfo()) return(this.ordertype); else return(orderinfo.GetType()); }
   
   virtual datetime GetOpenTime() { if (!CheckOrderInfo()) return(MathMax(this.executetime,this.filltime)); else return(orderinfo.GetOpenTime()); }
   
   virtual double GetOpenPrice() { if (!CheckOrderInfo()) return(this.price); else return(orderinfo.GetOpenPrice()); }
   
   virtual double GetLots() { if (!CheckOrderInfo()) return(this.volume); else return(orderinfo.GetLots()); }
   virtual double GetClosePrice() { if (!CheckOrderInfo()) return(0); else return(orderinfo.GetClosePrice()); }
   virtual datetime GetCloseTime() { if (!CheckOrderInfo()) return(-1); else return(orderinfo.GetCloseTime()); }

   double GetInternalTP() { return(tp); }
   double GetInternalSL() { return(sl); }
   double GetInternalPrice() { return(price); }
   double GetInternalLot() { return(volume); }

   virtual int GetStopLossTicks() { double _sl = this.GetStopLoss(); return(_sl==0?EMPTY_VALUE:getstoplossticks(this.symbol, this.GetType(), _sl, this.Price())); }   
   virtual double GetStopLoss() { if (this.sl_virtual || executestate == ES_VIRTUAL) return(sl); if (!CheckOrderInfo()) return(0); return(this.orderinfo.GetStopLoss()); }   
   virtual int GetTakeProfitTicks() { double _tp = this.GetTakeProfit(); return(_tp==0?EMPTY_VALUE:gettakeprofitticks(this.symbol, this.GetType(), _tp, this.Price())); }
   virtual double GetTakeProfit() { if (this.tp_virtual || executestate == ES_VIRTUAL) return(tp); if (!CheckOrderInfo()) return(0); return(this.orderinfo.GetTakeProfit()); }   
   virtual int GetProfitTicks() { if (State() == ORDER_STATE_PLACED) return(0); else return(gettakeprofitticks(this.symbol, this.GetType(), this.CurrentPrice(), this.Price())); }
   //int GetProfitMoney() { if (!CheckOrderInfo()) return(0); return(this.orderinfo.Get()); }

   // Change after select:   
   //ENUM_ORDER_STATE State() { if (!CheckOrderInfo()) return(this.state); else return(orderinfo.State()); }
   virtual datetime GetExpiration() { if (!CheckOrderInfo()) return(this.expiration); else return(orderinfo.GetExpiration()); }

   virtual void SetOrderType(const ENUM_ORDER_TYPE value) { if (executestate == ES_NOT_EXECUTED) ordertype=value; else Print("Cannot change executed order data (ordertype)"); }
   virtual void SetMagic(const int value) { if (executestate == ES_NOT_EXECUTED) magic=value; else Print("Cannot change executed order data (magic)"); }
   virtual void SetSymbol(const string value) { if (executestate == ES_NOT_EXECUTED) symbol=value; else Print("Cannot change executed order data (symbol)"); }
   virtual void SetComment(const string value) { if (executestate == ES_NOT_EXECUTED) comment=value; else Print("Cannot change executed order data (comment)"); }
   virtual void SetLots(const double value) { if (executestate == ES_NOT_EXECUTED) volume=value; else Print("Cannot change executed order data (lots)"); }
   virtual void SetExpiration(const datetime value) { expiration_set = true; if (executestate != ES_CANCELED) expiration = value; else Print("Cannot change canceled order data (expiration)"); }
   
   virtual void SetPrice(const double value) { price_set = true; if (executestate != ES_CANCELED) price = value; else Print("Cannot change canceled order data (price)"); }
   virtual void SetStopLoss(const double value) { sl_set = true; if (executestate != ES_CANCELED) sl = value; else Print("Cannot change canceled order data (sl)"); }
   virtual void SetTakeProfit(const double value) { tp_set = true; if (executestate != ES_CANCELED) tp = value; else Print("Cannot change canceled order data (tp)"); }
   
   bool SetStopLoss(CStopLoss* _sl, bool check = false);
   bool SetTakeProfit(CTakeProfit* _tp, bool check = false);
   
   static void DeleteIf(CStopLoss* obj) {
      if (obj.DeleteAfterUse()) delete obj;
   }

   static void DeleteIf(CTakeProfit* obj) {
      if (obj.DeleteAfterUse()) delete obj;
   }
   
   static void DeleteIf(CEntry* obj) {
      if (obj.DeleteAfterUse()) delete obj;
   }
   
   static void DeleteIf(CMoneyManagement* obj) {
      if (obj.DeleteAfterUse()) delete obj;
   }

   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      Print(__FUNCTION__+" Start Saving pos: "+file.Tell());

      if (!file.WriteInteger(id)) return file.Error("id",__FUNCTION__);
      if (!file.WriteInteger(executestate)) return file.Error("executestate",__FUNCTION__);
      if (!file.WriteInteger(state)) return file.Error("state",__FUNCTION__);      
      if (!file.WriteInteger(ticket)) return file.Error("ticket",__FUNCTION__);
      if (!file.WriteString(symbol)) return file.Error("symbol",__FUNCTION__);
      if (!file.WriteInteger(ordertype)) return file.Error("ordertype",__FUNCTION__);
      if (!file.WriteDouble(volume)) return file.Error("volume",__FUNCTION__);
      if (!file.WriteDouble(price)) return file.Error("price",__FUNCTION__);
      if (!file.WriteDouble(sl)) return file.Error("sl",__FUNCTION__);
      if (!file.WriteDouble(tp)) return file.Error("tp",__FUNCTION__);
      if (!file.WriteInteger(expiration)) return file.Error("expiration",__FUNCTION__);
      if (file.WriteString(comment) < 0) return file.Error("comment",__FUNCTION__);
      if (!file.WriteInteger(magic)) return file.Error("magic",__FUNCTION__);
      if (!file.WriteInteger(closetime)) return file.Error("closetime",__FUNCTION__);
      if (!file.WriteInteger(sl_virtual)) return file.Error("sl_virtual",__FUNCTION__);
      if (!file.WriteInteger(tp_virtual)) return file.Error("tp_virtual",__FUNCTION__);
      if (!file.WriteInteger(price_virtual)) return file.Error("price_virtual",__FUNCTION__);
      if (!file.WriteInteger(retcode)) return file.Error("retcode",__FUNCTION__);
      if (!file.WriteInteger(executetime)) return file.Error("executetime",__FUNCTION__);
      if (!file.WriteInteger(filltime)) return file.Error("filltime",__FUNCTION__);
      if (!file.WriteInteger(sl_set)) return file.Error("sl_set",__FUNCTION__);
      if (!file.WriteInteger(tp_set)) return file.Error("tp_set",__FUNCTION__);
      if (!file.WriteInteger(price_set)) return file.Error("price_set",__FUNCTION__);
      if (!file.WriteInteger(expiration_set)) return file.Error("expiration_set",__FUNCTION__);   

      if (!file.WriteInteger(COrderBase::max_virtual_ticket)) return file.Error("max_virtual_ticket",__FUNCTION__);   
      if (!file.WriteInteger(COrderBase::maxid)) return file.Error("maxid",__FUNCTION__);   
      
      Print(__FUNCTION__+" End Saving pos: "+file.Tell());
        
      return(true);  
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;
      
      Print(__FUNCTION__+" Start Loading pos: "+file.Tell());
      
      if (!file.ReadInteger(id)) return file.Error("id",__FUNCTION__);
      maxid = MathMax(maxid,id);
            
      int int_executestate,int_state; 
      if (!file.ReadInteger(int_executestate)) return file.Error("executestate",__FUNCTION__);      
      if (!file.ReadInteger(int_state)) return file.Error("state",__FUNCTION__);
      executestate = (ENUM_EXECUTE_STATE) int_executestate;
      state = (ENUM_ORDER_STATE) int_state;
      if (!file.ReadInteger(ticket)) return file.Error("ticket",__FUNCTION__);
      if (!file.ReadString(symbol)) return file.Error("symbol",__FUNCTION__);
      int _ordertype;
      if (!file.ReadInteger(_ordertype)) return file.Error("ordertype",__FUNCTION__);
      ordertype = (ENUM_ORDER_TYPE)_ordertype;
      if (!file.ReadDouble(volume)) return file.Error("ordertype",__FUNCTION__);
      if (!file.ReadDouble(price)) return file.Error("price",__FUNCTION__);
      if (!file.ReadDouble(sl)) return file.Error("sl",__FUNCTION__);
      if (!file.ReadDouble(tp)) return file.Error("tp",__FUNCTION__);
      if (!file.ReadDateTime(expiration)) return file.Error("expiration",__FUNCTION__);
      if (!file.ReadString(comment)) return file.Error("comment",__FUNCTION__);
      if (!file.ReadInteger(magic)) return file.Error("magic",__FUNCTION__);
      if (!file.ReadDateTime(closetime)) return file.Error("closetime",__FUNCTION__);
      if (!file.ReadBool(sl_virtual)) return file.Error("sl_virtual",__FUNCTION__);
      if (!file.ReadBool(tp_virtual)) return file.Error("tp_virtual",__FUNCTION__);
      if (!file.ReadBool(price_virtual)) return file.Error("price_virtual",__FUNCTION__);
      if (!file.ReadInteger(retcode)) return file.Error("retcode",__FUNCTION__);
      if (!file.ReadDateTime(executetime)) return file.Error("executetime",__FUNCTION__);
      if (!file.ReadDateTime(filltime)) return file.Error("filltime",__FUNCTION__);
      if (!file.ReadBool(sl_set)) return file.Error("sl_set",__FUNCTION__);
      if (!file.ReadBool(tp_set)) return file.Error("tp_set",__FUNCTION__);
      if (!file.ReadBool(price_set)) return file.Error("price_set",__FUNCTION__);
      if (!file.ReadBool(expiration_set)) return file.Error("expiration_set",__FUNCTION__); 

      if (!file.ReadInteger(COrderBase::max_virtual_ticket)) return file.Error("max_virtual_ticket",__FUNCTION__);   
      if (!file.ReadInteger(COrderBase::maxid)) return file.Error("maxid",__FUNCTION__);   
            
      Print(__FUNCTION__+" End Loading pos: "+file.Tell());
      
      return(true);  
   }

};

CTrade* COrderBase::trade_default = NULL;

ushort COrderBase::activity = ACTIVITY_NOTHING;

int COrderBase::magic_default = 0;
bool COrderBase::price_virtual_default = false;

bool COrderBase::vstops_draw_line = true;
bool COrderBase::vprice_draw_line = true;
bool COrderBase::realstops_draw_line = false;
bool COrderBase::realprice_draw_line = false;
color COrderBase::vsl_color = Red;
color COrderBase::vtp_color = Green;
color COrderBase::vprice_color = Yellow;
string COrderBase::vsl_objname = "_vsl";
string COrderBase::vtp_objname = "_vtp";
string COrderBase::vprice_objname = "_vprice";
bool COrderBase::vstops_use_bid = false;

bool COrderBase::lotround_execute = true;

int COrderBase::max_virtual_ticket = 1000000000;
int COrderBase::maxid = 0;

bool COrderBase::use_normal_stops = true;

bool COrderBase::delete_stoploss_objects = true;
bool COrderBase::delete_takeprofit_objects = true;
bool COrderBase::delete_entry_objects = true;
bool COrderBase::delete_mm_objects = false;


// ********************************************************************************************
// |---------------------------------------- COrderBase ------------------------------------------|
// ********************************************************************************************
   
   void COrderBase::Copy(COrderBase*& target) {
      target.trade = trade;
      target.orderinfo = orderinfo;
      target.executestate = executestate;
      target.state = state;
   
      target.ticket = ticket;
   
      target.ordertype = ordertype;
      target.symbol = symbol;
      target.volume = volume;
      target.price = price;
      target.sl = sl;
      target.tp = tp;
   
      target.comment = comment;
      target.expiration = expiration;
      target.magic = magic;
   
      target.closetime = closetime;
   
      target.sl_virtual = sl_virtual;
      target.tp_virtual = tp_virtual;
      target.price_virtual = price_virtual;
      
      target.retcode = retcode;
      
      target.executetime = executetime;   
      target.filltime = filltime;
   }
   
    bool COrderBase::ExistingOrder(int existing_ticket) {

      ticket = existing_ticket;
      executestate = ES_EXECUTED;    
      
      if (this.GetOrderInfoB()) {
         this.symbol = this.orderinfo.GetSymbol();
         this.comment = this.orderinfo.GetComment();
         this.expiration = this.orderinfo.GetExpiration();         
         this.magic = this.orderinfo.GetMagicNumber();  
         this.Update();
         return(true);
      } else {
         if (event.Error ()) event.Error ("Existing Order Info Select Failed: "+this.ticket,__FUNCTION__);
         return(false);
      }
            
   };
      
   COrderInfo* COrderBase::GetOrderInfo()
   {
      if (!isset(this.orderinfo)) this.orderinfo = new COrderInfo();
      if (this.orderinfo.Select(ticket,MODE_TRADES)) {
         return(orderinfo);
      }
      if (this.orderinfo.Select(ticket,MODE_HISTORY)) {  
         return(orderinfo);
      }      
      this.orderinfo = NULL;      
      return(NULL);
   }
   
   bool COrderBase::GetOrderInfo(COrderInfo *_orderinfo)
   {
      _orderinfo = GetOrderInfo();
      return(orderinfo != NULL);
   }
   
   bool COrderBase::GetOrderInfoB()
   {
      GetOrderInfo();
      //if ( event.Verbose ()) event.Verbose ("orderinfo != NULL:"+(orderinfo != NULL),__FUNCTION__);
      return(orderinfo != NULL);
   }
   
   bool COrderBase::Execute()
   {
      activity = activity | ACTIVITY_EXECUTE;
      COrderInfo historyorder;
      if (executestate == ES_NOT_EXECUTED) {
         /*if (ordermanager != NULL && ordermanager.simulation_enabled) {         
            return(this.UpdateSimulation());
         } else {*/
            if ( event.Info ()) event.Info ("Execute Order: type="+ordertype+" price="+price+" tp="+tp+" sl="+sl+" expiration="+expiration+" magic="+this.magic,__FUNCTION__);
            bool success;
            bool isvirtual = false;
            string virtual_error = "";
            double real_sl = 0, real_tp = 0;                   
            if (ordertype_market(ordertype)) {
               loadsymbol(symbol);
               if (price == 0) {                  
                  if (ordertype == ORDER_TYPE_SELL) { price = _symbol.Bid(); }
                  else if (ordertype == ORDER_TYPE_BUY) { price = _symbol.Ask(); }
               }              
               if (!sl_virtual) real_sl = sl;
               if (!tp_virtual) real_tp = tp;
               trade.SetExpertMagicNumber(this.magic);
               success = trade.PositionOpen(symbol,ordertype,lotround_execute?_symbol.LotRound(volume):volume,_symbol.PriceRound(price),_symbol.PriceRound(real_sl),_symbol.PriceRound(real_tp),comment);
            } else if (ordertype_pending(ordertype)) {
               if (price > 0) {
                  if (price_virtual) {                  
                     isvirtual = true;
                     if (getentrypriceticks(this.symbol,this.ordertype,this.price) > 0) {
                        ticket = max_virtual_ticket;
                        max_virtual_ticket++;
                        state = ORDER_STATE_PLACED;
                        executetime = TimeCurrent();
                        success = true;
                     } else {
                        virtual_error = "Invalid Price: "+this.price+" bid/ask:"+_symbol.Bid()+"/"+_symbol.Ask();
                     }
                  } else {
                     loadsymbol(symbol);
                     if (!sl_virtual) real_sl = sl;
                     if (!tp_virtual) real_tp = tp;
                     trade.SetExpertMagicNumber(this.magic);
                     success = trade.OrderOpen(symbol,ordertype,lotround_execute?_symbol.LotRound(volume):volume,_symbol.PriceRound(price),_symbol.PriceRound(real_sl),_symbol.PriceRound(real_tp),expiration,comment);
                  }
               } else {
                  if (event.Warning ()) event.Warning ("No Price",__FUNCTION__);
               }
            }
            if (!isvirtual) {
               if (success) {               
                  if (trade.ResultOrder() >= 0) {
                     ticket = trade.ResultOrder();
                     if ( event.Info ()) event.Info ("Order Executed. Ticket:"+(string)ticket,__FUNCTION__);
                     executestate = ES_EXECUTED;
                     Update();
                     return(true);
                  } else {
                     retcode = trade.ResultRetcode();
                     if (event.Warning ()) event.Warning ("No Ticket in trade result retcode: "+(string)trade.ResultRetcode(),__FUNCTION__);
                  } 
               } else {
                  retcode = trade.ResultRetcode();
                  loadsymbol(this.symbol);
                  if (event.Error ()) event.Error ("Order Open Failed ("+trade.ResultRetcode()+":"+ErrorDescription(trade.ResultRetcode())+"): symbol:"+this.symbol+" ordertype:"+(string)ordertype+", volume:"+(string)volume+", price:"+(string)price+" sl:"+real_sl+" tp:"+tp+" current ask:"+_symbol.Ask()+" bid:"+_symbol.Bid(),__FUNCTION__);
                  executestate = ES_CANCELED;
                     
               }
            } else {
               if (success) {
                  if ( event.Info ()) event.Info ("Order Executed. Ticket:"+(string)ticket,__FUNCTION__);
                  executestate = ES_VIRTUAL;
                  Update();
                  return(true);
               } else {
                  if (event.Error ()) event.Error ("Order Open Failed ("+virtual_error+"): ordertype:"+(string)ordertype+", volume:"+(string)volume+", price:"+(string)price+" sl:"+real_sl+" tp:"+tp,__FUNCTION__);                  
                  executestate = ES_CANCELED;
               }
            }
         //}
      } else {
         if (executestate == ES_CANCELED) {
            if ( event.Info ()) event.Info ("Order Already Canceled",__FUNCTION__);
         } else if (executestate == ES_EXECUTED) {
            if ( event.Info ()) event.Info ("Order Already Executed",__FUNCTION__);
         }
      }
      return(false);
   }   
   
   bool COrderBase::Cancel()
   {
      activity = activity | ACTIVITY_DELETE;      
      if (executestate == ES_EXECUTED) {
         if (!Select()) {
            if (event.Notice ()) event.Notice ("Cannot select order "+this.ticket,__FUNCTION__);
            return(false);
         }
         State();
         if (state <= ORDER_STATE_PLACED) {
            if (trade.OrderDelete(ticket,orderinfo)) {
               this.OnTick();
            } else {
               if (event.Warning ()) event.Warning ("Order Delete Failed ("+trade.ResultRetcode()+":"+ErrorDescription(trade.ResultRetcode())+"): ticket:"+ticket,__FUNCTION__);
            }
         } else if (state == ORDER_STATE_DELETED) {
            if (event.Info ()) event.Info ("Order Already Canceled, state:"+(string)state,__FUNCTION__);
         } else if (state == ORDER_STATE_FILLED) {
            if (event.Info ()) event.Info ("Order Already Filled, state:"+(string)state,__FUNCTION__);
         } else {
            if (event.Info ()) event.Info ("Invalid Order State",__FUNCTION__);
         }
      } else if (executestate == ES_NOT_EXECUTED) {
         executestate = ES_CANCELED;
         if (event.Info ()) event.Info ("Order Not Yet Executed, Execution Canceled",__FUNCTION__);
      } else if (executestate == ES_VIRTUAL) {
         DeleteVPriceLine();
         state = ORDER_STATE_DELETED;
         if (event.Info ()) event.Info ("Virtual Order Canceled",__FUNCTION__);
      } else if (executestate == ES_CANCELED) {
         if (event.Info ()) event.Info ("Order Not Executed, Execution Already Canceled",__FUNCTION__);
      } else {
         event.Error("Invalid Execute State",__FUNCTION__);
         return(false);
      }
      return(true);
   }
   
   bool COrderBase::Close(double closevolume = 0, double closeprice = 0)
   {      
      activity = activity | ACTIVITY_CLOSE;
      
      if (!state_ongoing(this.State())) {
         if (event.Notice ()) event.Notice ("Order "+this.ticket+" is already closed or canceled",__FUNCTION__);
         return(true);
      }
      
      //if ( event.Verbose ()) event.Verbose ("Closing Order type:"+ordertype+" state:"+state,__FUNCTION__);
      
      ordertype = GetType();
      
      if (ordertype_pending(ordertype)) {
         if (event.Notice ()) event.Notice ("Order to close is pending",__FUNCTION__);
         if (state_undone(state)) {            
            if (event.Notice ()) event.Notice ("Order to close is not filled",__FUNCTION__);
            return(this.Cancel());
            //return(false);
         }
      }
      
      if (!Select()) {
         if (event.Notice ()) event.Notice ("Cannot select order "+this.ticket,__FUNCTION__);
         return(false);
      }      
      
      if (closeprice == 0) {
         loadsymbol(symbol);
         if (this.ordertype == ORDER_TYPE_SELL) { closeprice = _symbol.Ask(); }
         else if (this.ordertype == ORDER_TYPE_BUY) { closeprice = _symbol.Bid(); }
         //if ( event.Verbose ()) event.Verbose ("closeprice: "+(string)closeprice,__FUNCTION__);
      }
      
      if (closevolume == 0) closevolume = GetLots();
      if (closevolume > GetLots()) closevolume = GetLots();
      
      //if ( event.Verbose ()) event.Verbose ("closevolume="+(string)closevolume+" volume="+(string)volume,__FUNCTION__);
      
      if (trade.OrderClose(this.ticket,closevolume,closeprice,orderinfo)) {
         if (event.Info ()) event.Info ("order closed",__FUNCTION__);
         this.OnTick();
         //this.DeleteVStopLines(); 
         return(true);
      } else {
         if (event.Error ()) event.Error ("Failed to close order ("+trade.ResultRetcode()+":"+ErrorDescription(trade.ResultRetcode())+"):"+this.ticket+" volume:"+closevolume+" ordervolume:"+volume+" price:"+closeprice+" state:"+state+" type:"+ordertype+" executestate:"+executestate,__FUNCTION__);
      }
            
      return(false);
   }
   
   

   bool COrderBase::Modify()
   {      
      activity = activity | ACTIVITY_MODIFY;
      if (Select()) {
         double real_sl = 0, real_tp = 0;
         if ( event.Info ()) event.Info ("Modify Order: ticket="+ticket+" price="+price+" tp="+tp+" sl="+sl+" expiration="+expiration,__FUNCTION__);
         loadsymbol(this.symbol);
         if (!sl_virtual) real_sl = _symbol.PriceRound(sl_set?sl:orderinfo.GetStopLoss());
         if (!tp_virtual) real_tp = _symbol.PriceRound(tp_set?tp:orderinfo.GetTakeProfit());
         if (!price_set) price = orderinfo.GetOpenPrice();
         if (!expiration_set) expiration = orderinfo.GetExpiration();
	 
	 price_set = false;
	 sl_set = false;
	 tp_set = false;
	 expiration_set = false;
	 
         if (GetOrderInfoB()) {
            if (real_sl != orderinfo.GetStopLoss() || real_tp != orderinfo.GetTakeProfit() || (ordertype_pending(orderinfo.GetType()) && (price != orderinfo.GetOpenPrice() || expiration != orderinfo.GetExpiration()))) {
               if (trade.OrderModify(ticket,_symbol.PriceRound(price),_symbol.PriceRound(real_sl),_symbol.PriceRound(real_tp),expiration,orderinfo)) {
                  Update();
                  return(true);
               } else return(false);
            } else return(true);
         } else return(false);
      } else return(false);
   }
   
   bool COrderBase::CheckForSimulation(double currentprice)
   {
      if (this.ordertype == ORDER_TYPE_BUY || this.ordertype == ORDER_TYPE_SELL) {
         return(true);
      }
      if (this.ordertype == ORDER_TYPE_BUY_LIMIT || this.ordertype == ORDER_TYPE_SELL_STOP) {
         if (this.price >= currentprice) return(false);
      }
      else if (this.ordertype == ORDER_TYPE_SELL_LIMIT || this.ordertype == ORDER_TYPE_BUY_STOP) {
         if (this.price <= currentprice) return(false);
      }
      if (this.price <= 0) return(false);
      return(true);
   }
   
   bool COrderBase::Update()
   {
      //Print("order"+ticket+" update");
      if (executestate == ES_EXECUTED) {  
         if (Select()) {
            this.State();

            return(true);
         } else {            
            //if ( event.Verbose ()) event.Verbose ("Failed to get OrderInfo ticket:"+(string)this.ticket,__FUNCTION__);
            return(true);
         }
      } else if (executestate == ES_VIRTUAL) {
         if (state == ORDER_STATE_PLACED) {
            // Checking virtual price
            UpdateVPriceLine();
            if (getentrypriceticks(this.symbol,this.ordertype,this.price) <= 0) {               
               DeleteVPriceLine();
               this.ordertype = ordertype_convert_to_market(this.ordertype);
               executestate = ES_NOT_EXECUTED;
               price = 0;
               if (Execute()) {
                  //executestate = ES_EXECUTED;
                  return(true);
               } else {
                  //executestate = ES_CANCELED;
                  return(false);
               }               
            }
            return(true);
         } else {
            //DeleteVPriceLine();
            return(true);
         }
      } else if (executestate == ES_NOT_EXECUTED) {
         this.state = ORDER_STATE_UNKNOWN;            
         if (event.Info ()) event.Info ("Execute order",__FUNCTION__);
         if (Execute()) {
            //executestate = ES_EXECUTED;
            return(true);
         } else {
            if (event.Warning ()) event.Warning ("Failed to execute order",__FUNCTION__);
            // ToDo: Add Counter to retry
            //executestate = ES_CANCELED;
            //if (ordermanager != NULL) ordermanager.MoveToHistory(this.ticket);
            return(false);
         }
      } else {
         this.state = ORDER_STATE_UNKNOWN;            
         return(false);
      }
      
   
   }
   
   COrderBase::OnTick(void)
   {
      //Print("Order "+ticket+" OnTick");
      if (Update()) {
         if (this.state == ORDER_STATE_CLOSED || this.state == ORDER_STATE_DELETED) {
            DeleteVStopLines();
            if (realprice_draw_line) DeleteVPriceLine();
         } else {
            if (this.state == ORDER_STATE_PLACED && (price_virtual || realprice_draw_line)) {           
               UpdateRealPriceLine();
            }
            if (this.state == ORDER_STATE_FILLED && realprice_draw_line) DeleteVPriceLine();
            if (this.state == ORDER_STATE_FILLED && (sl_virtual || tp_virtual || realstops_draw_line)) { 
               //Print("update Vstops of ",ticket," type:",ordertype);                 
               UpdateVStopLines();
               loadsymbol(symbol);
               double closeprice;
               ordertype = this.GetType();
               if (ordertype == ORDER_TYPE_SELL) { closeprice = vstops_use_bid?_symbol.Bid():_symbol.Ask(); }
               else if (ordertype == ORDER_TYPE_BUY) { closeprice = _symbol.Bid(); }
               //disable_vstops = true;
               if (ordertype == ORDER_TYPE_BUY) {
                  //Print("closeprice: ",closeprice," sl:",sl," tp:",tp);
                  if (sl_virtual && sl > 0 && closeprice <= sl) this.Close();
                  if (tp_virtual && tp > 0 && closeprice >= tp) this.Close();
               } else if (ordertype == ORDER_TYPE_SELL) {
                  //Print("closeprice: ",closeprice," sl:",sl," tp:",tp);
                  if (sl_virtual && sl > 0 && closeprice >= sl) this.Close();
                  if (tp_virtual && tp > 0 && closeprice <= tp) this.Close();
               }
               //disable_vstops = false;
            }
         }        
      }      
   }
   
   void COrderBase::DeleteVPriceLine()
   {
      if ((vprice_draw_line && price_virtual) || realprice_draw_line)
         objdel(vprice_objname,this.ticket);     
   }
   
   void COrderBase::DeleteVStopLines()
   {
      if ((vstops_draw_line && sl_virtual && sl > 0) || realstops_draw_line)
         objdel(vsl_objname,this.ticket);
      if ((vstops_draw_line && tp_virtual && tp > 0) || realstops_draw_line)
         objdel(vtp_objname,this.ticket);
   }   
   
   void COrderBase::UpdateVPriceLine()
   {
      if (vprice_draw_line) {
         if (price_virtual && price > 0) {
            double line_price = line_get(vprice_objname,this.ticket);            
            if (line_price <= 0 || last_vprice != price) {
               hline_put(vprice_objname,price,vprice_color,this.ticket);
            } else if (line_price > 0) {
               if (!line_beingdragged(vprice_objname,this.ticket)) {
                  price = line_price;
               }
            }
            last_vprice = price;            
         }         
      }      
   }
   
   void COrderBase::UpdateRealPriceLine()
   {      
      if (realprice_draw_line) {
         if (!price_virtual && GetOpenPrice() > 0) {
            double line_price = line_get(vprice_objname,this.ticket);            
            if (line_price <= 0 || last_vprice != GetOpenPrice()) {
               hline_put(vprice_objname,GetOpenPrice(),vprice_color,this.ticket);
            } else if (line_price > 0) {
               if (!line_beingdragged(vprice_objname,this.ticket)) {
                  if (GetOpenPrice() != line_price) {
                     SetPrice(line_price);
                     Modify();
                     hline_put(vprice_objname,GetOpenPrice(),vprice_color,this.ticket);
                  }
               }
            }
            last_vprice = GetOpenPrice();            
         }
      }
   }
   
   void COrderBase::UpdateVStopLines()
   {
      if (vstops_draw_line) {
         if (sl_virtual && sl > 0) {
            double line_sl = line_get(vsl_objname,this.ticket);            
            if (line_sl <= 0 || last_vsl != sl) {
               hline_put(vsl_objname,sl,vsl_color,this.ticket);
            } else if (line_sl > 0) {
               if (!line_beingdragged(vsl_objname,this.ticket)) {
                  sl = line_sl;
               }
            }
            last_vsl = sl;            
         }         
         if (tp_virtual && tp > 0) {
            double line_tp = line_get(vtp_objname,this.ticket);
            if (line_tp <= 0 || last_vtp != tp)
               hline_put(vtp_objname,tp,vtp_color,this.ticket);
            else if (line_tp > 0) {
               if (!line_beingdragged(vtp_objname,this.ticket)) {
                  tp = line_tp;
               }
            }
            last_vtp = tp;
         }
      }
      if (realstops_draw_line) {
         if (!sl_virtual && GetStopLoss() > 0) {
            line_sl = line_get(vsl_objname,this.ticket);            
            if (line_sl <= 0 || last_vsl != GetStopLoss()) {
               hline_put(vsl_objname,GetStopLoss(),vsl_color,this.ticket);
            } else if (line_sl > 0) {
               if (!line_beingdragged(vsl_objname,this.ticket)) {
                  if (GetStopLoss() != line_sl) {
                     SetStopLoss(line_sl);
                     Modify();
                     hline_put(vsl_objname,GetStopLoss(),vsl_color,this.ticket);
                  }
               }
            }
            last_vsl = sl;            
         }
         if (!tp_virtual && GetTakeProfit() > 0) {
            line_tp = line_get(vtp_objname,this.ticket);
            if (line_tp <= 0 || last_vtp != GetTakeProfit())
               hline_put(vtp_objname,GetTakeProfit(),vtp_color,this.ticket);
            else if (line_tp > 0) {
               if (!line_beingdragged(vtp_objname,this.ticket)) {
                  if (GetTakeProfit() != line_tp) {
                     SetTakeProfit(line_tp);
                     Modify();
                     hline_put(vtp_objname,GetTakeProfit(),vtp_color,this.ticket);
                  }
               }
            }
            last_vtp = tp;
         }
      }
   }

   
   bool COrderBase::SetStopLoss(CStopLoss* _sl, bool check = false) {
      if (!check) {
         SetStopLoss(_sl.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice()).GetPrice());
         DeleteIf(_sl);
         return true;
      } else {
         loadsymbol(this.symbol);
         double thissl = _symbol.PriceRound(_sl.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice()).GetPrice());
         if (thissl != _symbol.PriceRound(this.GetStopLoss())) {
            SetStopLoss(thissl);
            DeleteIf(_sl);
            return true;
         } else {
            DeleteIf(_sl);
            return false;
         }
      }
   }
   
   bool COrderBase::SetTakeProfit(CTakeProfit* _tp, bool check = false) {
      if (!check) {
         SetTakeProfit(_tp.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice()).GetPrice());
         if (delete_takeprofit_objects) delete _tp;
         return true;
      } else {
         loadsymbol(this.symbol);
         double thistp = _symbol.PriceRound(_tp.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice()).GetPrice());
         if (thistp != _symbol.PriceRound(this.GetTakeProfit())) {
            SetTakeProfit(thistp);
            if (delete_takeprofit_objects) delete _tp;
            return true;
         } else {
            if (delete_takeprofit_objects) delete _tp;
            return false;
         }
      }
   }




