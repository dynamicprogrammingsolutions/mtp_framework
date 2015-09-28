//
class CEventManagerInterface : public CServiceProvider
{
public:
  
   virtual void Register(int& id, CAppObject* callback)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual bool Send(const int id, CObject* o = NULL, const bool deleteobject = false)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return false;
   }

};