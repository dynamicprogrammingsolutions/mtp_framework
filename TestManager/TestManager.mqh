//
#include "Loader.mqh"

class CTestManager : public CTestManagerInterface
{
private:
   CArrayObj tests;
   bool started;
   bool ended;
   
public:
   virtual void Initalize()
   {
      for (int i = 0; i < tests.Total(); i++) {
         CTestInterface* test = tests.At(i);
         Prepare(test);
      }
   }

   virtual void AddTest(CTestInterface* test)
   {
      tests.Add(test);
   }
   
   virtual void Start()
   {
      if (tests.Total() == 0) return;
      started = true;
      use_ontick = true;
   }
   
   virtual void Stop()
   {
      ended = true;
      use_ontick = false;
   }
   
   virtual bool IsRunning()
   {
      return started && !ended;
   }
   
   virtual void OnTick()
   {
      for (int i = 0; i < tests.Total(); i++) {
         CTestInterface* test = tests.At(i);
         if (!test.IsStarted()) {
	         test.Start();
         }
         if (test.IsRunning()) {
            test.OnTick();
         }
         if (test.IsEnded()) {
            continue;
         }
         return;
      }
      Stop();
   }

};