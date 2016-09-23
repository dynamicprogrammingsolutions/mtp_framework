#include "..\Loader.mqh"

#include "SymbolInfoInterface.mqh"
#ifdef SYMBOL_INFO_INTERFACE_H
#include "StopsCalcInterface.mqh"
#endif
#ifdef STOPS_CALC_INTERFACE_H
#include "MoneyManagementInterface.mqh"
#endif
#ifdef MONEY_MANAGEMENT_INTERFACE_H
#include "OrderInterface.mqh"
#endif
#ifdef ORDER_INTERFACE_H
#include "TestInterface.mqh"
#endif

#ifdef TEST_INTERFACE_H
#include "ServiceProviders\Loader.mqh"
#endif

#ifdef INTERFACES_SERVICE_PROVIDERS_LOADER_H
#define INTERFACES_LOADER_H
#endif