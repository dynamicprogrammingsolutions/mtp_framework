//
class CEventCallBackInterface : public CAppObject
{
public:
   virtual void Function(int id, CObject* obj)
   {
      AbstractFunctionWarning(__FUNCTION__);
   }

   virtual CObject* FunctionRetObj(int id, CObject* obj)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }

   virtual bool FunctionRetBool(int id, CObject* obj)
   {
      AbstractFunctionWarning(__FUNCTION__);
      return NULL;
   }
};