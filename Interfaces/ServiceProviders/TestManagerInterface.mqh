//
#include "Loader.mqh"

#define TEST_MANAGER_INTERFACE_H
class CTestManagerInterface : public CServiceProvider
{
public:
   virtual void AddTest(CTestInterface* test)
   {
   }
   
   virtual bool IsRunning()
   {
      return false;
   }
   
   virtual void Start()
   {
   }
   
   virtual void Stop()
   {
   }
   
   virtual void OnTick()
   {
   }  
};