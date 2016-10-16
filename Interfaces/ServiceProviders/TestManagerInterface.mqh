//
#include "Loader.mqh"

#define PTestManager shared_ptr<CTestManagerInterface>
#define NewPTestManager(__obj__) PTestManager::make_shared(__obj__)

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