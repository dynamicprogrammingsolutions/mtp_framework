//
#include <Arrays\ArrayObj.mqh>
#include "libraries\commonfunctions.mqh"
#include "libraries\math.mqh"
#include "libraries\file.mqh"
#include "libraries\strfunctions.mqh"
#include "libraries\objectfunctions.mqh"
#include "libraries\commonfunctions.mqh"

#ifdef __MQL5__
#include "mql4to5\constants.mqh"
#include "mql4to5\timeseries.mqh"
#include "mql4to5\objects.mqh"
#include "mql4to5\renamed_functions.mqh"
#include "mql4to5\accountinfo.mqh"
#endif

#include "EnumClassNames.mqh"
#include "EnumApplicationService.mqh"
#include "Traits\Loader.mqh"
#include "ErrorAndEventHandling.mqh"

#include "Ptr.mqh"
#ifdef PTR_H
#include "AppObject.mqh"
#endif
#ifdef APP_OBJECT_H
#include "AppObjectArray.mqh"
#endif
#ifdef APP_OBJECT_ARRAY_H
#include "AppObjectArrayObj.mqh"
#endif
#ifdef APP_OBJECT_ARRAY_OBJ_H
#include "AppObjectArrayObjManaged.mqh"
#endif
#ifdef APP_OBJECT_ARRAY_OBJ_MANAGED_H
#include "ArrayObject.mqh"
#endif

#ifdef ARRAY_OBJECT_H
#include "Triggers.mqh"
#endif
#ifdef TRIGGERS_H
#include "ServiceProvider.mqh"
#endif
#ifdef SERVICE_PROVIDER_H
#include "ServiceProviderArray.mqh"
#endif
#ifdef SERVICE_PROVIDER_ARRAY_H
#include "ServiceProviderArrayObj.mqh"
#endif

#ifdef SERVICE_PROVIDER_ARRAY_OBJ_H
#include "Observable.mqh"
#endif

#ifdef OBSERVABLE_H
#include "Interfaces\Loader.mqh"
#endif
#ifdef INTERFACES_LOADER_H
#include "ServiceContainer.mqh"
#endif
#ifdef SERVICE_CONTAINER_H
#include "Application.mqh"
#endif

#ifdef APPLICATION_H
#define LOADER_H
#endif

#ifdef LOADER_H

#ifdef LOAD_EVENT_HANDLER
#include "EventHandler\EventHandler.mqh"
#endif

#ifdef LOAD_TRIGGER_MANAGER
#include "TriggerManager\TriggerManager.mqh"
#endif

#ifdef LOAD_DEPENDENCY_MANAGER
#include "DependencyManager\DependencyManager.mqh"
#endif

#ifdef LOAD_TEST_MANAGER
#include "TestManager\Loader.mqh"
#endif

#ifdef __MQL4__
#include "SymbolInfoMT4\MTPSymbolInfo.mqh"
#endif

#ifdef __MQL5__
#include "SymbolInfoMT5\MTPSymbolInfo.mqh"
#endif

#ifdef LOAD_SYMBOL_LOADER
#include "SymbolLoader\SymbolLoader.mqh"
#endif

#ifdef LOAD_SCRIPT_MANAGER
#include "ScriptManager\ScriptManagerBase.mqh"
#endif

#ifdef EXPIRATION_DAYS
#include "Modules\Expiration.mqh"
#endif

#ifdef INDICATOR_EXPIRATION_DAYS
#include "Modules\Expiration.mqh"
#endif

void loadservices(CApplication* _application)
{
#ifdef LOAD_EVENT_HANDLER
   _application.RegisterService(new CEventHandler(),srvEvent,"eventhandler");
#endif
#ifdef LOAD_TRIGGER_MANAGER
   _application.RegisterService(new CTriggerManager(),srvTriggerManager,"triggers");
#endif
#ifdef LOAD_DEPENDENCY_MANAGER
   _application.RegisterService(new CDependencyManager(),srvDependencyManager,"dependencymanager");
#endif
#ifdef LOAD_TEST_MANAGER
   _application.RegisterService(new CTestManager(), srvTestManager, "testmanager");
#endif
#ifdef LOAD_SYMBOL_LOADER
   _application.RegisterService(new CSymbolLoader(),srvSymbolLoader,"symbolloader");
#endif
#ifdef LOAD_SCRIPT_MANAGER
   _application.RegisterService(new CScriptManagerBase(),srvScriptManager,"scriptmanager");
#endif
#ifdef EXPIRATION_DAYS
   app.RegisterService(new CExpiration(EXPIRATION_DAYS),srvNone,"expiration");
#endif
#ifdef INDICATOR_EXPIRATION_DAYS
   app.RegisterService(new CExpiration(INDICATOR_EXPIRATION_DAYS),srvNone,"expiration");
#endif

}

#endif

