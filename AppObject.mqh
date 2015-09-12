//
#include "ApplicationBase.mqh"
#include <Object.mqh>

class CAppObject : public CObject
{
public:
   CApplicationBase* app;
   CAppObject()
   {
      app = global_application_base_object;
   }
};