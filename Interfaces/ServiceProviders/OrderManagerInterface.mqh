//
#include "Loader.mqh"

#define POrderManager shared_ptr<COrderManagerInterface>
#define NewPOrderManager(__obj__) POrderManager::make_shared(__obj__)

#define ORDER_MANAGER_INTERFACE_H
class COrderManagerInterface : public CServiceProvider
{
public:
   virtual void NewOrderObject(CAppObject* obj) { AbstractFunctionWarning(__FUNCTION__); }

   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
      const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                    const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }

   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CMoneyManagementInterface*& _mm_ptp[], CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit, CStopsCalcInterface*& _ptps[],const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CMoneyManagementInterface*& _mm_ptp[], CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit, CStopsCalcInterface*& _ptps[],const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }

   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &mm, PStopsCalc &_price,
                                    PStopsCalc &_stoploss, PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* NewOrder(POrder &_order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &mm, PStopsCalc &_price,
                                    PStopsCalc &_stoploss, PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }

};