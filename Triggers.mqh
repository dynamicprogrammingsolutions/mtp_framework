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
   PAppObject CallbackObj(T &p)
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

   PAppObject CallbackObj()
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
   
   virtual int Count()
   {
      int cnt = 0;
      CArrayObject<CArrayObject<CTriggerCB>> *classlist;
      while(container.ForEach(classlist)) {
         if (isset(classlist)) {
            CArrayObject<CTriggerCB> *triggerlist;
            while(classlist.ForEach(triggerlist)) {
               if (isset(triggerlist)) {
                  CTriggerCB *cblist;
                  while(triggerlist.ForEach(cblist)) {
                     if (isset(cblist)) cnt++;
                  }
               }
            }
         }
      }
      return cnt;
   }
   
   bool DeRegister(const int classtype)
   {
      if (container.DeletePosition(classtype)) {
         EInfo(Conc("trigger handler deregistered for ",TypeToString(classtype)));
         return true;
      }
      return false;
   }
   
   bool DeRegister(const int classtype, int trigger_id)
   {
      if (container.At(classtype) == NULL) {return false;}
      if (container.At(classtype).DeletePosition(trigger_id)) {
         EInfo(Conc("trigger handler deregistered for ",TypeToString(classtype)," trigger id: ",trigger_id));
         return true;
      }   
      return false;   
   }
   
   bool Register(const int classtype, int& trigger_id, base_ptr<CAppObject> &callback, const int handler_id)
   {
      //shared_ptr<CAppObject> *cb = new shared_ptr<CAppObject>(callback);
      return Register(classtype, trigger_id, GetPointer(callback), handler_id, true);
   }

   bool Register(const int classtype, int& trigger_id, CAppObject &callback, const int handler_id)
   {
      weak_ptr<CAppObject> *cb = new weak_ptr<CAppObject>(callback);
      return Register(classtype, trigger_id, cb, handler_id, true);
   }

   bool Register(const int classtype, uint trigger_id, base_ptr<CAppObject> &callback, const int handler_id)
   {
      int _trigger_id = (int)trigger_id;
      //shared_ptr<CAppObject> *cb = new shared_ptr<CAppObject>(callback);
      return Register(classtype, _trigger_id, GetPointer(callback), handler_id);
   }

   bool Register(const int classtype, uint trigger_id, CAppObject &callback, const int handler_id)
   {
      int _trigger_id = (int)trigger_id;
      weak_ptr<CAppObject> *cb = new weak_ptr<CAppObject>(callback);
      return Register(classtype, _trigger_id, cb, handler_id);
   }
   
private:
   bool Register(const int classtype, int& trigger_id, base_ptr<CAppObject> *callback, const int handler_id, const bool automatic_trigger_id = false)
   {
      if (container.Total()-1 < classtype && !container.Resize(classtype+1)) EError_Ret(false)
      if (container.At(classtype) == NULL && !container.Update(classtype,new CArrayObject<CArrayObject<CTriggerCB>>())) {
         EFatal("Cannot add type: "+EnumToString((ENUM_CLASS_NAMES)classtype)); return false;
      }
      
      CArrayObject<CArrayObject<CTriggerCB>> *arr = container.At(classtype);;
      if (arr == NULL) EError_Ret(false)

      if (trigger_id == 0 && automatic_trigger_id) {
         int i = 0;
         CArrayObject<CTriggerCB> *item;
         while(arr.ForEach(item,i)) {
            if (item == NULL && i != 1) break;
         }
         if (i-1 < arr.Total() && i != 0) {
            trigger_id = i-1;
            arr.Update(trigger_id,new CArrayObject<CTriggerCB>());
         } else {
            if (arr.Total() == 0) arr.Add(new CArrayObject<CTriggerCB>());
            arr.Add(new CArrayObject<CTriggerCB>());
            trigger_id = arr.Total()-1;
         }
      }
      
      int trigger_idx = trigger_id;
      if (trigger_idx < 0) EError_Ret(false);
      if (arr.Total() < trigger_idx+1 && !arr.Resize(trigger_idx+1)) EError_Ret(false)
      if (arr.At(trigger_idx) == NULL && !arr.Update(trigger_idx,new CArrayObject<CTriggerCB>())) EError_Ret(false)
      if (arr.At(trigger_idx) == NULL) EError_Ret(false);
      if (!arr.At(trigger_idx).Add(new CTriggerCB(callback,handler_id))) EError_Ret(false);
      
      EInfo(Conc("trigger handler successfully added for ",TypeToString(classtype)," trigger id: ",trigger_id));
      
      return true;
   }
   
