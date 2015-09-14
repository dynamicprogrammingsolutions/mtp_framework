//
class CAppObject : public CObject
{
private:
   CApplicationBase* appbase;
protected:
   void AbstractFunctionWarning(string function = "")
   {
      Print(function,": Calling Abstract Function Of Object ",EnumToString((ENUM_CLASS_NAMES)this.Type()));
   }
   CAppObject* Prepare(CAppObject* obj)
   {
      obj.AppBase(this.AppBase());
      obj.Initalize();
      return obj;
   }
   
public:
   virtual void Initalize() {
      //AbstractFunctionWarning(__FUNCTION__);
   }
   CApplicationBase* AppBase() {
      if (CheckPointer(appbase) == POINTER_INVALID) {
         Print("App not set in: ",EnumToString((ENUM_CLASS_NAMES)this.Type()));
         return global_application_base_object;
      } else {
         return appbase;
      }
   }
   void AppBase(CApplicationBase* _appbase) {
      appbase = _appbase;
   }
};