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

void register_services()
{
  if (!app().ServiceIsRegistered(srvEvent)) app().RegisterService(new CEventHandler(),srvEvent,"eventhandler");
  if (!app().ServiceIsRegistered(srvSymbolLoader)) app().RegisterService(new CSymbolLoader(),srvSymbolLoader,"symbolloader");
  if (!app().ServiceIsRegistered(srvOrderManager)) app().RegisterService(new COrderManager(),srvOrderManager,"ordermanager");
  if (!app().ServiceIsRegistered(srvOrderFactory)) app().RegisterService(new COrderFactory(),srvOrderFactory,"orderfactory");
  if (!app().ServiceIsRegistered(srvAttachedOrderFactory)) app().RegisterService(new CAttachedOrderFactory(),srvAttachedOrderFactory,"attachedorderfactory");
  
  app().RegisterEventHandler(app().eventhandler,classEventLog);
}