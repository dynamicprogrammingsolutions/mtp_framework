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
   ENUM_ORDER_TYPE ordertype;
   double currentprice;
   double entryprice;       

   int ticks;
   double price;   
   bool ticks_set;
   bool price_set;
   virtual void CalcTicks() {}
   virtual void CalcPrice() {}   
     
public:

   virtual CStopsCalc* SetOrderType(ENUM_ORDER_TYPE _ordertype)
   {
      this.ordertype = _ordertype;
      return GetPointer(this);
   }
   
   virtual CStopsCalc* SetSymbol(string __symbol)
   {
      this.symbol = __symbol;
      return GetPointer(this);
   }     
   
   virtual CStopsCalc* SetTicks(int _ticks)
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
   
   virtual int GetTicks()
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
   CEntryTicks(int _ticks) {
      this.SetTicks(_ticks);
   }
};

class CEntryPrice : public CEntry {
public:
   CEntryPrice(double _price) {
      this.SetPrice(_price);
   }
};

class CStopLossTicks : public CStopLoss {
public:
   CStopLossTicks(int _ticks, bool _zero_is_nosl = true) {
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
   CTakeProfitTicks(int _ticks) {
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