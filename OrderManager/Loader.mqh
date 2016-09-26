//
#include "..\Loader.mqh"
#include "HelperOrderselect.mqh"
#ifdef HELPER_ORDERSELECT_H
#include "StopsCalc.mqh"
#endif

#ifdef STOPS_CALC_H
#ifdef __MQL4__
   #include "MT4\Loader.mqh"
#endif

#ifdef __MQL5__
   #include "..\OrderManagerMT5\Loader.mqh"
#endif
#endif

#ifdef ORDER_MANAGER_MT4_LOADER_H
#define ORDER_MANAGER_LOADER_H
#endif

#ifdef ORDER_MANAGER_MT5_LOADER_H
#define ORDER_MANAGER_LOADER_H
#endif
