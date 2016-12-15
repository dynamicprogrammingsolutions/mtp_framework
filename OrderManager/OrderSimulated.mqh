//
#include "Loader.mqh"
#include "..\libraries\math.mqh"

class COrderSimulated : public COrderInterface
{
public:
   TraitGetType(classOrderSimulated)
   TraitNewObject(COrderSimulated)
   TraitAppAccess
   TraitLoadSymbolFunction
   //TraitRefCount
   TraitServiceAlias(CEventHandlerInterface*,eventhandler,event)
   
   TraitEvent(EventStateChange,OnStateChange)
   
private:
   int id;
   static int max_virtual_ticket;
   static int maxid;

   ENUM_EXECUTE_STATE executestate;
   ENUM_ORDER_STATE state;
   ENUM_ORDER_STATE laststate;
   bool closed;
   
   int ticket;
   string symbol;
   ENUM_ORDER_TYPE ordertype;
   double volume;   
   double price;
   double sl;
   double tp;
   bool sl_set;
   bool tp_set;
   bool price_set;
   double executed_sl;
   double executed_tp;
   double executed_price;
   datetime expiration;
   string comment;
   int magic;
   datetime executetime;   
   datetime filltime;

   double closeprice;
   datetime closetime;
   
public:
   COrderSimulated()
   {
      this.id = maxid+1;
      maxid = this.id;
   }

   virtual bool Save(const int handle);
   virtual bool Load(const int handle);

   virtual int Id() { return id; }
   
   virtual bool DoNotArchive() { return false; }
   virtual bool DoNotDelete() { return false; }
   
   virtual ENUM_ORDER_STATE State() { return state; }
   void State(ENUM_ORDER_STATE value) {
      state = value;
      if (laststate != state) {
         event().Info(Conc("new state in simulated order id ",Id(),": ",EnumToString(state)," last state: ",EnumToString(laststate)));
         laststate = state;
         OnStateChange();
      }
   }
   void SetClosed()
   {
      #ifdef __MQL4__
      State(ORDER_STATE_CLOSED);
      #else
      closed = true;
      #endif
   }
   
   virtual ENUM_EXECUTE_STATE ExecuteState() { return executestate; }
   
   virtual bool NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
   const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);
   
   virtual void OnTick();
   virtual bool Execute();
   
   virtual bool Close(double _closevolume = 0, double _closeprice = 0);
   virtual bool Cancel();
   virtual bool Modify();

   virtual bool CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment) { return false; }
   virtual bool AddStopLoss(double in_price, double stopvolume = 0, string name = "") { return false; }
   virtual bool AddTakeProfit(double in_price, double stopvolume = 0, string name = "") { return false; } 

   virtual bool Closed() {
      #ifdef __MQL4__
      return state==ORDER_STATE_CLOSED;
      #else
      return closed;
      #endif;
   }
   virtual bool Deleted() {
      #ifdef __MQL4__
      return state==ORDER_STATE_DELETED;
      #else
      return state==ORDER_STATE_CANCELED;
      #endif;
   }
   virtual bool ClosedOrDeleted() { return Closed()||Deleted(); }   
         
   virtual long GetTicket() { return ticket; }
   virtual int GetMagicNumber() { return magic; }
   virtual string GetSymbol() { return symbol; }
   virtual string GetComment() { return comment; }
   virtual ENUM_ORDER_TYPE GetType() { return ordertype; }
   virtual datetime GetOpenTime() { return MathMax(executetime,filltime); }
   virtual double GetOpenPrice() { return executed_price; }
   virtual double GetLots() { return volume; }
   virtual double GetClosePrice() {
      if (executestate == ES_EXECUTED) {
         if (state == ORDER_STATE_FILLED) {
            loadsymbol(symbol);
            if (ordertype_long(ordertype)) return _symbol.Bid();
            if (ordertype_short(ordertype)) return _symbol.Ask();
         } else if (Closed()) {
            return closeprice;
         } else {
            return 0;
         }
      }
      return 0;
   }
   virtual datetime GetCloseTime() { return closetime; }
   virtual int GetStopLossTicks() { return getstoplossticks(symbol,ordertype,executed_sl,executed_price); }   
   virtual double GetStopLoss() { return executed_sl; }   
   virtual int GetTakeProfitTicks() { return gettakeprofitticks(symbol,ordertype,executed_tp,executed_price); }
   virtual double GetTakeProfit() { return executed_tp; }   
   virtual int GetProfitTicks() {
      if (executestate == ES_EXECUTED) {
         if (state == ORDER_STATE_FILLED
         #ifdef __MQL4__
            || state == ORDER_STATE_CLOSED
         #endif
         ) {
            return gettakeprofitticks(this.symbol, this.GetType(), this.GetClosePrice(), this.GetOpenPrice());
         }
      }
      return 0;
   }
   virtual datetime GetExpiration() { return expiration; }
   virtual double GetProfitMoney() {
      if (executestate == ES_EXECUTED) {
         if (state == ORDER_STATE_FILLED
         #ifdef __MQL4__
            || state == ORDER_STATE_CLOSED
         #endif
         ) {
            loadsymbol(symbol);
            return GetProfitTicks()*_symbol.TickValue()*volume;
         }
      }
      return 0;
   }
   virtual double GetCommission() { return 0; }
   virtual double GetSwap() { return 0; }

   virtual void SetOrderType(const ENUM_ORDER_TYPE value) { ordertype = value; }
   virtual void SetMagic(const int value) { magic = value; }
   virtual void SetSymbol(const string value) { symbol = value; }
   virtual void SetComment(const string value) { comment = value; }
   virtual void SetLots(const double value) { volume = value; }
   virtual void SetExpiration(const datetime value) { expiration = value; }
   virtual void SetPrice(const double value) { price = value; price_set = true; }
   virtual void SetStopLoss(const double value) { sl = value; sl_set = true; }
   virtual void SetTakeProfit(const double value) { tp = value; tp_set = true; }
   virtual bool SetStopLoss(CStopsCalcInterface* _sl, bool checkchange = false, bool checkhigher = false);
   virtual bool SetTakeProfit(CStopsCalcInterface* _tp, bool check = false);
   
   /*static void DeleteIf(CStopsCalcInterface* obj) {
      if (obj.DeleteAfterUse()) delete obj;
   }*/
   
};
int COrderSimulated::max_virtual_ticket = 1000000000;
int COrderSimulated::maxid = 0;

