//
#include "libraries\math.mqh"
#include "libraries\time.mqh"
#include "libraries\arrays.mqh"
#include "libraries\strfunctions.mqh"
#include "libraries\commonfunctions.mqh"
#include "libraries\comments.mqh"

#include "EventHandler\EventHandler.mqh"
#include "TestManager\Loader.mqh"
#include "EventManager\EventManager.mqh"
#include "CommandManager\CommandManager.mqh"
#include "DependencyManager\DependencyManager.mqh"

#include "Commands\Loader.mqh"
#include "Tests\Loader.mqh"

#include "SymbolLoader\SymbolLoader.mqh"
#include "OrderManager\Loader.mqh"
#ifdef __MQL4__
#include "OrderManagerMT4\Loader.mqh"
#endif
#ifdef __MQL5__
#include "OrderManagerMT5\Loader.mqh"
#endif
#include "SymbolLoader\SymbolInfoVars.mqh"
#include "Commands\OrderCommandHandlerBase.mqh"

#include "Signals\Signal.mqh"
#include "EntryMethod\EntryMethodSignal.mqh"
#include "ScriptManager\ScriptManagerBase.mqh"
#include "ScriptManager\OrderScriptHandler.mqh"

#include "ChartInfo\IsFirstTick.mqh"
#include "TrailingStop\TrailingStop.mqh"

void register_services()
{
   // logs events like error and notifications
   global_app().RegisterService(new CEventHandler(),srvEvent,"eventhandler");

   // manages events, handlers are registered by SetEventHandler() method
   global_app().RegisterService(new CEventManager(),srvEventManager,"eventmanager");
   
   // manages commands, handlers are registered by SetCommandHandler() method
   global_app().RegisterService(new CCommandManager(),srvCommandManager,"commandmanager");
   
   global_app().RegisterService(new CDependencyManager(),srvDependencyManager,"dependencymanager");
   
   // loads symbol info
   global_app().RegisterService(new CSymbolLoader(),srvSymbolLoader,"symbolloader");
   
   // manages orders
   global_app().RegisterService(new COrderManager(new COrder),srvOrderManager,"ordermanager");
   global_app().SetDependency(classOrder,classAttachedOrder,new CAttachedOrder());
   
   // sets global vars for symbol info easy access
   global_app().RegisterService(new CSymbolInfoVars(Symbol()),srvSymbolInfoVars,"symbolinfovars");
  
}