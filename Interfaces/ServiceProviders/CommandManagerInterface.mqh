//
class CCommandManagerInterface : public CServiceProvider
{
public:
  
   virtual void Register(int& id, CAppObject* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual CObject* Send(int id, CObject* o = NULL, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
   
};