TraitInitEvent(COrderSimulated,EventStateChange)

bool COrderSimulated::Save(const int handle)
{
   MTPFileBin file;
   file.Handle(handle);            
   if (file.Invalid()) return false;
   
   if (!file.WriteInteger(id)) return file.Error("id",__FUNCTION__);
   if (!file.WriteInteger(max_virtual_ticket)) return file.Error("max_virtual_ticket",__FUNCTION__);
   if (!file.WriteInteger(maxid)) return file.Error("maxid",__FUNCTION__);
   if (!file.WriteEnum(executestate)) return file.Error("executestate",__FUNCTION__);
   if (!file.WriteEnum(state)) return file.Error("state",__FUNCTION__);
   if (!file.WriteEnum(laststate)) return file.Error("laststate",__FUNCTION__);
   if (!file.WriteInteger(ticket)) return file.Error("ticket",__FUNCTION__);
   if (file.WriteString(symbol) < 0) return file.Error("symbol",__FUNCTION__);
   if (!file.WriteEnum(ordertype)) return file.Error("ordertype",__FUNCTION__);
   if (!file.WriteDouble(volume)) return file.Error("volume",__FUNCTION__);
   if (!file.WriteDouble(price)) return file.Error("price",__FUNCTION__);
   if (!file.WriteDouble(sl)) return file.Error("sl",__FUNCTION__);
   if (!file.WriteDouble(tp)) return file.Error("tp",__FUNCTION__);
   if (!file.WriteBool(sl_set)) return file.Error("sl_set",__FUNCTION__);
   if (!file.WriteBool(tp_set)) return file.Error("tp_set",__FUNCTION__);
   if (!file.WriteDouble(executed_sl)) return file.Error("executed_sl",__FUNCTION__);
   if (!file.WriteDouble(executed_tp)) return file.Error("executed_tp",__FUNCTION__);
   if (!file.WriteDouble(executed_price)) return file.Error("executed_price",__FUNCTION__);
   if (!file.WriteDateTime(expiration)) return file.Error("expiration",__FUNCTION__);
   if (file.WriteString(comment) < 0) return file.Error("comment",__FUNCTION__);
   if (!file.WriteInteger(magic)) return file.Error("magic",__FUNCTION__);
   if (!file.WriteDateTime(executetime)) return file.Error("executetime",__FUNCTION__);
   if (!file.WriteDateTime(filltime)) return file.Error("filltime",__FUNCTION__);
   if (!file.WriteDouble(closeprice)) return file.Error("closeprice",__FUNCTION__);
   if (!file.WriteDateTime(closetime)) return file.Error("closetime",__FUNCTION__);
   
   return true;
}

