//
class CStopsCalcBase : public CAppObject
{
public:
   virtual CStopsCalcBase* SetOrderType(ENUM_ORDER_TYPE _ordertype)
   {
      AbstractFunctionWarning(__FUNCTION__); 
      return NULL;
   }
   
   virtual CStopsCalcBase* SetSymbol(string __symbol)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }     
   
   virtual CStopsCalcBase* SetTicks(double _ticks)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual CStopsCalcBase* SetPrice(double _price)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual CStopsCalcBase* SetCurrentPrice(double _currentprice)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual CStopsCalcBase* SetEntryPrice(double _entryprice)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual double GetTicks()
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual double GetPrice()
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }    
};
