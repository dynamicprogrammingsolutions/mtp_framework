//
#include "..\..\Loader.mqh"

class CEventManagerInterface : public CServiceProvider
{
public:
   virtual int SetId(int& id)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return 0;
   }
  
   virtual void Register(int& id, CAppObject* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual void RegisterOnly(const int id, CAppObject* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual bool Send(const int id, CObject* o = NULL, const bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }

};