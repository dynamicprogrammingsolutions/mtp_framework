//
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