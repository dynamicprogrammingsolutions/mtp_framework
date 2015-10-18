//
class CAttachedOrder : public COrderBase
{
public:
   virtual int Type() const { return classMT5AttachedOrder; }
public:
   CAttachedOrder(CApplication* app)
   {
      app.Prepare(GetPointer(this));
   }
   string name;
   bool filling_updated;
   //static CAttachedOrder* Null() { return(new CAttachedOrder()); }
};
