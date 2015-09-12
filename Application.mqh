//
#define MTP_FRAMEWORK_VERSION 1.1

#include <Arrays\ArrayObj.mqh>
#include "ApplicationBase.mqh"
#include "ServiceProviderBase\ServiceProvider.mqh"
#include "ServiceContainer.mqh"

#include "ServiceProviderBase\EventHandlerBase.mqh"
#include "ServiceProviderBase\SymbolLoaderBase.mqh"
#include "ServiceProviderBase\OrderManagerBase.mqh"

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
   COrderManagerBase* ordermanager;

   void RegisterService(CServiceProvider* service)
   {
      if (service.srv != srvNone && services.IsRegistered(service.srv)) {
         CServiceProvider* oldservice = DeregisterService(service.srv);
         if (CheckPointer(oldservice) == POINTER_DYNAMIC) delete oldservice;
      }
      Print("Registering Service ",EnumToString(service.srv)," '",service.name,"'");
            
      service.app = GetPointer(this);
      services.Add(service);

      if (service.srv == srvEvent) event = service;
      if (service.srv == srvSymbolLoader) symbolloader = service;
      if (service.srv == srvOrderManager) ordermanager = service;
      
   }
   
   void InitalizeServices()
   {
      services.InitalizeServices();
   }
   
   CServiceProvider* DeregisterService(ENUM_APPLICATION_SERVICE srv)
   {
      return (CServiceProvider*)services.Detach(services.FindService(srv));
   }

   bool ServiceIsRegistered(ENUM_APPLICATION_SERVICE srv)
   {
      return services.IsRegistered(srv);
   }

   virtual CObject* GetService(string name) {
      return (CObject*)services.GetService(name);
   }
   
   virtual CObject* GetService(ENUM_APPLICATION_SERVICE srv) {
      switch (srv) {
         case srvEvent: return (CObject*)event;
         case srvSymbolLoader: return (CObject*)symbolloader;
         case srvOrderManager: return (CObject*)ordermanager;
      }   
      return NULL;
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