public:
   CArrayObject<CTriggerCB> *GetCallbacks(const int classtype, const int trigger_id)
   {
      EDebug(Conc("Triggering: ",EnumToString((ENUM_CLASS_NAMES)classtype)," ",trigger_id))
      CArrayObject<CArrayObject<CTriggerCB>> *arr = container.At(classtype);
      if (arr == NULL) return NULL;
      CArrayObject<CTriggerCB> *callbacks = arr.At(trigger_id);
      if (callbacks == NULL) return NULL;
      return callbacks;
   }
   
   void Trigger(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         callbacks.At(i).Callback();
      }
   }
   
   int TriggerInt(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return 0;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackInt();
      }
      return 0;
   }

   double TriggerDouble(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return 0;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackDouble();
      }
      return 0;
   }
   
   PAppObject TriggerObj(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return NULL;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackObj();
      }
      return NULL;
   }
   
   bool TriggerBool(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return false;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackBool();
      }
      return false;
   }
   
   bool TriggerBoolAnd(const int classtype, const int trigger_id)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return false;
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
      if (callbacks == NULL) return true;
      int total = callbacks.Total();
      bool ret = false;
      for (int i = 0; i != total; i++) {
         ret = ret || callbacks.At(i).CallbackBool();
      }
      return ret;
   }

   void Trigger(const int classtype, const int trigger_id, BAppObject &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         callbacks.At(i).Callback(p);
      }
   }
   
   int TriggerInt(const int classtype, const int trigger_id, BAppObject &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return 0;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackInt(p);
      }
      return 0;
   }
   
   double TriggerDouble(const int classtype, const int trigger_id, BAppObject &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return 0;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackDouble(p);
      }
      return 0;
   }
   
   PAppObject TriggerObj(const int classtype, const int trigger_id, BAppObject &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return NULL;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackObj(p);
      }
      return NULL;
   }
   
   bool TriggerBool(const int classtype, const int trigger_id, BAppObject &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return false;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackBool(p);
      }
      return false;
   }
   
   bool TriggerBoolAnd(const int classtype, const int trigger_id, BAppObject &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return false;
      int total = callbacks.Total();
      bool ret = true;
      for (int i = 0; i != total; i++) {
         ret &= callbacks.At(i).CallbackBool(p);
      }
      return ret;
   }
   
   bool TriggerBoolOr(const int classtype, const int trigger_id, BAppObject &p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return true;
      int total = callbacks.Total();
      bool ret = false;
      for (int i = 0; i != total; i++) {
         ret |= callbacks.At(i).CallbackBool(p);
      }
      return ret;
   }

   // ggggg
   
   template<typename T>
   void Trigger(const int classtype, const int trigger_id, T p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         callbacks.At(i).Callback(p);
      }
   }
   
   template<typename T>
   int TriggerInt(const int classtype, const int trigger_id, T p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return 0;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackInt(p);
      }
      return 0;
   }
   
   template<typename T>
   double TriggerDouble(const int classtype, const int trigger_id, T p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return 0;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackDouble(p);
      }
      return 0;
   }
   
   template<typename T>
   PAppObject TriggerObj(const int classtype, const int trigger_id, T p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return NULL;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackObj(p);
      }
      return NULL;
   }
   
   template<typename T>
   bool TriggerBool(const int classtype, const int trigger_id, T p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return false;
      int total = callbacks.Total();
      for (int i = 0; i != total; i++) {
         return callbacks.At(i).CallbackBool(p);
      }
      return false;
   }
   
   template<typename T>
   bool TriggerBoolAnd(const int classtype, const int trigger_id, T p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return false;
      int total = callbacks.Total();
      bool ret = true;
      for (int i = 0; i != total; i++) {
         ret &= callbacks.At(i).CallbackBool(p);
      }
      return ret;
   }
   
   template<typename T>
   bool TriggerBoolOr(const int classtype, const int trigger_id, T p)
   {
      CArrayObject<CTriggerCB> *callbacks = GetCallbacks(classtype,trigger_id);
      if (callbacks == NULL) return true;
      int total = callbacks.Total();
      bool ret = false;
      for (int i = 0; i != total; i++) {
         ret |= callbacks.At(i).CallbackBool(p);
      }
      return ret;
   }
   
};