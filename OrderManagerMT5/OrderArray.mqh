//

class COrderArray : public CAppObjectArrayObj
{
public:
   virtual int Type() const { return classMT5OrderArray; }
public:
   COrderArray()
   {
      m_free_mode = false;
   }
   COrder* Order(int nIndex){ if (!isset(At(nIndex))) return(NULL); else return((COrder*)At(nIndex)); }   
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(((CApplication*)AppBase()).orderfactory.Create());
      return(true);
   }
};