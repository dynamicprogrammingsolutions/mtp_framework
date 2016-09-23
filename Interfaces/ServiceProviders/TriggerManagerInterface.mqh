//

#include "Loader.mqh"

#define TRIGGER_MANAGER_INTERFACE_H
class CTriggerManagerInterface : public CServiceProvider
{
public:

   virtual void Register(int& trigger_id, CAppObject* callback, int handler_id)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual bool Send(const int id)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }
   
   virtual bool SendR(const int id, CObject* o, const bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }
   
   virtual bool Send(const int id, CObject*& o, const bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }

};

