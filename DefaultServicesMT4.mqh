//
#include "EventHandler/EventHandler.mqh"
#include "SymbolLoader/SymbolLoaderMT4.mqh"
#include "OrderManagerMT4/OrderManager.mqh"
#include "OrderManagerMT4/OrderFactory.mqh"

void register_services()
{
  if (!app().ServiceIsRegistered(srvEvent)) app().RegisterService(new CEventHandler());
  if (!app().ServiceIsRegistered(srvSymbolLoader)) app().RegisterService(new CSymbolLoaderMT4());
  if (!app().ServiceIsRegistered(srvOrderManager)) app().RegisterService(new COrderManager());
  if (!app().ServiceIsRegistered(srvOrderFactory)) app().RegisterService(new COrderFactory());
}