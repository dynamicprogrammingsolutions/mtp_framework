//
class CServiceProvider : public CAppObject
{
public:
   string name;
   ENUM_APPLICATION_SERVICE srv;
   
   bool use_oninit;
   bool use_ontick;
   bool use_ondeinit;
   
   CApplicationInterface* App()
   {
      return (CApplicationInterface*)this.AppBase();
   }
   
   virtual void OnInit() {
      AbstractFunctionWarning(__FUNCTION__);
     
   }
   
   virtual void OnTick() {
      AbstractFunctionWarning(__FUNCTION__);
     
   }
   
   virtual void OnDeinit() {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual void HandleEvent(CObject* event)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual void HandleCommand(CObject* command)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   
};