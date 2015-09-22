//
#include "EventHandler\EventHandler.mqh"
#include "SymbolLoader\SymbolLoader.mqh"
#ifdef __MQL4__
#include "OrderManagerMT4\OrderManager.mqh"
#endif
#ifdef __MQL5__
#include "OrderManagerMT5\OrderManager.mqh"
#endif
#include "OrderManager\OrderFactory.mqh"
#include "OrderManager\AttachedOrderFactory.mqh"
#include "Events\Loader.mqh"
#include "SymbolLoader\SymbolInfoVars.mqh"

#include "ChartInfo\IsFirstTick.mqh"
#include "EntryMethod\EntryMethodBase.mqh"
#include "Signals\SignalManagerBase.mqh"
#include "Commands\OrderCommandHandlerBase.mqh"

#include "ScriptManager\ScriptManagerBase.mqh"
#include "ScriptManager\OrderScriptHandler.mqh"

#include <mtp_framework_1.1\libraries\comments.mqh>


void register_services()
{
  global_app().RegisterService(new CEventHandler(),srvEvent,"eventhandler");
  global_app().RegisterService(new CSymbolLoader(),srvSymbolLoader,"symbolloader");
  global_app().RegisterService(new COrderManager(),srvOrderManager,"ordermanager");
  global_app().RegisterService(new COrderFactory(),srvOrderFactory,"orderfactory");
  global_app().RegisterService(new CAttachedOrderFactory(),srvAttachedOrderFactory,"attachedorderfactory");
  global_app().RegisterService(new CSymbolInfoVars(Symbol()),srvSymbolInfoVars,"symbolinfovars");
  
  global_app().RegisterEventHandler(global_app().eventhandler,classEventLog);
}