bool COrderSimulated::Load(const int handle)
{
   MTPFileBin file;
   file.Handle(handle);            
   if (file.Invalid()) return false;
   
   if (!file.ReadInteger(id)) return file.Error("id",__FUNCTION__);
   if (!file.ReadInteger(max_virtual_ticket)) return file.Error("max_virtual_ticket",__FUNCTION__);
   if (!file.ReadInteger(maxid)) return file.Error("maxid",__FUNCTION__);
   if (!file.ReadEnum(executestate)) return file.Error("executestate",__FUNCTION__);
   if (!file.ReadEnum(state)) return file.Error("state",__FUNCTION__);
   if (!file.ReadEnum(laststate)) return file.Error("laststate",__FUNCTION__);
   if (!file.ReadInteger(ticket)) return file.Error("ticket",__FUNCTION__);
   if (!file.ReadString(symbol)) return file.Error("symbol",__FUNCTION__);
   if (!file.ReadEnum(ordertype)) return file.Error("ordertype",__FUNCTION__);
   if (!file.ReadDouble(volume)) return file.Error("volume",__FUNCTION__);
   if (!file.ReadDouble(price)) return file.Error("price",__FUNCTION__);
   if (!file.ReadDouble(sl)) return file.Error("sl",__FUNCTION__);
   if (!file.ReadDouble(tp)) return file.Error("tp",__FUNCTION__);
   if (!file.ReadBool(sl_set)) return file.Error("sl_set",__FUNCTION__);
   if (!file.ReadBool(tp_set)) return file.Error("tp_set",__FUNCTION__);
   if (!file.ReadDouble(executed_sl)) return file.Error("executed_sl",__FUNCTION__);
   if (!file.ReadDouble(executed_tp)) return file.Error("executed_tp",__FUNCTION__);
   if (!file.ReadDouble(executed_price)) return file.Error("executed_price",__FUNCTION__);
   if (!file.ReadDateTime(expiration)) return file.Error("expiration",__FUNCTION__);
   if (!file.ReadString(comment)) return file.Error("comment",__FUNCTION__);
   if (!file.ReadInteger(magic)) return file.Error("magic",__FUNCTION__);
   if (!file.ReadDateTime(executetime)) return file.Error("executetime",__FUNCTION__);
   if (!file.ReadDateTime(filltime)) return file.Error("filltime",__FUNCTION__);
   if (!file.ReadDouble(closeprice)) return file.Error("closeprice",__FUNCTION__);
   if (!file.ReadDateTime(closetime)) return file.Error("closetime",__FUNCTION__);
   
   return true;
}

bool COrderSimulated::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{
   event().Info("Initiating new simulated order",__FUNCTION__);
   executestate = ES_NOT_EXECUTED;
   SetSymbol(in_symbol);
   SetOrderType(_ordertype);
   SetLots(_volume);
   SetPrice(_price);
   SetStopLoss(_stoploss);
   SetTakeProfit(_takeprofit);
   SetComment(_comment);
   SetExpiration(_expiration);
   if (Execute()) return true;
   else {
      event().Error("Simulated order execution falied",__FUNCTION__);
      return false;
   }
}

void COrderSimulated::OnTick()
{
   if (executestate == ES_EXECUTED) {
      if (state == ORDER_STATE_FILLED && !Closed()) {
         bool closing = false;
         if (gettakeprofitticks(symbol,ordertype,executed_tp,GetClosePrice()) <= 0) {
            closeprice = executed_tp;
            event().Info(Conc("Closing simulated order id ",Id()," by takeprofit ",executed_tp," price=",GetClosePrice()),__FUNCTION__);
            closing = true;
         }
         if (getstoplossticks(symbol,ordertype,executed_sl,GetClosePrice()) <= 0) {
            closeprice = executed_sl;
            event().Info(Conc("Closing simulated order id ",Id()," by stoploss ",executed_sl," price=",GetClosePrice()),__FUNCTION__);
            closing = true;
         }
         if (closing) {
            closetime = TimeCurrent();
            this.SetClosed();
         }
      }
   }
}

