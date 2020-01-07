//
#include "Loader.mqh"

class COrderSet : public COrderArray {
public:
   TraitGetType(classOrderSet)
   TraitNewObject(COrderSet)

   int id;
   static int highest_id;
   bool closed;
   bool has_open;
   bool has_closed;
   
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      file.WriteInteger(id);
      file.WriteInteger(highest_id);
      file.WriteBool(closed);
      file.WriteBool(has_open);
      file.WriteBool(has_closed);

      file.WriteInteger(this.Total());
      for (int i = 0; i < Total(); i++) {
         if (!isset(this.At(i))) {
            file.WriteInteger(-1);
            continue;
         }
         COrder* order = this.At(i);
         Print("saving order id: "+order.id);
         file.WriteInteger(order.id);
      }

      return true;      
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      file.ReadInteger(id);
      file.ReadInteger(highest_id);
      file.ReadBool(closed);
      file.ReadBool(has_open);
      file.ReadBool(has_closed);
      
      int total;
      file.ReadInteger(total);
      for (int i = 0; i < total; i++) {
         int _id;
         file.ReadInteger(_id);
         Print("finding order id "+_id);
         COrder* order = App().orderrepository.GetById(_id);
         if (isset(order)) {
            Print("adding order "+order.ticket);
            this.Add(order);
         }
      }
      
      return true;
   }
   
   COrderSet()
   {
      id = highest_id+1;
      highest_id = id;
   }
   COrder* Last()
   {
      if (this.Total() == 0 || this.At(this.Total()-1) == NULL) return NULL;
      CObject* obj = this.At(this.Total()-1);
      if (isset(obj)) return obj;
      else return NULL;
   }
   COrder* First()
   {
      if (this.Total() == 0) return NULL;
      CObject* obj = this.At(0);
      if (isset(obj)) return obj;
      else return NULL;
   }
   virtual void OnTick()
   {
      BeforeUpdate();
      has_open = false;
      has_closed = false;
      for (int i = 0; i < this.Total(); i++) {
         if (isset(this.At(i))) {
            COrder* _order = this.At(i);
            if (state_ongoing(_order.State())) has_open = true;
            else has_closed = true;
            UpdateOrder(_order);
         } else {
            this.Detach(i);
            i--;
         }
      }
      AfterUpdate();
   }
   
   /*virtual bool CreateElement(const int index) {
      return(false);
   }*/
   
   virtual void UpdateOrder(COrder* _order)
   {
      
   }
   virtual void BeforeUpdate()
   {
      
   }
   virtual void AfterUpdate()
   {
      if (!has_open) closed = true;
      else closed = false;   
   }
};
int COrderSet::highest_id = 0;