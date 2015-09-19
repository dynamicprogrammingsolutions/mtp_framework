//
#define MTP_FRAMEWORK_VERSION 1.1

#include "Loader.mqh"

class CApplication : public CApplicationInterface
{
private:

   CServiceContainer services;
   CHandlerContainer eventhandlers;
   CHandlerContainer commandhandlers;
   
public:

   CApplication()
   {
      global_application_object = GetPointer(this);
      this.AppBase(GetPointer(this));
   }

#include "Interfaces\ServiceProviders\__service_fastaccess_objects.mqh"

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

#include "Interfaces\ServiceProviders\__service_fastaccess_switch.mqh"	

#ifdef SERVICE_FASTACCESS_SWITCH
  SERVICE_FASTACCESS_SWITCH
#endif
	
      }
      
   }
   
   void RegisterEventHandler(CServiceProvider* handler, ENUM_CLASS_NAMES handled_class)
   {
      eventhandlers.Add(handled_class, handler);
   }

   void RegisterCommandHandler(CServiceProvider* handler, ENUM_CLASS_NAMES handled_class)
   {
      commandhandlers.Add(handled_class, handler);
   }

   bool EventHandlerIsRegistered(ENUM_CLASS_NAMES handled_class)
   {
      return eventhandlers.IsRegistered(handled_class);
   }

   bool CommandHandlerIsRegistered(ENUM_CLASS_NAMES handled_class)
   {
      return commandhandlers.IsRegistered(handled_class);
   }
   
   virtual void Command(CObject* command) {
      CServiceProvider* handler = commandhandlers.GetHandler((ENUM_CLASS_NAMES)command.Type());
      if (handler != NULL) handler.HandleCommand(command);
      else Print(__FUNCTION__,": Command Handler Not Found For ",command.Type());
      delete command;
   }
   
   virtual void Event(CObject* event) {
      CServiceProvider* handler = eventhandlers.GetHandler((ENUM_CLASS_NAMES)event.Type());
      if (handler != NULL) handler.HandleEvent(event);
      else Print(__FUNCTION__,": Event Handler Not Found For ",event.Type());
      delete event;
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

   bool ServiceIsRegistered(string servicename)
   {
      return services.IsRegistered(servicename);
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