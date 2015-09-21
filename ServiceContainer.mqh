//
#include "Loader.mqh"

class CServiceContainer : public CArrayObj
{
public:
   CServiceProvider* ServiceProvider(int i)
   {
      CObject* obj = At(i);
      if (CheckPointer(obj) != POINTER_INVALID)
         return (CServiceProvider*)obj;
      else
         return NULL;
   }
   
   int FindService(string name)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.name == name) return i;
      }
      return -1;
   }
   
   int FindService(ENUM_APPLICATION_SERVICE srv)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.srv == srv) return i;
      }
      Print(__FUNCTION__,": Cannot Find Service: ",EnumToString(srv));
      return -1;
   }
   
   CServiceProvider* GetService(string name)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.name == name) return service;
      }
      return NULL;
   }
   
   CServiceProvider* GetService(ENUM_APPLICATION_SERVICE srv)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.srv == srv) return service;
      }
      Print("not found: ",EnumToString(srv));
      return NULL;
   }
   
   bool IsRegistered(ENUM_APPLICATION_SERVICE srv)
   {
      if (srv == srvNone) return false;
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.srv == srv) return true;
      }
      return false;
   }
   
   bool IsRegistered(string servicename)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.name == servicename) return true;
      }
      return false;
   }
   
   void InitalizeServices()
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (!service.Initalized()) {
            Print("Initalizing Service ",EnumToString(service.srv)," '",service.name,"': ",EnumToString((ENUM_CLASS_NAMES)service.Type()));
            service.Initalize();
            service.SetInitalized();
         } else {
            Print("Service Alread Initalized: ",EnumToString((ENUM_CLASS_NAMES)service.Type()));
         }
      }
   }
   
   void OnInit()
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_oninit) service.OnInit();
      }
   }
   
   void OnTick()
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_ontick) {
            service.OnTick();
         }
      }
   }
   
   void OnDeinit()
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_ondeinit) service.OnDeinit();
      }
   }
};