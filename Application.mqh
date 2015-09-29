//
#define MTP_FRAMEWORK_VERSION 1.2

#include "Loader.mqh"

class CApplication : public CApplicationInterface
{
private:

   CServiceContainer services;

   bool initalized;
     
public:

   CApplication()
   {
      global_application_object = GetPointer(this);
   }

#include "__service_fastaccess_objects.mqh"

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

#include "__service_fastaccess_switch.mqh"	

#ifdef SERVICE_FASTACCESS_SWITCH
  SERVICE_FASTACCESS_SWITCH
#endif
	
      }
      
   }
   
   virtual void Initalize()
   {
      this.SetInitalized();
      services.InitalizeServices();
   }
   
   void SetInitalized() { initalized = true; }
   bool Initalized() { return initalized; }   
   
   CServiceProvider* DeregisterService(ENUM_APPLICATION_SERVICE srv)
   {
      return (CServiceProvider*)services.Detach(services.FindService(srv));
   }

   bool ServiceIsRegistered(ENUM_APPLICATION_SERVICE srv)
   {
      return services.IsRegistered(srv);
   }

   bool ServiceIsRegistered(string servicename)
   {
      return services.IsRegistered(servicename);
   }

   virtual CServiceProvider* GetService(string name) {
      return (CObject*)services.GetService(name);
   }
   
   virtual CServiceProvider* GetService(ENUM_APPLICATION_SERVICE srv) {
      return services.GetService(srv);
   }

   void SetCommandHandler(CAppObject* commandobject, CAppObject* handlerobject)
   {
      Prepare(commandobject);
      Prepare(handlerobject);
      commandobject.CommandHandler(handlerobject);
   }
   
   void SetCommandHandler(CAppObject* commandobject, ENUM_APPLICATION_SERVICE handlerservice)
   {
      Prepare(commandobject);
      commandobject.CommandHandler(GetService(handlerservice));
   }

   void SetCommandHandler(ENUM_APPLICATION_SERVICE commandservice, CAppObject* handlerobject)
   {
      Prepare(handlerobject);
      GetService(commandservice).CommandHandler(handlerobject);
   }
   
   void SetEventListener(CAppObject* eventobject, CAppObject* handlerobject)
   {
      Prepare(eventobject);
      Prepare(handlerobject);
      eventobject.EventListener(handlerobject);
   }
   
   void SetEventListener(CAppObject* eventobject, ENUM_APPLICATION_SERVICE handlerservice)
   {
      Prepare(eventobject);
      eventobject.EventListener(GetService(handlerservice));
   }

   void SetEventListener(ENUM_APPLICATION_SERVICE eventservice, CAppObject* handlerobject)
   {
      Prepare(handlerobject);
      GetService(eventservice).EventListener(handlerobject);
   }
   
   void SetEventListener(int& id, CAppObject* handlerobject)
   {
      Prepare(handlerobject);
      this.eventmanager.Register(id, handlerobject);
   }

   void SetEventListener(int id, ENUM_APPLICATION_SERVICE handlerservice)
   {
      this.eventmanager.Register(id, GetService(handlerservice));
   }
   
   CAppObject* Prepare(CAppObject* obj)
   {
      if (!obj.Initalized()) {
         obj.AppBase(GetPointer(this));
         if (!obj.Initalized()) {
            obj.SetInitalized();
            obj.Initalize();
         }
      }
      return obj;
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
   
   void OnChartEvent(int id, long lparam, double dparam, string sparam)
   {
      services.OnChartEvent(id, lparam, dparam, sparam);
   }
   
   void OnTimer()
   {
      services.OnTimer();
   }

};

CApplication* global_app()
{
   return (CApplication*)global_application_object;
}