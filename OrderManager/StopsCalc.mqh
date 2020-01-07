//
#include "Loader.mqh"

#define STOPS_CALC_H
class CStopsCalc : public CStopsCalcInterface
{
public:
   virtual int Type() const { return classStopsCalc; }
protected:

   CApplication* App() { return (CApplication*)AppBase(); }
   CSymbolInfoInterface* _symbol;   
   void loadsymbol(string __symbol)
   {
      _symbol = this.App().symbolloader.LoadSymbol(__symbol);
   }

   string symbol;
   int ordertype;
   double currentprice;
   double entryprice;       
   
   bool ordertype_set;
   bool symbol_set;

   double ticks;
   double price;   
   bool ticks_set;
   bool price_set;
   virtual void CalcTicks() {}
   virtual void CalcPrice() {}
   
     
public:

   virtual void Reset() {}

   virtual CStopsCalcInterface* SetOrderType(ENUM_ORDER_TYPE _ordertype)
   {
      ordertype_set = true;
      this.ordertype = _ordertype;
      return (CStopsCalcInterface*)GetPointer(this);
   }
   
   virtual CStopsCalcInterface* SetSymbol(string __symbol)
   {
      symbol_set = true;
      this.symbol = __symbol;
      return (CStopsCalcInterface*)GetPointer(this);
   }     
   
   virtual CStopsCalcInterface* SetTicks(double _ticks)
   {
      ticks_set = true;
      price_set = false;
      ticks = _ticks;
      return (CStopsCalcInterface*)GetPointer(this);
   }
   
   virtual CStopsCalcInterface* SetPrice(double _price)
   {
      price_set = true;
      ticks_set = false;
      price = _price;
      return (CStopsCalcInterface*)GetPointer(this);
   }
   
   virtual CStopsCalcInterface* SetCurrentPrice(double _currentprice)
   {
      currentprice = _currentprice;      
      return (CStopsCalcInterface*)GetPointer(this);
   }
   
   virtual CStopsCalcInterface* SetEntryPrice(double _entryprice)
   {
      entryprice = _entryprice;      
      return (CStopsCalcInterface*)GetPointer(this);
   }
   
   virtual CStopsCalcInterface* SetTakeProfit(CStopsCalcInterface* tp)
   {
      return GetPointer(this);
   }

   virtual CStopsCalcInterface* SetStopLoss(CStopsCalcInterface* sl)
   {
      return GetPointer(this);
   }

   virtual CStopsCalcInterface* SetTakeProfit(PStopsCalc &tp)
   {
      return SetTakeProfit(tp.get());
   }

   virtual CStopsCalcInterface* SetStopLoss(PStopsCalc &sl)
   {
      return SetStopLoss(sl.get());
   }
   
   virtual void Calculate() { }
   
   virtual double GetTicks()
   {
      if (!ticks_set && !price_set) Calculate();
      if (ticks_set) return ticks;
      if (price_set){
         this.CalcTicks();
         return ticks;
      }
      return(0);
   }
   
   virtual double GetPrice()
   {
      if (!ticks_set && !price_set) Calculate();
      if (price_set) return price;
      if (ticks_set){
         this.CalcPrice();
         return price;
      }
      return(0);
   }    
};

class CEntry : public CStopsCalc {
public:
   virtual int Type() const { return classEntry; }
   CEntry() {}
protected:
   virtual void CalcTicks()
   {
      ticks = getentrypriceticks(this.symbol,this.ordertype,this.price,this.currentprice);
   }
   virtual void CalcPrice()
   {
      price = getentryprice(this.symbol,this.ordertype,(int)this.ticks,this.currentprice);
   }   
   
};

class CStopLoss : public CStopsCalc {
public:
   virtual int Type() const { return classStopLoss; }
   CStopsCalc* tp;

   CStopLoss()
   {
   }
   
   virtual CStopsCalcInterface* SetTakeProfit(CStopsCalcInterface* _tp)
   {
      tp = _tp;
      return NULL;
   }
   
protected:
   bool zero_is_nosl;
   
   
   virtual void CalcTicks()
   {
      ticks = getstoplossticks(this.symbol,this.ordertype,this.price,this.entryprice);
   }
   virtual void CalcPrice()
   {
      if (!zero_is_nosl && this.ticks == 0) price = this.entryprice;
      else price = getstoplossprice(this.symbol,this.ordertype,(int)this.ticks,this.entryprice);
   }   
      
};

class CTakeProfit : public CStopsCalc {
public:
   virtual int Type() const { return classTakeProfit; }
   CStopsCalc* sl;

   CTakeProfit()
   {
   }
   
