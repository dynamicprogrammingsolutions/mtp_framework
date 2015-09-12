//
#include "tradefunctions.mqh"

/*enum ENUM_STOPTYPE {
   STOPTYPE_ENTRY,
   STOPTYPE_STOPLOSS,
   STOPTYPE_TAKEPROFIT
};*/

class CStopsCalc : private CObject
{
protected:
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

   virtual CStopsCalc* SetOrderType(int _ordertype)
   {
      ordertype_set = true;
      this.ordertype = _ordertype;
      return GetPointer(this);
   }
   
   virtual CStopsCalc* SetSymbol(string __symbol)
   {
      symbol_set = true;
      this.symbol = __symbol;
      return GetPointer(this);
   }     
   
   virtual CStopsCalc* SetTicks(double _ticks)
   {
      ticks_set = true;
      ticks = _ticks;
      return GetPointer(this);
   }
   
   virtual CStopsCalc* SetPrice(double _price)
   {
      price_set = true;
      price = _price;
      return GetPointer(this);
   }
   
   virtual CStopsCalc* SetCurrentPrice(double _currentprice)
   {
      currentprice = _currentprice;      
      return GetPointer(this);
   }
   
   virtual CStopsCalc* SetEntryPrice(double _entryprice)
   {
      entryprice = _entryprice;      
      return GetPointer(this);
   }
   
   virtual double GetTicks()
   {
      if (ticks_set) return ticks;
      if (price_set){
         this.CalcTicks();
         return ticks;
      }
      return(0);
   }
   
   virtual double GetPrice()
   {
      if (price_set) return price;
      if (ticks_set){
         this.CalcPrice();
         return price;
      }
      return(0);
   }    
};

class CEntry : public CStopsCalc {

protected:
   virtual void CalcTicks()
   {
      ticks = getentrypriceticks(this.symbol,this.ordertype,this.price,this.currentprice);
   }
   virtual void CalcPrice()
   {
      price = getentryprice(this.symbol,this.ordertype,this.ticks,this.currentprice);
   }   
   
};

class CStopLoss : public CStopsCalc {

protected:
   bool zero_is_nosl;

   virtual void CalcTicks()
   {
      ticks = getstoplossticks(this.symbol,this.ordertype,this.price,this.entryprice);
   }
   virtual void CalcPrice()
   {
      if (!zero_is_nosl && this.ticks == 0) price = this.entryprice;
      else price = getstoplossprice(this.symbol,this.ordertype,this.ticks,this.entryprice);
   }   
      
};

class CTakeProfit : public CStopsCalc {

protected:
   virtual void CalcTicks()
   {
      ticks = gettakeprofitticks(this.symbol,this.ordertype,this.price,this.entryprice);
   }
   virtual void CalcPrice()
   {
      price = gettakeprofitprice(this.symbol,this.ordertype,this.ticks,this.entryprice);
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
   double chartprice;
   CEntryPrice(double _price, bool _addspread = false) {
      addspread = _addspread;
      chartprice = _price;
      this.SetPrice(chartprice);
   }
   virtual CStopsCalc* SetPrice(double _price)
   {
      if (!addspread) {
         CStopsCalc::SetPrice(_price);
      } else if (symbol_set && symbol_set) {
         if (ordertype_long(this.ordertype)) {
            loadsymbol(this.symbol,__FUNCTION__);
            Print("adding spread to price "+_price+" spread: "+_symbol.SpreadInPrice());
            CStopsCalc::SetPrice(_price+_symbol.SpreadInPrice());
         } else {
            CStopsCalc::SetPrice(_price);
         }
      }
      return GetPointer(this);
   }
   virtual CStopsCalc* SetOrderType(int _ordertype)
   {
      CStopsCalc::SetOrderType(_ordertype);
      if (!price_set && symbol_set)
         this.SetPrice(chartprice);
      return GetPointer(this);
   }
   virtual CStopsCalc* SetSymbol(string __symbol)
   {
      CStopsCalc::SetSymbol(__symbol);
      if (!price_set && ordertype_set) 
         this.SetPrice(chartprice);
      return GetPointer(this);
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
   CStopLossPrice(double _price) {
      this.SetPrice(_price);
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
   CTakeProfitPrice(double _price) {
      this.SetPrice(_price);
   }
};