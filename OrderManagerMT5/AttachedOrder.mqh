//
class CAttachedOrder : public COrderBase
{
public:
   virtual int Type() const { return classMT5AttachedOrder; }
public:
   string name;
   bool filling_updated;
   static CAttachedOrder* Null() { return(new CAttachedOrder()); }
};
