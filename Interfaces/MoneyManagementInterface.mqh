//
#include "..\Loader.mqh"

#define MONEY_MANAGEMENT_INTERFACE_H

#define PMoneyManagement shared_ptr<CMoneyManagementInterface>
#define NewPMoneyManagement(__object__) PMoneyManagement::make_shared(__object__)
#define MakeMoneyManagement(__object__) PMoneyManagement::make_shared(__object__)

class CMoneyManagementInterface : public CAppObject {

public:

   //virtual bool DeleteAfterUse() { return false; }

   virtual CMoneyManagementInterface* SetSymbol(string __symbol)
   {
      return GetPointer(this);
   }
   virtual CMoneyManagementInterface* SetStopLoss(CStopsCalcInterface* _stoploss)
   {
      return GetPointer(this);
   }
   virtual CMoneyManagementInterface* SetOrderType(ENUM_ORDER_TYPE _ordertype)
   {
      return GetPointer(this);
   }
   virtual CMoneyManagementInterface* SetStopLoss(PStopsCalc &_stoploss)
   {
      return GetPointer(this);
   }
   virtual double GetLotsize() { return 0; }
};