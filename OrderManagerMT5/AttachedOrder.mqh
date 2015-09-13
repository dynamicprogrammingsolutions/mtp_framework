//
class CAttachedOrder : public COrderBase
{
public:
   string name;
   bool filling_updated;
   static CAttachedOrder* Null() { return(new CAttachedOrder()); }
};
