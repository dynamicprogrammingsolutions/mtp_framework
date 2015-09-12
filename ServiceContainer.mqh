//
#include <Arrays\ArrayObj.mqh>

#include "ServiceProviderBase\ServiceProvider.mqh"

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
   
   bool IsRegistered(string name)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.name == name) return true;
      }
      return false;
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
         if (service.use_ontick) service.OnTick();
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