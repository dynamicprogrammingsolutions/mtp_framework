//
#include "EventHandler/EventHandler.mqh"
#include "SymbolLoader/SymbolLoaderMT5.mqh"

void register_services()
{
  if (!app().ServiceIsRegistered(srvEvent)) app().RegisterService(new CEventHandler());
  if (!app().ServiceIsRegistered(srvSymbolLoader)) app().RegisterService(new CSymbolLoaderMT5());
}