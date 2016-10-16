//
#include "..\Loader.mqh"

#define TEST_INTERFACE_H

#define PTest shared_ptr<CTestInterface>
#define NewPTest(__object__) PTest::make_shared(__object)
#define MakeTest(__object__) PTest::make_shared(__object)

class CTestInterface : public CAppObject
{
public:
   virtual bool IsStarted()
   {
      return false;
   }
   
   virtual bool IsRunning()
   {
      return false;
   }
   
   virtual bool IsEnded()
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