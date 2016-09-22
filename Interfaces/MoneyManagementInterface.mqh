//
class CMoneyManagementInterface : public CAppObject {

public:

   virtual bool DeleteAfterUse() { return false; }

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
   virtual double GetLotsize() { return 0; }
};