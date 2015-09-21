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

#include <mtp_framework_1.1\libraries\comments.mqh>


void register_services()
{
  app().RegisterService(new CEventHandler(),srvEvent,"eventhandler");
  app().RegisterService(new CSymbolLoader(),srvSymbolLoader,"symbolloader");
  app().RegisterService(new COrderManager(),srvOrderManager,"ordermanager");
  app().RegisterService(new COrderFactory(),srvOrderFactory,"orderfactory");
  app().RegisterService(new CAttachedOrderFactory(),srvAttachedOrderFactory,"attachedorderfactory");
  
  app().RegisterEventHandler(app().eventhandler,classEventLog);
}