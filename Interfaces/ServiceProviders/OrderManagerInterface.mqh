//
#include "Loader.mqh"

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
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0)  { AbstractFunctionWarning(__FUNCTION__); return NULL; }
};