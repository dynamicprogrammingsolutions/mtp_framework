//
class CStopsCalcInterface : public CAppObject
{
public:
   virtual CStopsCalcInterface* SetOrderType(ENUM_ORDER_TYPE _ordertype)
   {
      AbstractFunctionWarning(__FUNCTION__); 
      return NULL;
   }
   
   virtual CStopsCalcInterface* SetSymbol(string __symbol)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }     
   
   virtual CStopsCalcInterface* SetTicks(double _ticks)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual CStopsCalcInterface* SetPrice(double _price)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual CStopsCalcInterface* SetCurrentPrice(double _currentprice)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual CStopsCalcInterface* SetEntryPrice(double _entryprice)
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
