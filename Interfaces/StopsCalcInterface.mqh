//
#include "..\Loader.mqh"

#define STOPS_CALC_INTERFACE_H

#define PStopsCalc shared_ptr<CStopsCalcInterface>
#define NewPStopsCalc(__object__) PStopsCalc::make_shared(__object__)
#define MakeStopsCalc(__object__) PStopsCalc::make_shared(__object__)

class CStopsCalcInterface : public CAppObject
{
public:
   virtual bool DeleteAfterUse() { return false; }

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
   
   virtual CStopsCalcInterface* SetTakeProfit(CStopsCalcInterface* _tp)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual CStopsCalcInterface* SetStopLoss(CStopsCalcInterface* _sl)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual CStopsCalcInterface* SetTakeProfit(PStopsCalc &_tp)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual CStopsCalcInterface* SetStopLoss(PStopsCalc &_sl)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual void Calculate()
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual void Reset()
   {
      AbstractFunctionWarning(__FUNCTION__);
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