   virtual CStopsCalcInterface* SetStopLoss(CStopsCalcInterface* _sl)
   {
      sl = _sl;
      return NULL;
   }

protected:
   virtual void CalcTicks()
   {
      ticks = gettakeprofitticks(this.symbol,this.ordertype,this.price,this.entryprice);
   }
   virtual void CalcPrice()
   {
      price = gettakeprofitprice(this.symbol,this.ordertype,(int)this.ticks,this.entryprice);
   }   
      
};

class CEntryTicks : public CEntry {
public:
   CEntryTicks(double _ticks) {
      this.SetTicks(_ticks);
   }
};

class CEntryPrice : public CEntry {
public:
   bool addspread;
   CEntryPrice() {
   
   }
   CEntryPrice(double _price, bool _addspread = false) {
      addspread = _addspread;
      this.SetPrice(_price);
   }
   virtual double GetPrice()
   {
      double _price = CEntry::GetPrice();
      if (addspread && ordertype_long(this.ordertype)) {
         loadsymbol(this.symbol);
         _price = _price+_symbol.SpreadInPrice();
      }
      return _price;
   }
};

class CEntryCalculate : public CEntryPrice {
public:
   CEntryCalculate()
   {
      addspread = true;
   }
   virtual void Reset()
   {
      price_set = false;
   } 
};


class CStopLossTicks : public CStopLoss {
public:
   CStopLossTicks(double _ticks, bool _zero_is_nosl = true) {
      zero_is_nosl = _zero_is_nosl;
      if (zero_is_nosl && _ticks == 0) this.SetPrice(0);
      else this.SetTicks(_ticks);
   }
};

class CStopLossPrice : public CStopLoss {
public:
   bool addspread;
   CStopLossPrice()
   {
      
   }
   CStopLossPrice(double _price, bool _addspread = false) {
      addspread = _addspread;
      this.SetPrice(_price);
   }
   virtual double GetPrice()
   {
      double _price = CStopLoss::GetPrice();
      if (addspread && ordertype_short(this.ordertype)) {
         loadsymbol(this.symbol);
         _price = _price+_symbol.SpreadInPrice();
      }
      return _price;
   }
};

class CStopLossCalculate : public CStopLossPrice {
public:
   CStopLossCalculate()
   {
      addspread = true;
   }
   virtual void Reset()
   {
      price_set = false;
   } 
};

class CTakeProfitTicks : public CTakeProfit {
public:
   CTakeProfitTicks(double _ticks) {
      if (_ticks == 0) this.SetPrice(0);
      else this.SetTicks(_ticks);
   }
};

class CTakeProfitPrice : public CTakeProfit {
public:
   bool addspread;
   CTakeProfitPrice()
   {
   
   }
   CTakeProfitPrice(double _price, bool _addspread = false) {
      addspread = _addspread;
      this.SetPrice(_price);
   }
   virtual double GetPrice()
   {
      double _price = CTakeProfit::GetPrice();
      if (addspread && ordertype_short(this.ordertype)) {
         loadsymbol(this.symbol);
         _price = _price+_symbol.SpreadInPrice();
      }
      return _price;
   }
};

class CTakeProfitCalculate : public CTakeProfitPrice {
public:
   CTakeProfitCalculate()
   {
      addspread = true;
   }
   virtual void Reset()
   {
      price_set = false;
   } 
};

double getstoplossprice(string in_symbol, int in_ordertype, int in_stoploss, double price=0, bool formodify = false)
{
   if (price == 0) {
      price = getentryprice(in_symbol,in_ordertype,0,0);      
   }

   if (ordertype_long(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_SELL_STOP,in_stoploss,price));
   }
   else if (ordertype_short(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_BUY_STOP,in_stoploss,price));
   }
   else Print(__FUNCTION__,": Invalid Order Type");
   return(0);
}

double gettakeprofitprice(string in_symbol, int in_ordertype, int in_stoploss, double price=0, bool formodify = false)
{
   if (price == 0) {
      price = getentryprice(in_symbol,in_ordertype,0,0);      
   }

   if (ordertype_long(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_SELL_LIMIT,in_stoploss,price));
   }
   else if (ordertype_short(in_ordertype)) {
      return(getentryprice(in_symbol,ORDER_TYPE_BUY_LIMIT,in_stoploss,price));
   }
   else Print(__FUNCTION__,": Invalid Order Type");
   return(0);
}

double getentryprice(string in_symbol, int in_ordertype, int entrydistance, double price = 0)
{
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
   //loadsymbol(in_symbol,__FUNCTION__);

   if (price == 0) {      
      if (ordertype_long(in_ordertype)) price = _symbol.Ask();
      else if (ordertype_short(in_ordertype)) price = _symbol.Bid();
   }
   
   switch (in_ordertype) {
   case (ORDER_TYPE_BUY):
      return(price);
   case (ORDER_TYPE_SELL):
      return(price);
   case (ORDER_TYPE_BUY_LIMIT):
      return(price-entrydistance*_symbol.TickSizeR());
   case (ORDER_TYPE_BUY_STOP):
      return(price+entrydistance*_symbol.TickSizeR());
   case (ORDER_TYPE_SELL_LIMIT):
      return(price+entrydistance*_symbol.TickSizeR());
   case (ORDER_TYPE_SELL_STOP):
      return(price-entrydistance*_symbol.TickSizeR());
   default:
      Print(__FUNCTION__,": Invalid Order Type");
      return(0);      
   }
}

