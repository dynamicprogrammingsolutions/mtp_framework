//
#include "..\Loader.mqh"
#include "HelperOrderselect.mqh"
#include "EnumOrderEvents.mqh"
#ifdef HELPER_ORDERSELECT_H
#include "StopsCalc.mqh"
#endif

#ifdef STOPS_CALC_H
#include "MoneyManagement.mqh"
#endif

#ifdef MONEY_MANAGEMENT_H
#ifdef __MQL4__
   #include "MT4\Loader.mqh"
#endif

#ifdef __MQL5__
   #include "MT5\Loader.mqh"
#endif
#endif

#ifdef ORDER_MANAGER_PLATFORM_LOADER_H
#include "OrderArray.mqh"
#endif
#ifdef ORDER_ARRAY_H
#include "OrderManager.mqh"
#endif
#ifdef ORDER_MANAGER_H
#include "OrderRepository.mqh"
#endif
#ifdef ORDER_REPOSITORY_H
#define ORDER_MANAGER_LOADER_H
#endif