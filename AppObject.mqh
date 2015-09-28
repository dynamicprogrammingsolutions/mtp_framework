//
#include "Loader.mqh"

class CAppObject : public CObject
{
private:
   CApplicationInterface* appbase;
   
protected:

  bool initalized;
  
   void AbstractFunctionWarning(string function = "")
   {
      Print(function,": Calling Abstract Function Of Object ",EnumToString((ENUM_CLASS_NAMES)this.Type()));
   }
   
   CAppObject* Prepare(CAppObject* obj)
   {
      if (!obj.Initalized()) {
         obj.AppBase(this.AppBase());
         obj.Initalize();
         obj.initalized = true;
      }
      return obj;
   }
   
public:
   void SetInitalized() { initalized = true; }
   bool Initalized() { return initalized; }
   
   virtual void Initalize() {
      //AbstractFunctionWarning(__FUNCTION__);
   }
   
   CApplicationInterface* AppBase() {
      if (CheckPointer(appbase) == POINTER_INVALID) {
         Print("App not set in: ",EnumToString((ENUM_CLASS_NAMES)this.Type()));
         return global_application_object;
      } else {
         return appbase;
      }
   }
   void AppBase(CApplicationInterface* _appbase) {
      appbase = _appbase;
   }
   
   // callback for command:
   //    object parameter is used for return.
   //    if true is returned it means, the command is handled, and other handlers will not be called.
   
   // callback for event:
   //    object parameter is only for input.
   //    return value is used only for events that is called before the action, and false will mean that the action shouln't be done.
   
   virtual bool callback(const int id, CObject*& obj) { AbstractFunctionWarning(__FUNCTION__); return false; }

};

// this is just for protection
CApplicationInterface* global_application_object;