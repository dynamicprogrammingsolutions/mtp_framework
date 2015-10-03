//
#include "OrderSet.mqh"

class COrderSetArray : public CServiceProviderArrayObj {
private:
   CAppObject* newobjectcallback;

public:
   virtual int Type() const { return classMT4OrderSetArray; }

public:
   COrderSetArray()
   {
      newobjectcallback = new COrderSet();
   }
   
   COrderSetArray(CAppObject* newobj)
   {
      newobjectcallback = newobj;
   }

   virtual COrderSet* NewSetObject()
   {
      CAppObject* obj;
      newobjectcallback.callback(0,obj);
      return obj;
   }

   COrderSet* NewSet()
   {
      COrderSet* set = NewSetObject();
      this.Add(set);
      return set;
   }

   virtual void OnTick()
   {
      BeforeUpdate();
      for (int i = this.Total()-1; i >= 0; i--) {
         if (isset(this.At(i))) {
            COrderSet* set = this.At(i);
            set.OnTick();
            UpdateSet(set,i);
         }
      }
      AfterUpdate();      
   }
   COrderSet* Last()
   {
      if (this.Total() == 0) return NULL;
      else return this.At(this.Total()-1);
   }
   COrderSet* First()
   {
      if (this.Total() == 0) return NULL;
      else return this.At(0);
   }
   virtual void BeforeUpdate()
   {
      
   }
   virtual void UpdateSet(COrderSet* set, int idx)
   {
      if (set.closed) this.Delete(idx);
   }
   virtual void AfterUpdate()
   {
   
   }
};