bool COrderSimulated::Execute()
{
   if (executestate == ES_NOT_EXECUTED) {
      if (ordertype_market(ordertype)) {
         loadsymbol(symbol);
         executed_price = ordertype==ORDER_TYPE_BUY?_symbol.Ask():_symbol.Bid();
         double close_price = ordertype==ORDER_TYPE_BUY?_symbol.Bid():_symbol.Ask();
         executed_sl = _symbol.PriceRound(sl);
         executed_tp = _symbol.PriceRound(tp);
         sl_set = false;
         tp_set = false;
         price_set = false;
         if (
            gettakeprofitticks(symbol,ordertype,executed_tp,close_price) < _symbol.StopsLevelInTicks() ||
            getstoplossticks(symbol,ordertype,executed_sl,close_price) < _symbol.StopsLevelInTicks()         
         ) {
            event().Error(Conc("Invalid SL/TP in simulated order: price=",executed_price," closeprice=",close_price," sl=",executed_sl," tp=",executed_tp),__FUNCTION__);
            executestate = ES_NOT_EXECUTED;
            return false;
         }
         ticket = max_virtual_ticket+1;
         max_virtual_ticket = ticket;
         executestate = ES_EXECUTED;
         State(ORDER_STATE_FILLED);
         executetime = TimeCurrent();
         filltime = TimeCurrent();
         event().Info(Conc("Order Executed. Ticket:",(string)ticket," price=",executed_price," sl=",executed_sl," tp=",executed_tp),__FUNCTION__);
         return true;
      } else {
         executestate = ES_CANCELED;
         // pending order not supported yet
         return false;
      }
   } else {
      return false;
   }
}

bool COrderSimulated::Close(double _closevolume = 0, double _closeprice = 0) {
   if (executestate == ES_EXECUTED) {
      if (state == ORDER_STATE_FILLED && !Closed()) {
         if (_closevolume > 0 && !q(_closevolume,volume)) event().Warning("Simulation does not support partial close",__FUNCTION__);
         event().Info(Conc("Closing simulated order id ",Id()),__FUNCTION__);
         closetime = TimeCurrent();
         closeprice = GetClosePrice();
         this.SetClosed();
         //State(ORDER_STATE_CLOSED);
         return true;
      } else if (state == ORDER_STATE_PLACED) {
         Cancel();
      }
   }
   return false;
}

bool COrderSimulated::Cancel() {
   event().Warning("Simulation does not support pending orders",__FUNCTION__);
   return false;
}

bool COrderSimulated::Modify() {
   if (price_set) {
      if (executestate == ES_EXECUTED) {
         if (state == ORDER_STATE_PLACED) {
            event().Warning("Simulation does not support pending orders",__FUNCTION__);
         }
      }
   }
   if (sl_set || tp_set) {
      if (executestate == ES_EXECUTED) {
         if (state == ORDER_STATE_FILLED && !Closed()) {
            bool modify_sl_ok = true;
            bool modify_tp_ok = true;
            double close_price;
            if (sl_set) {
               loadsymbol(symbol);
               sl = _symbol.PriceRound(sl);
               close_price = ordertype==ORDER_TYPE_BUY?_symbol.Bid():_symbol.Ask();
               if (getstoplossticks(symbol,ordertype,sl,close_price) < _symbol.StopsLevelInTicks()) {
                  modify_sl_ok = false;
               }
            }
            if (tp_set) {
               loadsymbol(symbol);
               tp = _symbol.PriceRound(tp);
               close_price = ordertype==ORDER_TYPE_BUY?_symbol.Bid():_symbol.Ask();
               if (gettakeprofitticks(symbol,ordertype,tp,close_price) < _symbol.StopsLevelInTicks()) {
                  modify_tp_ok = false;
               }
            }
            if (modify_sl_ok && modify_tp_ok) {
               if (sl_set) executed_sl = sl;
               if (tp_set) executed_tp = tp;
               return true;
            }
         } else if (state == ORDER_STATE_PLACED) {
            event().Warning("Simulation does not support pending orders",__FUNCTION__);
            return false;
         }
      }
   }
   return false;
}


bool COrderSimulated::SetStopLoss(CStopsCalcInterface* _sl, bool checkchange = false, bool checkhigher = false)
{
   loadsymbol(this.symbol);
   _sl.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice());
   _sl.Reset();
   double thissl = _symbol.PriceRound(_sl.GetPrice());
   double thisslticks = _sl.GetTicks();
   if (
      (checkchange && thissl == _symbol.PriceRound(this.GetStopLoss())) ||
      (checkhigher && thisslticks >= this.GetStopLossTicks())
   ) {
      //DeleteIf(_sl);
      return false;
   }
   SetStopLoss(thissl);
   return true;
}

bool COrderSimulated::SetTakeProfit(CStopsCalcInterface* _tp, bool check = false)
{
   if (!check) {
      SetTakeProfit(_tp.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice()).GetPrice());
      //DeleteIf(_tp);
      return true;
   } else {
      loadsymbol(this.symbol);
      double thistp = _symbol.PriceRound(_tp.SetSymbol(this.symbol).SetOrderType(this.GetType()).SetEntryPrice(this.GetOpenPrice()).GetPrice());
      if (thistp != _symbol.PriceRound(this.GetTakeProfit())) {
         SetTakeProfit(thistp);
         //DeleteIf(_tp);
         return true;
      } else {
         //DeleteIf(_tp);
         return false;
      }
   }
}