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
   
   virtual void callback() { AbstractFunctionWarning(__FUNCTION__); }
   
   virtual void callback(int i) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void callback(double i) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void callback(CObject* o) { AbstractFunctionWarning(__FUNCTION__); }

   virtual void callback(int i1, int i2) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void callback(int i, bool b) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void callback(int i, double d) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void callback(int i, CObject* o) { AbstractFunctionWarning(__FUNCTION__); }

   virtual bool callback_b() { AbstractFunctionWarning(__FUNCTION__); return false; }
   
   virtual bool callback_b(int i) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool callback_b(double i) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool callback_b(bool b) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool callback_b(CObject* o) { AbstractFunctionWarning(__FUNCTION__); return false; }

   virtual bool callback_b(int i1, int i2) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool callback_b(int i, bool b) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool callback_b(int i, double d) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool callback_b(int i, CObject* o) { AbstractFunctionWarning(__FUNCTION__); return false; }
   
};

// this is just for protection
CApplicationInterface* global_application_object;