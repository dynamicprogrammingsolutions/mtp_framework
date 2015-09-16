//
#define MTP_FRAMEWORK_VERSION 1.1

#include "Loader.mqh"

class CApplication : public CApplicationBase
{
private:

   CServiceContainer services;
public:

   CApplication()
   {
      global_application_object = GetPointer(this);
      this.AppBase(GetPointer(this));
   }

#include "ServiceProviderBase\__service_fastaccess_objects.mqh"

#ifdef SERVICE_FASTACCESS_OBJECTS
  SERVICE_FASTACCESS_OBJECTS
#endif

   void RegisterService(CServiceProvider* service, ENUM_APPLICATION_SERVICE srv, string servicename)
   {
      service.srv = srv;
      service.name = servicename;
      
      if (service.srv != srvNone && services.IsRegistered(service.srv)) {
         CServiceProvider* oldservice = DeregisterService(service.srv);
         if (CheckPointer(oldservice) == POINTER_DYNAMIC) delete oldservice;
      }
      Print("Registering Service type:",EnumToString(service.srv)," name:'",service.name,"' class:",EnumToString((ENUM_CLASS_NAMES)service.Type()));
            
      service.AppBase(GetPointer(this));
      services.Add(service);

      switch(service.srv) {

#include "ServiceProviderBase\__service_fastaccess_switch.mqh"	

#ifdef SERVICE_FASTACCESS_SWITCH
  SERVICE_FASTACCESS_SWITCH
#endif
	
      }
      
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
      return services.GetService(srv);
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

CApplication* app()
{
   return (CApplication*)global_application_object;
}