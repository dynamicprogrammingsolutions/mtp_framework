//
class COrderSet : public COrderArray {
public:
   virtual int Type() const { return classMT4OrderSet; }

public:
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
      if (this.Total() == 0) return NULL;
      else return this.At(this.Total()-1);
   }
   COrder* First()
   {
      if (this.Total() == 0) return NULL;
      else return this.At(0);
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