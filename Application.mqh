//
#define MTP_FRAMEWORK_VERSION 1.1

#include <Arrays\ArrayObj.mqh>
#include "ApplicationBase.mqh"
#include "ServiceProviderBase\ServiceProvider.mqh"
#include "ServiceContainer.mqh"

#include "ServiceProviderBase\EventHandlerBase.mqh"
#include "ServiceProviderBase\SymbolLoaderBase.mqh"

class CApplication : public CApplicationBase
{
private:

   CServiceContainer services;
public:

   CApplication()
   {
      global_application_object = GetPointer(this);
   }

   CEventHandlerBase* event;
   CSymbolLoaderBase* symbolloader;
   
   /*void RegisterDefaultServices()
   {
      if (!ServiceIsRegistered("event")) RegisterService(new CEventHandler());
   }*/
   
   void RegisterService(CServiceProvider* service)
   {
      if (services.IsRegistered(service.name)) {
         //Print(__FUNCTION__,": Service '",service.name,"' is already registered.");
         CServiceProvider* oldservice = DeregisterService(service.name);
         if (CheckPointer(oldservice) == POINTER_DYNAMIC) delete oldservice;
      }
      service.app = GetPointer(this);
      services.Add(service);
      
      if (service.name == "event") event = service;
      if (service.name == "symbolloader") symbolloader = service;
   }
   
   CServiceProvider* DeregisterService(string service)
   {
      return (CServiceProvider*)services.Detach(services.FindService(service));
   }

   bool ServiceIsRegistered(string service)
   {
      return services.IsRegistered(service);
   }

   void OnInit()
   {
      services.OnInit();
   }
   
   void OnTick()
   {
      services.OnTick();
   }
   
   void OnDeinit()
   {
      services.OnDeinit();
   }

};


CApplication* global_application_object;

CApplication* app()
{
   return global_application_object;
}


