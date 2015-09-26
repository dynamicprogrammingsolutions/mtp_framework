//
class CCommandManagerInterface : public CServiceProvider
{
public:
  
   virtual void Register(int& id, CCallBackInterface* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual void Send(int id, CObject* object = NULL, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual CObject* SendRetObj(int id, CObject* object = NULL, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return object;
   }

   virtual bool SendRetBool(int id, CObject* object = NULL, bool defaultreturn = true, bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return defaultreturn;
   }

};