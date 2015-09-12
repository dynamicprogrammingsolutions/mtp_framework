//
#include "..\ApplicationBase.mqh"

#include <Object.mqh>

class CServiceProvider : protected CObject
{
public:
   string name;
   CApplicationBase* app;
   bool use_oninit;
   bool use_ontick;
   bool use_ondeinit;
   virtual void OnInit() {}
   virtual void OnTick() {}
   virtual void OnDeinit() {}
   
};