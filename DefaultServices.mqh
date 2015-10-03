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

#include "SymbolLoader\SymbolInfoVars.mqh"

#include "ChartInfo\IsFirstTick.mqh"

#include "Commands\Loader.mqh"

#include "EntryMethod\EntryMethodBase.mqh"
#include "Signals\SignalManagerBase.mqh"
#include "Commands\OrderCommandHandlerBase.mqh"

#include "ScriptManager\ScriptManagerBase.mqh"
#include "ScriptManager\OrderScriptHandler.mqh"

#include "TrailingStop\TrailingStop.mqh"

#include "EventManager\EventManager.mqh"
#include "CommandManager\CommandManager.mqh"

#include "libraries\comments.mqh"



void register_services()
{
   // logs events like error and notifications
   global_app().RegisterService(new CEventHandler(),srvEvent,"eventhandler");

   // manages events, handlers are registered by SetEventHandler() method
   global_app().RegisterService(new CEventManager(),srvEventManager,"eventmanager");
   
   // manages commands, handlers are registered by SetCommandHandler() method
   global_app().RegisterService(new CCommandManager(),srvCommandManager,"commandmanager");
   
   // loads symbol info
   global_app().RegisterService(new CSymbolLoader(),srvSymbolLoader,"symbolloader");
   
   // manages orders
   global_app().RegisterService(new COrderManager(),srvOrderManager,"ordermanager");
   
   // creates order objects
   global_app().RegisterService(new COrderFactory(),srvOrderFactory,"orderfactory");
   global_app().RegisterService(new CAttachedOrderFactory(),srvAttachedOrderFactory,"attachedorderfactory");
   
   // sets global vars for symbol info easy access
   global_app().RegisterService(new CSymbolInfoVars(Symbol()),srvSymbolInfoVars,"symbolinfovars");
  
}