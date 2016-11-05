//
#include "Loader.mqh"

#define APP_OBJECT_H

#define PAppObject shared_ptr<CAppObject>
#define WAppObject weak_ptr<CAppObject>
#define UAppObject unique_ptr<CAppObject>
#define BAppObject base_ptr<CAppObject>
#define NewPAppObject(__object__) PAppObject::make_shared(__object__)
#define MakeAppObject(__object__) PAppObject::make_shared(__object__)
#define MakeWAppObject(__object__) WAppObject::make_weak(__object__)
#define MakeUAppObject(__object__) UAppObject::make_unique(__object__)

class CAppObject : public CObject
{
private:
   CObject* appbase;
   int refcount;
   bool owned_by_unique;
   static int maxid;
   int object_id;
   
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

   CAppObject() : refcount(0), owned_by_unique(false), object_id(maxid+1)
   {
      maxid = this.object_id;
      //Print("constructing object "+this.object_id);
   
   }
   
   int Id() const { return this.object_id; }

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
      if (refcount <= 0 && !owned_by_unique) {
         EDebug("delete shared object type "+EnumToString((ENUM_CLASS_NAMES)this.Type()));
         delete GetPointer(this);
      }
   }

   void UniqueLock()
   {
      owned_by_unique = true;
   }
   
   void UniqueRelease()
   {
      owned_by_unique = false;
   }
   
   void UniqueDelete()
   {
      if (!owned_by_unique) {
         EDebug("delete unique object type "+EnumToString((ENUM_CLASS_NAMES)this.Type()));
         delete GetPointer(this);
      }
   }
   bool Owned() const
   {
      return owned_by_unique;
   }
   int RefCount() const
   {
      return refcount;
   }
   
   /*template<typename T>
   shared_ptr<T> make_shared(T *obj)
   {
      shared_ptr<T> ptr(obj);
      return ptr;
   }*/
   
   // callback for command:
   //    object parameter is used for return.
   //    if true is returned it means, the command is handled, and other handlers will not be called.
   
   // callback for event:
   //    object parameter is only for input.
   //    return value is used only for events that is called before the action, and false will mean that the action shouln't be done.
   
   virtual bool callback(const int id, CObject*& obj) { AbstractFunctionWarning(__FUNCTION__); return false; }

   virtual void callback(const int id, bool obj) { AbstractFunctionWarning(__FUNCTION__); return; }
   virtual CObject* callback_obj(const int id, bool obj) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual bool callback_bool(const int id, bool obj) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual double callback_double(const int id, bool obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int callback_int(const int id, bool obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual void callback(const int id, int obj) { AbstractFunctionWarning(__FUNCTION__); return; }
   virtual CObject* callback_obj(const int id, int obj) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual bool callback_bool(const int id, int obj) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual double callback_double(const int id, int obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int callback_int(const int id, int obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual void callback(const int id, double obj) { AbstractFunctionWarning(__FUNCTION__); return; }
   virtual CObject* callback_obj(const int id, double obj) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual bool callback_bool(const int id, double obj) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual double callback_double(const int id, double obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int callback_int(const int id, double obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual void callback(const int id, BAppObject &obj) { AbstractFunctionWarning(__FUNCTION__); return; }
   virtual CObject* callback_obj(const int id, BAppObject &obj) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual bool callback_bool(const int id, BAppObject &obj) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual double callback_double(const int id, BAppObject &obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int callback_int(const int id, BAppObject &obj) { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual void callback(const int id) { AbstractFunctionWarning(__FUNCTION__); return; }
   virtual CObject* callback_obj(const int id) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual bool callback_bool(const int id) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual double callback_double(const int id) { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int callback_int(const int id) { AbstractFunctionWarning(__FUNCTION__); return 0; }

};

int CAppObject::maxid = 0;

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