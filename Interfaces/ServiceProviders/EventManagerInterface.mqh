//
class CEventManagerInterface : public CServiceProvider
{
public:
  
   virtual void Register(int& id, CAppObject* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual void Send(int id)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual void Send(int id, CObject* o, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual bool SendB(int id)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }

};