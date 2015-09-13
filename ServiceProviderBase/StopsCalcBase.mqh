//
class CStopsCalcBase : public CAppObjectWithBaseServices
{
public:
   virtual CStopsCalcBase* SetOrderType(ENUM_ORDER_TYPE _ordertype)
   {
      return NULL;
   }
   
   virtual CStopsCalcBase* SetSymbol(string __symbol)
   {
      return NULL;
   }     
   
   virtual CStopsCalcBase* SetTicks(double _ticks)
   {
      return NULL;
   }
   
   virtual CStopsCalcBase* SetPrice(double _price)
   {
      return NULL;
   }
   
   virtual CStopsCalcBase* SetCurrentPrice(double _currentprice)
   {
      return NULL;
   }
   
   virtual CStopsCalcBase* SetEntryPrice(double _entryprice)
   {
      return NULL;
   }
   
   virtual double GetTicks()
   {
      return NULL;
   }
   
   virtual double GetPrice()
   {
      return NULL;
   }    
};
