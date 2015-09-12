//
#include "EventHandler/EventHandler.mqh"
#include "SymbolLoader/SymbolLoader.mqh"

void register_services()
{
  if (!app().ServiceIsRegistered(srvEvent)) app().RegisterService(new CEventHandler());
  if (!app().ServiceIsRegistered(srvSymbolLoader)) app().RegisterService(new CSymbolLoader());
}