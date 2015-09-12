//
#include "EventHandler/EventHandler.mqh"
#include "SymbolLoader/SymbolLoader.mqh"

void register_services()
{
  if (!app().ServiceIsRegistered("event")) app().RegisterService(new CEventHandler());
  if (!app().ServiceIsRegistered("symbolloader")) app().RegisterService(new CSymbolLoader());
}