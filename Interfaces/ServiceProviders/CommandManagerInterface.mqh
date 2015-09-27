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

   virtual void Send(int id, int i)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual void Send(int id, double d)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual void Send(int id, bool b)
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

   virtual bool SendB(int id, int i)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }

   virtual bool SendB(int id, double d)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }

   virtual bool SendB(int id, bool b)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }
   
   virtual bool SendB(int id, CObject* o, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }

};