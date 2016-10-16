#include "Loader.mqh"

#define TRIGGERS_H
class CTriggerCB : public CAppObject
{
   base_ptr<CAppObject> *callbackobj;
   int handler_id;
public:
   CTriggerCB(base_ptr<CAppObject> &_callback, int _handler_id)
   {
      callbackobj = GetPointer(_callback);
      handler_id = _handler_id;
   }
   ~CTriggerCB()
   {
      delete callbackobj;
   }
   
   template <typename T>
   void Callback(T &p)
   {
      callbackobj.get().callback(handler_id,p);
   }
   
   template <typename T>
   bool CallbackBool(T &p)
   {
      return callbackobj.get().callback_bool(handler_id,p);
   }

   template <typename T>
   double CallbackDouble(T &p)
   {
      return callbackobj.get().callback_double(handler_id,p);
   }

   template <typename T>
   int CallbackInt(T &p)
   {
      return callbackobj.get().callback_int(handler_id,p);
   }

   template <typename T>
   WAppObject CallbackObj(T &p)
   {
      return callbackobj.get().callback_obj(handler_id,p).get();
   }
   
   void Callback()
   {
      callbackobj.get().callback(handler_id);
   }
   
   bool CallbackBool()
   {
      return callbackobj.get().callback_bool(handler_id);
   }

   double CallbackDouble()
   {
      return callbackobj.get().callback_double(handler_id);
   }

   int CallbackInt()
   {
      return callbackobj.get().callback_int(handler_id);
   }

   WAppObject CallbackObj()
   {
      return callbackobj.get().callback_obj(handler_id);
   }
   
};

class CTriggers : public CObject
{
public:
   TraitGetType(classTriggerManager)
   
public:
   CArrayObject<CArrayObject<CArrayObject<CTriggerCB>>> container;
   
   virtual bool Register(const int classtype, int& trigger_id, shared_ptr<CAppObject> &callback, const int handler_id)
   {
      shared_ptr<CAppObject> *cb = new shared_ptr<CAppObject>(callback);
      return Register(classtype, trigger_id, cb, handler_id);
   }

   virtual bool Register(const int classtype, int& trigger_id, unique_ptr<CAppObject> &callback, const int handler_id)
   {
      unique_ptr<CAppObject> *cb = new unique_ptr<CAppObject>(callback);
      return Register(classtype, trigger_id, cb, handler_id);
   }

   virtual bool Register(const int classtype, int& trigger_id, weak_ptr<CAppObject> &callback, const int handler_id)
   {
      weak_ptr<CAppObject> *cb = new weak_ptr<CAppObject>(callback);
      return Register(classtype, trigger_id, cb, handler_id);
   }

   virtual bool Register(const int classtype, int& trigger_id, CAppObject &callback, const int handler_id)
   {
      weak_ptr<CAppObject> *cb = new weak_ptr<CAppObject>(callback);
      return Register(classtype, trigger_id, cb, handler_id);
   }
   
   virtual bool Register(const int classtype, int& trigger_id, base_ptr<CAppObject> *callback, const int handler_id)
   {
      if (container.Total()-1 < classtype && !container.Resize(classtype+1)) EError_Ret(false)
      if (container.At(classtype) == NULL && !container.Update(classtype,new CArrayObject<CArrayObject<CTriggerCB>>())) {
         EFatal("Cannot add type: "+EnumToString((ENUM_CLASS_NAMES)classtype)); return false;
      }
      
      CArrayObject<CArrayObject<CTriggerCB>> *arr = container.At(classtype);;
      if (arr == NULL) EError_Ret(false)

      if (trigger_id == 0) {
         arr.Add(new CArrayObject<CTriggerCB>());
         trigger_id = container.Total();
      }
      
      int trigger_idx = trigger_id-1;
      if (trigger_idx < 0) EError_Ret(false);
      if (arr.Total() < trigger_idx-1 && !arr.Resize(trigger_idx-1)) EError_Ret(false)
      if (arr.At(trigger_idx) == NULL && !arr.Update(trigger_idx,new CArrayObject<CTriggerCB>())) EError_Ret(false)
      if (arr.At(trigger_idx) == NULL) EError_Ret(false);
      if (!arr.At(trigger_idx).Add(new CTriggerCB(callback,handler_id))) EError_Ret(false);
      
      EInfo(Conc("trigger handler successfully added for ",TypeToString(classtype)));
      
      return true;
   }
   
   CArrayObject<CTriggerCB> *GetCallbacks(const int classtype, const int trigger_id)
   {
      CArrayObject<CArrayObject<CTriggerCB>> *arr = container.At(classtype);
      if (arr == NULL) EError_Ret(NULL);
      if (arr.At(trigger_id-1) == NULL) EError_Ret(NULL);
      //Print(EnumToString(CheckPointer(arr.At(trigger_id-1))));
      return arr.At(trigger_id-1);
   }
   
   void Trigger(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         callbacks.At(i).Callback();
      }
   }
   
   int TriggerInt(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackInt();
      }
      return 0;
   }

   double TriggerDouble(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackDouble();
      }
      return 0;
   }
   
   WAppObject TriggerObj(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackObj();
      }
      return MakeAppObject(NULL);
   }
   
   bool TriggerBool(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackBool();
      }
      return false;
   }
   
   bool TriggerBoolAnd(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      bool ret = true;
      for (int i = 0; i != total; i++) {
         ret = ret && callbacks.At(i).CallbackBool();
      }
      return ret;
   }
   
   bool TriggerBoolOr(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      bool ret = false;
      for (int i = 0; i != total; i++) {
         ret = ret || callbacks.At(i).CallbackBool();
      }
      return ret;
   }

   template<typename T>
   void Trigger(const int classtype, const int trigger_id, T &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         callbacks.At(i).Callback(p);
      }
   }
   
   template<typename T>
   int TriggerInt(const int classtype, const int trigger_id, T &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackInt(p);
      }
   }
   
   template<typename T>
   double TriggerDouble(const int classtype, const int trigger_id, T &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackDouble(p);
      }
   }
   
   template<typename T>
   WAppObject TriggerObj(const int classtype, const int trigger_id, T &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackObj(p);
      }
      return MakeAppObject(NULL);
   }
   
   template<typename T>
   bool TriggerBool(const int classtype, const int trigger_id, T &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackBool(p);
      }
      return false;
   }
   
   template<typename T>
   bool TriggerBoolAnd(const int classtype, const int trigger_id, T &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      bool ret = false;
      for (int i = 0; i != total; i++) {
         ret = ret && callbacks.At(i).CallbackBool(p);
      }
      return ret;
   }
   
   template<typename T>
   bool TriggerBoolOr(const int classtype, const int trigger_id, T &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      int total = callbacks.Total();
      bool ret = true;
      for (int i = 0; i != total; i++) {
         ret = ret || callbacks.At(i).CallbackBool(p);
      }
      return ret;
   }
   
};