//
class CCommandManagerInterface : public CServiceProvider
{
public:
  
   virtual void Register(int& id, CAppObject* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual CAppObject* Send(int id)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual CAppObject* Send(int id, int i)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual CAppObject* Send(int id, double d)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual CAppObject* Send(int id, bool b)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
   virtual CAppObject* Send(int id, CObject* o, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

};