//bool debug = false;

int getstoplossticks(string in_symbol, int in_ordertype, double in_stoploss, double price=0)
{
   //if (debug) Print("getstoplossticks");
   if (in_stoploss == 0)
      return(0);
      
   if (price == 0)
   {
      CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
      //loadsymbol(in_symbol,__FUNCTION__);
      if (ordertype_long(in_ordertype))
         {price = _symbol.Ask();}
      else if (ordertype_short(in_ordertype))
         {price = _symbol.Bid();}
   }

   if (ordertype_long(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_SELL_STOP,in_stoploss,price));
   else if (ordertype_short(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_BUY_STOP,in_stoploss,price));
   
   return(0);
}

int gettakeprofitticks(string in_symbol, int in_ordertype, double in_takeprofit, double price=0)
{
   if (in_takeprofit == 0)
      return(0);

   if (price == 0)
   {
      CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
      //loadsymbol(in_symbol,__FUNCTION__);
      if (ordertype_long(in_ordertype))
         {price = _symbol.Ask();}
      else if (ordertype_short(in_ordertype))
         {price = _symbol.Bid();}
   }

   if (ordertype_long(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_SELL_LIMIT,in_takeprofit,price));
   else if (ordertype_short(in_ordertype))
      return(getentrypriceticks(in_symbol,ORDER_TYPE_BUY_LIMIT,in_takeprofit,price));
   
   return(0);
}

int getprofitticks(string in_symbol, int in_ordertype, double closeprice, double entryprice)
{
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
   if (ordertype_long(in_ordertype)) {
      return(_symbol.InTicks(closeprice-entryprice));
   } else if (ordertype_short(in_ordertype)) {
      return(_symbol.InTicks(-closeprice+entryprice));
   }
   return(0);
}

int getentrypriceticks(string in_symbol,int in_ordertype, double entryprice, double price=0)
{
   //loadsymbol(in_symbol,__FUNCTION__);
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);   
   if (price == 0)
   {
      if (ordertype_long(in_ordertype))
         {price = _symbol.Ask();}
      else if (ordertype_short(in_ordertype))
         {price = _symbol.Bid();}
      else
      {
         Print(__FUNCTION__,": Invalid Order Type");
         return(-1);
      }
   }
   switch (in_ordertype) {
   case ORDER_TYPE_BUY_LIMIT:
   case ORDER_TYPE_SELL_STOP:
      //if (debug) Print(price+"-"+entryprice);
      return(_symbol.InTicks(price-entryprice));
   case ORDER_TYPE_SELL_LIMIT:
   case ORDER_TYPE_BUY_STOP:
      //if (debug) Print("-"+price+"+"+entryprice);
      return(_symbol.InTicks(-price+entryprice));
   }
   return(0);
}

double getcurrententryprice(string in_symbol, int in_ordertype)
{
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
   //loadsymbol(in_symbol,__FUNCTION__);
   double currentprice = 0;
   if (ordertype_long(in_ordertype)) currentprice = _symbol.Ask();
   else if (ordertype_short(in_ordertype)) currentprice = _symbol.Bid();
   return(currentprice);
}

double getcurrentcloseprice(string in_symbol, int in_ordertype)
{
   //loadsymbol(in_symbol,__FUNCTION__);
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
   double currentprice = 0;
   if (ordertype_long(in_ordertype)) currentprice = _symbol.Bid();
   else if (ordertype_short(in_ordertype)) currentprice = _symbol.Ask();
   return(currentprice);
}

bool verifysl(string in_symbol, int in_stoploss)
{
   //loadsymbol(in_symbol,__FUNCTION__);
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
   if ((in_stoploss >= _symbol.MinStopLoss()) || (in_stoploss == 0))
      return(true);
      
   return(false);
}

bool verifytp(string in_symbol, int in_takeprofit)
{
   //loadsymbol(in_symbol,__FUNCTION__);
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
   if ((in_takeprofit >= _symbol.MinTakeProfit()) || (in_takeprofit == 0))
      return(true);
      
   return(false);
}

bool verifyentry(string in_symbol, int in_entry)
{
   //loadsymbol(in_symbol,__FUNCTION__);
   CSymbolInfoInterface* _symbol = global_app().symbolloader.LoadSymbol(in_symbol);
   if (in_entry >= _symbol.StopsLevelInTicks())
      return(true);
   return(false);
}