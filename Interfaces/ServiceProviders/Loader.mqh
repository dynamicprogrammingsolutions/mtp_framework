//
#include "..\Loader.mqh"

#include "EventHandlerInterface.mqh"
#ifdef EVENT_HANDLER_INTERFACE_H
#include "SymbolLoaderInterface.mqh"
#endif
#ifdef SYMBOL_LOADER_INTERFACE_H
#include "OrderManagerInterface.mqh"
#endif
#ifdef ORDER_MANAGER_INTERFACE_H
#include "OrderRepositoryInterface.mqh"
#endif
#ifdef ORDER_REPOSITORY_INTERFACE_H
#include "ScriptManagerInterface.mqh"
#endif
#ifdef SCRIPT_MANAGER_INTERFACE_H
#include "TestManagerInterface.mqh"
#endif
#ifdef TEST_MANAGER_INTERFACE_H
#include "DependencyManagerInterface.mqh"
#endif
#ifdef DEPENDENCY_MANAGER_INTERFACE_H
#include "TriggerManagerInterface.mqh"
#endif

#ifdef TRIGGER_MANAGER_INTERFACE_H
#define INTERFACES_SERVICE_PROVIDERS_LOADER_H
#endif
