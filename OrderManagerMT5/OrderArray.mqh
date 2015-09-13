//

class COrderArray : public CAppObjectArrayObj
{
public:
   COrderArray()
   {
      m_free_mode = false;
   }
   COrder* Order(int nIndex){ if (!isset(At(nIndex))) return(NULL); else return((COrder*)At(nIndex)); }   
   COrderFactoryBase* factory() { return ((CApplication*)app).orderfactory; }
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(factory().NewOrderObject());
      return(true);
   }
};