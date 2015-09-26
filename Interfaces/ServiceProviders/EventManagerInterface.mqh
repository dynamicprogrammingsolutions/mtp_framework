//
class CEventManagerInterface : public CServiceProvider
{
public:
  
   virtual void Register(int& geteventid, CEventCallBackInterface* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }
   
   virtual void Send(int eventid, CObject* eventobject = NULL)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual CObject* SendRetObj(int eventid, CObject* eventobject = NULL)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return eventobject;
   }

   virtual bool SendRetBool(int eventid, CObject* eventobject = NULL, bool defaultreturn = true)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return defaultreturn;
   }

};