//

#include "..\Loader.mqh"

#include "..\..\libraries\file.mqh"
#include "..\..\libraries\strfunctions.mqh"
#include "..\..\libraries\objectfunctions.mqh"
#include "..\..\libraries\commonfunctions.mqh"
#include "HelperStateselect.mqh"

#ifdef HELPER_STATESELECT_H
#include "MT4OrderInfo.mqh"
#endif
#ifdef MT4_ORDER_INFO_H
#include "..\..\SymbolInfoMT4\SymbolInfo.mqh"
#include "Trade.mqh"
#endif

#ifdef TRADE_H
#include "OrderBase.mqh"
#endif
#ifdef ORDER_BASE_H
#include "AttachedOrder.mqh"
#endif
#ifdef ATTACHED_ORDER_H
#include "AttachedOrderArray.mqh"
#endif
#ifdef ATTACHED_ORDER_ARRAY_H
#include "Order.mqh"
#endif
#ifdef ORDER_H
#define ORDER_MANAGER_PLATFORM_LOADER_H
#endif
