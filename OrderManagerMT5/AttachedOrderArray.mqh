//

class CAttachedOrderArray : public CAppObjectArrayObj
{
public:
   virtual int Type() const { return classMT5AttachedOrderArray; }
public:
   CAttachedOrder    *AttachedOrder(int nIndex){return((CAttachedOrder*)At(nIndex));}  
   CAttachedOrderArray()
   {
      m_free_mode = true;
   }
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(((CApplication*)AppBase()).attachedorderfactory.Create());      
      return(true);
   } 
};
