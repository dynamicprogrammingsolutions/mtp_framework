//
class COrderSet : public COrderArray {
public:
   virtual int Type() const { return classMT4OrderSet; }

public:
   bool callback(const int _id,CObject *&obj)
   {
      obj = new COrderSet();
      return true;
   }

   int id;
   static int highest_id;
   bool closed;
   bool has_open;
   bool has_closed;
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
   
   virtual bool CreateElement(const int index) {
      return(false);
   }
   
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