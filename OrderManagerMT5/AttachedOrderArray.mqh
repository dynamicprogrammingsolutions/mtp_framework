//

class CAttachedOrderArray : public CAppObjectArrayObj
{
public:
   CAttachedOrder    *AttachedOrder(int nIndex){return((CAttachedOrder*)At(nIndex));}  
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(((CApplication*)app).attachedorderfactory.Create());      
      return(true);
   } 
};
