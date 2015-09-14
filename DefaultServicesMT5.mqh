//
#include "EventHandler\EventHandler.mqh"
#include "SymbolLoader\SymbolLoaderMT5.mqh"
#include "OrderManagerMT5\OrderManager.mqh"
#include "OrderManager\OrderFactory.mqh"
#include "OrderManager\AttachedOrderFactory.mqh"

void register_services()
{
  if (!app().ServiceIsRegistered(srvEvent)) app().RegisterService(new CEventHandler());
  if (!app().ServiceIsRegistered(srvSymbolLoader)) app().RegisterService(new CSymbolLoaderMT5());
  if (!app().ServiceIsRegistered(srvOrderManager)) app().RegisterService(new COrderManager());
  if (!app().ServiceIsRegistered(srvOrderFactory)) app().RegisterService(new COrderFactory());
  if (!app().ServiceIsRegistered(srvAttachedOrderFactory)) app().RegisterService(new CAttachedOrderFactory());
}