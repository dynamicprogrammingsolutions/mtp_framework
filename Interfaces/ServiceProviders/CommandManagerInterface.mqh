//
class CCommandManagerInterface : public CServiceProvider
{
public:
  
   virtual void Register(int& id, CAppObject* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual CAppObject* GetCallBack(int id)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual void Send(int id)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual CObject* SendO(int id)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }


   virtual void Send(int id, int i)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual void Send(int id, CObject* o, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
};