//
#include "Loader.mqh"

#define APP_OBJECT_H
class CAppObject : public CObject
{
private:
   CObject* appbase;
   int refcount;
   
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
         if (!obj.initalized) {
            obj.initalized = true;
            obj.Initalize();
         }
      }
      return obj;
   }
   
public:

   CObject* AppBase() {
      if (CheckPointer(appbase) == POINTER_INVALID) {
         #ifndef GLOBAL_APPLICATION_OBJECT
            Print("App not set in: ",EnumToString((ENUM_CLASS_NAMES)this.Type()));
            return NULL;
         #else
            return global_application_object;
         #endif
      } else {
         return appbase;
      }
   }
   
   void AppBase(CObject* _appbase) {
      appbase = _appbase;
   }

   void SetInitalized() { initalized = true; }
   bool Initalized() { return initalized; }
   
   virtual void Initalize() {
      //AbstractFunctionWarning(__FUNCTION__);
   }
   
   //Reference Counting:
   
   bool ReferenceCountActive()
   {
      return true;
   }
   
   /*virtual CAppObject* RefAdd()
   {
      AbstractFunctionWarning(__FUNCTION__);
      return GetPointer(this);
   }

   virtual CAppObject* RefDel()
   {
      AbstractFunctionWarning(__FUNCTION__);
      return GetPointer(this);
   }
   
   virtual void RefClean()
   {
      AbstractFunctionWarning(__FUNCTION__);
   }*/
   
   CAppObject* RefAdd()
   {
      refcount++;
      return GetPointer(this);
   }
   
   CAppObject* RefDel()
   {
      refcount--;
      return GetPointer(this);
   }
   
   void RefClean()
   {
      if (refcount <= 0) {
         //Print("delete object type "+EnumToString((ENUM_CLASS_NAMES)obj.Type()));
         delete GetPointer(this);
      }
   }
   
   int RefCount()
   {
      return refcount;
   }

   
   // callback for command:
   //    object parameter is used for return.
   //    if true is returned it means, the command is handled, and other handlers will not be called.
   
   // callback for event:
   //    object parameter is only for input.
   //    return value is used only for events that is called before the action, and false will mean that the action shouln't be done.
   
   virtual bool callback(const int id, CObject*& obj) { AbstractFunctionWarning(__FUNCTION__); return false; }

};

void ref_clean(CAppObject* obj)
{
   if (obj.ReferenceCountActive()) obj.RefClean();
}

CAppObject* ref_del(CAppObject* obj)
{
   if (obj.ReferenceCountActive()) return obj.RefDel();
   return obj;
}

CAppObject* ref_add(CAppObject* obj)
{
   if (obj.ReferenceCountActive()) return obj.RefAdd();
   else return obj;
}


// this is just for protection
CObject* global_application_object;