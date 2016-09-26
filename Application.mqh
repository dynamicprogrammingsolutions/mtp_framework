//
#define MTP_FRAMEWORK_VERSION "1.4"

#include "Loader.mqh"

#define APPLICATION_H
class CApplication : public CApplicationInterface
{
private:

   CServiceContainer services;

   bool initalized;
     
public:

   CApplication()
   {
      #ifdef GLOBAL_APPLICATION_OBJECT
         global_application_object = GetPointer(this);
         app = GetPointer(this);
      #endif
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
         service.AppBase(GetPointer(this));
         services.ReRegister(service);
      } else {
         Print("Registering Service type:",EnumToString(service.srv)," name:'",service.name,"' class:",EnumToString((ENUM_CLASS_NAMES)service.Type()));
               
         service.AppBase(GetPointer(this));
         services.Add(service);
      }

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

   CObject* NewObject(CAppObject* callback)
   {
      CObject* obj;
      callback.callback(0,obj);
      return Prepare(obj);
   }
   
   void SetDependency(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency, CAppObject* callback)
   {
      dependencymanager.SetDependency(caller,dependency,callback);
   }
   
   CAppObject* GetDependency(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency)
   {
      return dependencymanager.GetDependency(caller,dependency);
   }
   
   bool DependencyIsSet(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency)
   {
      return dependencymanager.DependencyIsSet(caller,dependency);
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
   
   void OnDeinit(const int reason)
   {
      services.OnDeinit(reason);
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


#ifdef GLOBAL_APPLICATION_OBJECT
CApplication* App()
{
   return (CApplication*)global_application_object;
}

CApplication* app;
#endif

